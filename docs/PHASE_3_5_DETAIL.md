# Phase 3.5: Family Backup Access & Ownership Management

## Problem Statement

Vael's current sync architecture assumes a single Drive folder owned by whoever ran setup first. This creates fragile ownership semantics: the admin role exists in the data model but isn't enforced at the storage layer. If the folder-owning user leaves the family or loses their Google account, all backup access is lost. There's no in-app mechanism to grant Drive access to new members, transfer folder ownership, or gracefully revoke access when a member departs.

## Design Principles

1. **Admin owns the storage** — The Drive folder lives in the admin's Google account. Period.
2. **Per-member key wrapping** — Each member gets their own wrapped copy of the FEK, enabling individual revocation without re-keying the entire vault.
3. **Ownership transfer is a first-class operation** — Not a manual Google Drive hack.
4. **Graceful degradation** — Permission errors surface as actionable UI messages, not cryptic failures.
5. **Zero-server constraint holds** — All sharing uses Google Drive's native permission APIs, no intermediary.

## Architecture

### Current Key Hierarchy

```
Family Passphrase (shared, single)
    → PBKDF2 → KEK (single)
        → unwraps → FEK (single wrapped copy in manifest)
```

### New Key Hierarchy (Per-Member Wrapping)

```
Member A Passphrase → PBKDF2(salt_A) → KEK_A → wraps FEK → wrapped_fek_A
Member B Passphrase → PBKDF2(salt_B) → KEK_B → wraps FEK → wrapped_fek_B
                                                    ↓
                                              Same FEK used for
                                              all data encryption
```

### New Manifest Structure (`.meta/manifest.json`)

```json
{
  "schema_version": 2,
  "family_id": "family-001",
  "owner": {
    "user_id": "user-A",
    "email": "ajit@example.com",
    "drive_folder_id": "abc123"
  },
  "members": {
    "user-A": {
      "email": "ajit@example.com",
      "role": "admin",
      "wrapped_fek": "base64...",
      "fek_salt": "base64...",
      "added_at": "2026-03-20T10:00:00Z",
      "added_by": "user-A",
      "last_sync_at": "2026-03-21T08:00:00Z",
      "status": "active"
    },
    "user-B": {
      "email": "pravallika@example.com",
      "role": "member",
      "wrapped_fek": "base64...",
      "fek_salt": "base64...",
      "added_at": "2026-03-21T09:00:00Z",
      "added_by": "user-A",
      "last_sync_at": "2026-03-21T09:30:00Z",
      "status": "active"
    }
  },
  "manifest_version": 5,
  "last_updated": "2026-03-21T09:30:00Z"
}
```

Key changes from v1:
- `owner` block explicitly tracks who owns the Drive folder
- `members` is a map (keyed by user ID) instead of a list
- Each member has their own `wrapped_fek` + `fek_salt`
- `added_by`, `added_at` for audit trail
- `last_sync_at` per member for admin visibility
- `status` field (active, revoked, pending_transfer)

### Manifest Migration (v1 → v2)

On first sync after upgrade:
1. Read existing v1 manifest
2. Admin's device converts single `wrapped_fek`/`fek_salt` into per-member entries
3. All existing members get the same wrapped FEK (derived from current shared passphrase)
4. New `owner` block set to current admin
5. Write v2 manifest
6. Non-admin devices detect v2 on next pull and re-derive their individual wrapped FEK

## User Flows

### Flow 1: Family Setup (Admin Creates Vault)

```
Admin signs in with Google
    → Creates family, becomes admin
    → Sets their personal passphrase
    → App derives KEK_admin from passphrase + random salt_admin
    → App generates random FEK
    → App wraps FEK with KEK_admin → wrapped_fek_admin
    → Creates Drive folder in admin's Google account
    → Writes manifest with owner = admin, members = {admin}
    → Uploads initial empty snapshot
```

### Flow 2: Admin Invites Member

```
Admin opens Family Settings → Members → "Add Member"
    → Enters new member's email address
    → App shares Drive folder with member's Google account (via Drive API)
        - Permission level: "writer" (can read/write files, cannot delete folder or change permissions)
    → Manifest updated: new member entry with status = "pending_setup"
    → Admin tells member the family passphrase (out-of-band, in-person)

New member opens app → signs in with Google
    → App detects shared Drive folder (via Drive API: list shared folders)
    → Prompts for family passphrase
    → Here's the key: member enters the SAME passphrase as admin initially
    → App downloads manifest, finds their pending entry
    → App derives KEK_member from passphrase + existing salt
    → App unwraps FEK from admin's wrapped_fek (temporarily using shared passphrase)
    → App generates new random salt_member
    → Optionally: member sets their OWN passphrase (re-wraps FEK with their own KEK)
    → Updates their entry in manifest with their own wrapped_fek + fek_salt
    → Downloads latest snapshot → bootstraps local DB
    → Status updated to "active"
```

**Why "optionally set own passphrase"?** Families may prefer simplicity (one shared passphrase) or security (individual passphrases). Both work because the FEK is the same — only the wrapping differs.

### Flow 3: Member Removal (Admin Revokes Access)

```
Admin opens Family Settings → Members → selects member → "Remove"
    → Confirmation dialog with implications:
      "This will revoke [name]'s access to family backup.
       Their local data remains on their device until they delete the app.
       A new encryption key will be generated to protect future data."
    → App revokes Drive folder sharing permission (via Drive API)
    → App generates NEW FEK (FEK rotation)
    → App re-wraps new FEK for all remaining active members
    → App re-encrypts latest snapshot with new FEK
    → Manifest updated: removed member's status = "revoked"
    → Remaining members' devices detect FEK rotation on next sync:
      - Pull new manifest
      - Unwrap new FEK using their KEK
      - Store new FEK in secure storage
      - Continue syncing with new FEK

Note: Old changesets remain encrypted with old FEK.
New changesets use new FEK. Pull logic handles both during transition window.
```

**Why rotate FEK on removal?** The removed member has the old FEK cached locally. Without rotation, they could theoretically decrypt future data if they obtained the encrypted files. FEK rotation ensures forward secrecy.

### Flow 4: Ownership Transfer

```
Current admin opens Family Settings → "Transfer Ownership"
    → Selects new admin from active members list
    → Confirmation dialog:
      "This will:
       1. Transfer the backup folder to [name]'s Google account
       2. Make [name] the family admin
       3. You will become a regular member
       This cannot be undone without [name]'s cooperation."
    → Step 1: Verify new admin's Drive folder access is active
    → Step 2: Transfer Drive folder ownership via Google Drive API
        - Note: Drive API `transferOwnership` requires the new owner to accept
        - App sends ownership transfer request
        - New admin's app detects pending transfer on next open
        - New admin accepts transfer
    → Step 3: Update manifest:
        - owner block → new admin
        - old admin role → "member"
        - new admin role → "admin"
    → Step 4: Audit log entry: OWNERSHIP_TRANSFERRED
```

**Google Drive ownership transfer specifics:**
- Uses `permissions.update` with `transferOwnership=true`
- New owner must accept (Google's built-in consent)
- Original owner retains "writer" access automatically
- This is a Google-level operation — Vael orchestrates it but Google enforces it

### Flow 5: Graceful Permission Error Handling

```
On any Drive API call that returns 403 (Forbidden):
    → Check: is the user still in the manifest members list?
        → If yes but status = "revoked": show "Your access has been revoked by the family admin"
        → If yes and status = "active": show "Drive access issue — ask [admin name] to re-share the backup folder"
        → If not in manifest: show "You are not a member of this family vault"
    → Sync paused with clear status indicator
    → Local data remains accessible (offline-first)
    → No data loss — user can still export their local data

On Drive API 404 (folder not found):
    → Check if ownership transfer is in progress
    → Show: "The backup folder may have been moved. Contact [admin name]."
```

### Flow 6: Admin Dashboard

```
Family Settings → Backup Management (admin only)

┌─────────────────────────────────────────────┐
│  Family Backup                              │
│                                             │
│  📁 Storage: Ajit's Google Drive            │
│  🔑 Encryption: AES-256-GCM (active)       │
│  📊 Last backup: 2 hours ago               │
│                                             │
│  Members (2)                                │
│  ┌─────────────────────────────────────────┐│
│  │ 👤 Ajit (you)          Admin    Active  ││
│  │    Last sync: 5 min ago                 ││
│  │                                         ││
│  │ 👤 Pravallika          Member   Active  ││
│  │    Last sync: 1 hour ago                ││
│  └─────────────────────────────────────────┘│
│                                             │
│  [Add Member]  [Transfer Ownership]         │
│                                             │
│  Backup History                             │
│  • Full backup — Mar 21, 8:00 AM           │
│  • Full backup — Mar 14, 8:00 AM           │
│                                             │
│  [Create Backup Now]  [Restore from Backup] │
└─────────────────────────────────────────────┘
```

## Task Breakdown

### Wave 1: Per-Member Key Wrapping & Manifest V2

| # | Task | Details |
|---|------|---------|
| 1.1 | Manifest V2 schema | Define `ManifestV2` model with per-member wrapped FEK, owner block, member status |
| 1.2 | Manifest migration | V1 → V2 migration logic: convert single wrapped FEK to per-member entries |
| 1.3 | Per-member FEK wrapping | Update `FekManager` to wrap/unwrap per-member. `CryptoOrchestrator` handles multi-member flows |
| 1.4 | Individual passphrase support | Allow members to set their own passphrase (optional, defaults to family passphrase) |
| 1.5 | Tests | Round-trip encryption tests for per-member wrapping, manifest migration tests, individual passphrase derivation tests |

### Wave 2: Drive Permission Management

| # | Task | Details |
|---|------|---------|
| 2.1 | Drive permission service | New `DrivePermissionService` wrapping Google Drive Permissions API (list, create, update, delete permissions) |
| 2.2 | Admin-creates-folder enforcement | Ensure Drive folder creation only happens on admin's account. Validate at `SyncOrchestrator` level |
| 2.3 | In-app member invitation | Admin enters email → app shares Drive folder with "writer" role → updates manifest |
| 2.4 | Permission revocation | Admin removes member → revokes Drive permission → triggers FEK rotation |
| 2.5 | Permission error handling | Map Drive API 403/404 to actionable UI messages. Graceful sync pause |
| 2.6 | Tests | Mock Drive API permission operations, error mapping tests, FEK rotation round-trip tests |

### Wave 3: Ownership Transfer

| # | Task | Details |
|---|------|---------|
| 3.1 | Transfer initiation flow | Admin selects new admin → validates eligibility → sends Drive ownership transfer |
| 3.2 | Transfer acceptance flow | New admin's app detects pending transfer → accept/reject → manifest update |
| 3.3 | Manifest ownership update | Atomic update: owner block, role swap, audit log entry |
| 3.4 | Edge cases | Transfer timeout handling, cancel transfer, what if new admin hasn't synced recently |
| 3.5 | Tests | Full transfer flow tests, rollback on failure, concurrent modification tests |

### Wave 4: Admin Dashboard & Member Management UI

| # | Task | Details |
|---|------|---------|
| 4.1 | Admin backup dashboard | Storage info, member list with sync status, backup history |
| 4.2 | Add member flow UI | Email input → share → pending state → active on acceptance |
| 4.3 | Remove member flow UI | Confirmation dialog → revoke → FEK rotation progress |
| 4.4 | Transfer ownership UI | Member selection → confirmation → progress → completion |
| 4.5 | Member view (non-admin) | Read-only backup status, own sync status, who admin is |
| 4.6 | Widget tests | All new screens and flows |

### Wave 5: FEK Rotation & Forward Secrecy

| # | Task | Details |
|---|------|---------|
| 5.1 | FEK rotation engine | Generate new FEK → re-wrap for all active members → re-encrypt latest snapshot |
| 5.2 | Dual-FEK pull support | Pull logic handles changesets encrypted with old FEK during transition window |
| 5.3 | Rotation trigger integration | Wire rotation to member removal flow |
| 5.4 | Rotation status tracking | Manifest tracks `fek_generation` counter so devices know when to refresh |
| 5.5 | Tests | Rotation round-trip, dual-FEK decryption, concurrent rotation prevention |

## Google Drive API Specifics

### Required Scopes
Current: `drive.file` (access only files created by app) — **sufficient for all operations**

### Permission Levels Used
- **owner** → admin (full control)
- **writer** → members (can read/write files, cannot manage permissions or delete root folder)

### Key API Calls

```
# Share folder with member
POST https://www.googleapis.com/drive/v3/files/{folderId}/permissions
{ "type": "user", "role": "writer", "emailAddress": "member@gmail.com" }

# Revoke member access
DELETE https://www.googleapis.com/drive/v3/files/{folderId}/permissions/{permissionId}

# Transfer ownership
PATCH https://www.googleapis.com/drive/v3/files/{folderId}/permissions/{permissionId}
{ "role": "owner", "transferOwnership": true }

# List current permissions
GET https://www.googleapis.com/drive/v3/files/{folderId}/permissions
```

### Important Constraints
- `drive.file` scope only gives access to files/folders created by the app — this is by design (principle of least privilege)
- Ownership transfer requires the new owner to accept via Google's consent mechanism
- Google Workspace accounts may have domain-level sharing restrictions — handle gracefully
- Consumer Google accounts allow sharing with any email

## Migration & Backward Compatibility

- V1 manifest devices continue to work in read-only mode until they upgrade
- First admin device to upgrade writes V2 manifest
- Non-admin devices upgrade transparently on next pull (they just need to find their wrapped FEK in the new per-member map)
- No re-encryption of existing data — only the manifest wrapper changes
- FEK rotation (on member removal) is the only scenario requiring re-encryption of the latest snapshot

## Security Considerations

| Concern | Mitigation |
|---------|------------|
| Removed member has cached FEK | FEK rotation generates new key; old FEK only decrypts historical data |
| Drive permissions != encryption access | Both layers required: Drive permission (transport) + FEK (encryption). Revoking either blocks access |
| Admin account compromised | Attacker gets encrypted blob access but not FEK (passphrase never stored). Family can transfer ownership to new admin + rotate FEK |
| Manifest tampering | Manifest itself should be signed by admin's KEK in future phase. Currently integrity-checked by Drive API auth |
| Passphrase brute-force on wrapped FEK | PBKDF2 100K iterations provides computational cost barrier. Future: upgrade to Argon2id |

## Exit Criteria

- [ ] Admin creates family vault → Drive folder owned by admin's Google account
- [ ] Admin invites member by email → member gets Drive access + can derive FEK
- [ ] Member sets individual passphrase → can sync independently of shared passphrase
- [ ] Admin removes member → Drive access revoked + FEK rotated + remaining members unaffected
- [ ] Admin transfers ownership to member → Drive folder ownership transfers + roles swap
- [ ] Permission errors show actionable messages (not cryptic failures)
- [ ] V1 → V2 manifest migration is seamless for existing users
- [ ] All flows have comprehensive tests (crypto round-trips, permission mocks, UI widget tests)
