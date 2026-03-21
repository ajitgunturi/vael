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

## Test Count: 599 unit/widget (all green) + 29 simulator tests (iPhone) + 23 journey tests (iPad Pro 11-inch) — all green

## Current Work: E2E Simulator Test Suite — COMPLETE

### Branch: feat/simulator-tests

### Delivered
- `integration_test/` directory with 6 feature-level test files (29 tests, passing on iPhone 17 Pro Max)
  - `app_smoke_test.dart` (4), `navigation_flow_test.dart` (6), `account_crud_flow_test.dart` (5)
  - `transaction_flow_test.dart` (6), `budget_flow_test.dart` (4), `theme_rendering_test.dart` (4)
- `integration_test/simulator_test_app.dart` — test harness (AdaptiveScaffold, in-memory DB, seedTestFamily)
- iOS build fixes: ICloudPlugin added to pbxproj, AppDelegate optional unwrap, CocoaPods installed, xcode-select → Xcode.app
- `integration_test` SDK dependency added to pubspec.yaml
- 5 E2E journey test files (23 tests, all green on iPad Pro 11-inch M5):
  - `journey_net_worth_test.dart` (5), `journey_balance_cascade_test.dart` (6)
  - `journey_monthly_summary_test.dart` (5), `journey_budget_actuals_test.dart` (4)
  - `journey_cross_feature_test.dart` (3)
- `e2e_helpers.dart` — bounded `settle()` helper replacing `pumpAndSettle` for iPad compatibility
- AdaptiveScaffold responsive fix: removed nested double-AppBar, proper medium/expanded layouts

### Fixes Applied
- Dropdown interaction on iPad: `find.byType(DropdownButton<String>).first` for kind selector
- `pumpAndSettle` hang fix: bounded `settle()` helper handles infinite animations (CircularProgressIndicator)
- `navigateToTab` uses `.first` to prefer NavigationRail label over inner AppBar title
- AdaptiveScaffold: removed outer Scaffold+AppBar from medium/expanded layouts (eliminated double AppBar on iPad)
- Settings icon relocated: compact → BottomNav item; medium → NavigationRail trailing; expanded → sidebar ListTile

### Deferred
- `journey_loan_detail_test.dart` (3 tests) — deferred to Phase 4

## Next: Phase 4 — Advanced Features
