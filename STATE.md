# Vael — State

## Current Phase: 3 — Encryption + Sync (COMPLETE)
## Branch: feat/phase-2

## Phase 3 Delivered
### Crypto Track
- **3.1** PBKDF2 key derivation (100k iterations, SHA-256, 32-byte salt)
- **3.2** AES-256-GCM encrypt/decrypt (random IV, IV||ct||tag format)
- **3.3** FEK Manager (generate, wrap/unwrap with KEK)
- **3.4** Key Storage (platform secure storage abstraction)
- **3.5** Crypto Orchestrator (first device setup, join, passphrase change)
- **3.6** Join flow (unwrap FEK from manifest)
- **3.7** Passphrase change (re-wrap FEK with new KEK)

### Sync Track
- **3.9** Sync changelog + state tables/DAOs (schema v5)
- **3.10** Changeset serializer (JSON, INSERT/UPDATE/DELETE, round-trip)
- **3.11** Sync push (batch → serialize → encrypt → upload)
- **3.12** Sync pull (download → decrypt → deserialize → apply)
- **3.13** Conflict resolver (LWW, additive merge, delete wins, schema check)
- **3.14** Snapshot manager (encrypt/decrypt full DB snapshots)
- **3.15** Drive client (folder structure, manifest, changesets, snapshots)

### Integration
- **3.16** Sync orchestrator (coordinates push/pull/snapshot with FEK)
- Passphrase setup screen (validation, confirmation, visibility toggle)
- Sync status screen (device ID, pending count, timestamps, manual controls)

## Test Count: 517 (all green)

## Next: Phase 4 — Advanced Features
