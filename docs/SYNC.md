# Vael — Google Drive Sync Design

## Drive Folder Structure

```
Vael (shared folder)
├── .meta/
│   ├── manifest.json          # Family metadata, wrapped FEK, PBKDF2 salt, member list
│   └── schema_version.json    # Current schema version for migration compatibility
├── changesets/
│   ├── 2026-03-20T10-30-00_deviceA_001.enc   # Encrypted changeset
│   ├── 2026-03-20T10-35-00_deviceB_002.enc
│   └── ...
└── snapshots/
    └── latest.enc             # Encrypted full DB snapshot (periodic)
```

## Sync Protocol

### Push (Local → Drive)

1. Every local write (insert/update/delete) appends a row to `sync_changelog`:
   ```
   entity_type | entity_id | operation | payload (JSON) | timestamp | synced | changeset_id
   ```
2. Periodically (every 30s while active, or on app background event):
   - Batch all `synced = false` changelog entries
   - Serialize as JSON array of operations
   - Encrypt with FEK (AES-256-GCM, random 12-byte IV)
   - Upload to `changesets/` folder on Drive
   - Mark changelog entries as `synced = true` with `changeset_id`

### Pull (Drive → Local)

1. On app foreground + periodically (every 60s):
   - `files.list` on `changesets/` folder, filter `modifiedTime > lastPullTimestamp`
   - Download each new changeset file
   - Decrypt with FEK
   - Apply operations to local SQLite in timestamp order
   - Update `sync_state.last_pull_at`

### Full Snapshot

Triggered weekly or on-demand (Settings → "Create backup"):
1. Export local SQLite database as bytes
2. Encrypt with FEK (AES-256-GCM)
3. Upload to `snapshots/latest.enc` (overwrites previous)
4. Update `sync_state.last_snapshot_at`

New devices bootstrap from snapshot instead of replaying all changesets.

## Changeset Format (Pre-Encryption)

```json
{
  "device_id": "abc123",
  "sequence": 42,
  "timestamp": "2026-03-20T10:30:00Z",
  "operations": [
    {
      "op": "INSERT",
      "table": "transactions",
      "id": "uuid-here",
      "data": { "amount": 15000, "date": "2026-03-20", "description": "Groceries", "category_id": "uuid" }
    },
    {
      "op": "UPDATE",
      "table": "accounts",
      "id": "uuid-here",
      "data": { "balance": 485000 },
      "prev": { "balance": 500000 }
    },
    {
      "op": "DELETE",
      "table": "transactions",
      "id": "uuid-here",
      "deleted_at": "2026-03-20T10:30:00Z"
    }
  ]
}
```

## Conflict Resolution

| Scenario | Strategy | Rationale |
|----------|----------|-----------|
| Same entity updated on two devices | Last-writer-wins (by timestamp) | Concurrent edits to the same account/goal are rare in a family app |
| Two devices create different transactions | Additive merge (both kept) | Transactions are append-only by nature |
| Delete on one device, update on another | Delete wins (tombstone propagated) | Explicit user intent to remove should be respected |
| Schema version mismatch | Block sync, prompt upgrade | Prevents data corruption from incompatible schemas |

### Why Last-Writer-Wins is Sufficient

Family finance is low-contention:
- Typically one person manages accounts at a time
- Transactions are created (not edited) most of the time
- Budget limits change infrequently
- The window for true conflicts (same entity, both offline) is small

If stronger consistency is needed later, the changeset format already captures `prev` values, enabling operational transform or CRDT-like merging.

## Sync State Table

```sql
CREATE TABLE sync_state (
  device_id     TEXT PRIMARY KEY,
  last_push_at  INTEGER,  -- epoch ms
  last_pull_at  INTEGER,  -- epoch ms
  last_snapshot_at INTEGER,
  push_sequence INTEGER DEFAULT 0
);
```

## Edge Cases

| Case | Handling |
|------|---------|
| No internet | Writes accumulate in sync_changelog. Push/pull resume when online. |
| Large backlog (1000+ changesets) | Pull triggers snapshot download instead of replaying all changesets |
| Drive quota exceeded | Surface error in Settings → Sync Status. Suggest cleanup or snapshot-only mode. |
| Concurrent push from two devices | Drive file names include device_id + sequence — no overwrites. Pull merges both. |
| App killed during push | Changeset entries remain `synced = false`. Next push retries. |
| Corrupted changeset | Skip with warning in sync log. Alert user in Settings. |

## Google Drive API Usage

| Operation | API Call | Frequency |
|-----------|---------|-----------|
| List new changesets | `files.list` with `modifiedTime` filter | Every 60s |
| Download changeset | `files.get` with `alt=media` | Per new file |
| Upload changeset | `files.create` with multipart upload | Every 30s (if changes exist) |
| Upload snapshot | `files.update` on `latest.enc` | Weekly |
| Read manifest | `files.get` on `manifest.json` | On app launch |
| Update manifest | `files.update` on `manifest.json` | On passphrase change / member add |

Estimated Drive usage: ~1-5 MB/month for a typical family (hundreds of transactions/month).
