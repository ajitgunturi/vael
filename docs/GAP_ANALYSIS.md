# Vael — Design vs Implementation Gap Analysis

> Generated 2026-03-22. Audited every doc in `docs/` against `lib/` implementation.

## Summary

| Severity | Count | Description |
|----------|-------|-------------|
| **CRITICAL** | 10 | Feature described in docs, implementation missing/broken, user-facing |
| **MODERATE** | 17 | Feature partially implemented, some functionality works |
| **MINOR** | 11 | Cosmetic differences, naming mismatches, non-functional |
| **DEFERRED** | 5 | Explicitly deferred in roadmap (Scenario Sandbox, Vault, Notifications, macOS/iPad) |

---

## CRITICAL Gaps (Remediation Priority Order)

### C1. SQLCipher Not Activated
- **Doc**: ENCRYPTION.md — "SQLCipher (AES-256-CBC, PBKDF2 key from FEK) encrypts the local database."
- **Code**: `lib/core/providers/database_providers.dart:15-24` creates `NativeDatabase` (unencrypted). `sqlcipher_flutter_libs` is in pubspec but never used.
- **Impact**: Local database is **unencrypted at rest**. Violates Privacy principle #1.

### C2. Sync Changelog Never Populated
- **Doc**: SYNC.md — "Every local write appends a row to sync_changelog."
- **Code**: No DAO writes to `sync_changelog`. The table exists but is permanently empty.
- **Impact**: Push has nothing to push. Sync is architecturally complete but functionally inert.

### C3. Apply Operations Not Implemented
- **Doc**: SYNC.md — "Apply operations to local SQLite in timestamp order."
- **Code**: `SyncOrchestrator.pull()` passes `onOperationsApplied ?? (_) async {}` — a no-op callback.
- **Impact**: Pull downloads changesets but never applies them to local DB.

### C4. Conflict Resolver Not Integrated
- **Doc**: SYNC.md — LWW, additive merge, delete wins, schema block.
- **Code**: `ConflictResolver` exists as standalone class but `SyncPull.pull()` never calls it. Remote operations applied in order without conflict checking.
- **Impact**: Multi-device sync would overwrite local changes silently.

### C5. Lock Screen Missing
- **Doc**: UI_DESIGN.md 2.1 — Lock screen with passphrase input and biometric option.
- **Code**: `app.dart` goes directly to `HomeShell` or `OnboardingFlow`. No passphrase gate.
- **Impact**: Anyone with device access sees financial data. Encryption is meaningless without it.

### C6. Visibility Model Mismatch (SHARED/NAME_ONLY/HIDDEN)
- **Doc**: UI_DESIGN.md 0.5 and DATA_MODEL.md — Three-tier: SHARED, NAME_ONLY, HIDDEN.
- **Code**: `lib/core/models/enums.dart:27` defines `private_`, `shared`, `familyWide`. NAME_ONLY tier is missing.
- **Impact**: Family boundary model (principle #2) is incomplete. No way to share account name but hide balance.

### C7. Projection Engine Oversimplified
- **Doc**: archived/BUSINESS_LOGIC_PORTING.md — 60-month engine consuming recurring rules, RSU vestings, policy payouts, education costs, fund drawdowns, three scenarios with multipliers.
- **Code**: `ProjectionEngine` takes flat monthly income/expenses with hardcoded defaults and rate spreads. Does not consume recurring rules or any other data source.
- **Impact**: Projection screen shows toy data, not real financial projections.

### C8. Recovery Key Not Implemented
- **Doc**: ENCRYPTION.md — "Recommend generating a printable recovery key during setup."
- **Code**: No recovery key code exists anywhere.
- **Impact**: If user forgets passphrase, all encrypted data is permanently lost.

### C9. Audit Log Dead Table
- **Doc**: DATA_MODEL.md — Immutable audit trail for compliance.
- **Code**: `audit_log` table exists, no DAO, never written to.
- **Impact**: No audit trail despite architectural intent.

### C10. Balance Snapshot Never Created
- **Doc**: DATA_MODEL.md — `balance_snapshots` for net worth history.
- **Code**: `BalanceSnapshotDao` exists but no code creates daily snapshots (no scheduler for `BalanceReconciliation`).
- **Impact**: Net worth chart has no historical data points.

---

## MODERATE Gaps

| # | Gap | Doc | Code |
|---|-----|-----|------|
| M1 | No database indexes defined (5 specified) | DATA_MODEL.md | All table files |
| M2 | No `deletedAt` on `recurring_rules` (soft delete spec) | DATA_MODEL.md | `tables/recurring_rules.dart` |
| M3 | No `deletedAt` on `transactions` | DATA_MODEL.md | `tables/transactions.dart` |
| M4 | No database migration files (schema version 6) | DATA_MODEL.md | `migrations/` empty |
| M5 | Goal-investment linking not used in calculations | archived/BUSINESS_LOGIC_PORTING.md | `goal_tracking.dart` |
| M6 | Investment baseline return lookup: only platform defaults, no XIRR or family config | archived/BUSINESS_LOGIC_PORTING.md | `investment_valuation.dart` |
| M7 | Budget summary missing self-transfer filter | archived/BUSINESS_LOGIC_PORTING.md | `budget_summary.dart:52-66` |
| M8 | Closed period enforcement not implemented | archived/BUSINESS_LOGIC_PORTING.md | Nowhere |
| M9 | Idempotent key for recurring dedup not implemented | archived/BUSINESS_LOGIC_PORTING.md | `recurring_scheduler.dart` |
| M10 | Dedup hash for statement import not implemented | archived/BUSINESS_LOGIC_PORTING.md | `statement_parser.dart` |
| M11 | Biometric unlock not implemented | ENCRYPTION.md | No file |
| M12 | No periodic sync scheduling (30s push, 60s pull) | SYNC.md | `sync_orchestrator.dart` |
| M13 | No changeset backlog optimization (1000+ triggers snapshot) | SYNC.md | `sync_pull.dart` |
| M14 | Account Detail screen missing (balance history, txn list) | UI_DESIGN.md 2.4 | No file |
| M15 | Inline editing contract not implemented (tap-to-edit) | UI_DESIGN.md 0.3 | All screens |
| M16 | Cascade preview not implemented | UI_DESIGN.md 0.2 | All form screens |
| M17 | SyncOrchestrator not wired to permission/transfer services | PHASE_3_5 | `sync_orchestrator.dart` |

---

## MINOR Gaps

| # | Gap |
|---|-----|
| m1 | `investment_holdings` schema divergence (purpose-driven buckets vs per-holding) — intentional but undocumented |
| m2 | `power()` function not ported (uses dart:math pow) |
| m3 | Category group legacy fallback mapper missing |
| m4 | Drive folder named "Vael" not opaque hash |
| m5 | `features/family/` directories are empty shells |
| m6 | Sync status dot missing from screen headers |
| m7 | Undo snackbar not implemented |
| m8 | `CloudStorageInterface` missing `provider` and `supportsSharing` getters |
| m9 | ManifestV2 missing `provider` field |
| m10 | ManifestOwner missing `drive_folder_id` |
| m11 | `schema_version.json` for sync never created |

---

## DEFERRED (Explicitly Future Scope)

| # | Feature | Doc Reference |
|---|---------|---------------|
| D1 | Scenario Sandbox / Decision Engine | UI_DESIGN.md v3 |
| D2 | Document Vault | UI_DESIGN.md 0.1 |
| D3 | Net Worth Milestones + Notifications | UI_DESIGN.md 0.1 |
| D4 | macOS-specific features (menu bar, toolbar, shortcuts) | ARCHITECTURE.md |
| D5 | iPad-specific features (Split View, Slide Over, pointer) | ARCHITECTURE.md |

---

## Recommended Remediation Order

1. **SQLCipher activation** (C1) — Privacy is principle #1. Database is unencrypted.
2. **Lock Screen** (C5) — Required for encryption to have meaning.
3. **Sync plumbing** (C2 + C3 + C4) — changelog population, apply operations, conflict integration.
4. **Visibility model** (C6) — NAME_ONLY tier for family boundary principle.
5. **Audit log DAO** (C9) — Required for immutable audit trail.
6. **Recovery key** (C8) — Safety net before real user data is at risk.
7. **Projection engine** (C7) — Enrich with recurring rules and DB data.
8. **Balance snapshots** (C10) — Scheduler for net worth history.
9. **Database indexes** (M1) — Performance for production data volumes.
10. **Soft deletes** (M2, M3) — Required for sync and undo flows.
