# Vael — TDD Implementation Plan

## Context

Vael is a greenfield Flutter family finance app being ported from a Java/PostgreSQL monolith to a local-first, zero-server native app. This plan implements the full app using strict TDD (Red-Green-Refactor) across 5 phases, ~14 weeks.

**Governing docs**: `docs/INTENT.md` (constitutional), `docs/ARCHITECTURE.md`, `docs/DATA_MODEL.md`, `docs/BUSINESS_LOGIC.md`, `docs/ENCRYPTION.md`, `docs/SYNC.md`, `docs/UI_DESIGN.md`, `docs/ROADMAP.md`, `docs/MIGRATION.md`

---

## Phase 1: Foundation (Weeks 1-2) — COMPLETE ✅

> **172 tests, all green. Committed: b933378**

### 1.0 — Project Bootstrapping (infra, no tests) ✅
- `flutter create --platforms ios,android,macos --org com.vael vael`
- Configure `pubspec.yaml`: drift, drift_dev, sqlcipher_flutter_libs, riverpod, flutter_riverpod, pointycastle, flutter_secure_storage, google_sign_in, googleapis, fl_chart, uuid, mockito, build_runner
- `analysis_options.yaml` with strict lints
- `Makefile` with targets: test, build-runner, coverage, analyze
- Create full `lib/` and `test/` directory tree per ARCHITECTURE.md
- Minimal `lib/main.dart` + `lib/app.dart` stubs

### 1.1 — Enums and Value Types ✅ (21 tests)
- **Red**: `test/core/models/enums_test.dart` — verify AccountType(6), TransactionKind(7), CategoryGroup(4+MISSING), Visibility(3), BucketType(8), UserRole(2), GoalStatus(4)
- **Green**: `lib/core/models/enums.dart`

### 1.2 — Money Type (Integer Minor Units) ✅ (32 tests)
- **Red**: `test/core/models/money_test.dart` — construction from paise, fromMajor(), arithmetic (+,-,negate), Indian lakh formatting, comparisons, zero/positive/negative checks
- **Green**: `lib/core/models/money.dart`, `lib/shared/utils/formatters.dart`

### 1.3 — Financial Math (Pure Functions) ✅ (13 tests)
- **Red**: `test/core/financial/financial_math_test.dart` — pmt, fv, pv, inflationAdjust, requiredSip verified against Excel. Exact integer assertions, zero-rate edge cases
- **Green**: `lib/core/financial/financial_math.dart`

### 1.4 — Amortization Calculator ✅ (26 tests)
- **Red**: `test/core/financial/amortization_test.dart` — 10L/10%/12mo full schedule, prepayments at month 6, multiple prepayments, 0% edge, enrichment (remaining tenure, interest saved, etc.), sum of principal = original loan
- **Green**: `lib/core/financial/amortization.dart`, `lib/core/financial/amortization_row.dart`

### 1.5 — Drift Database Schema (Core Tables) ✅ (9 tests)
- **Red**: `test/core/database/schema_test.dart` — insert/query families, users (FK), accounts (soft delete), categories, transactions (int amounts), balance_snapshots, audit_log (insert-only)
- **Green**: `lib/core/database/database.dart`, `lib/core/database/tables/{families,users,accounts,categories,transactions,balance_snapshots,audit_log}.dart`

### 1.6 — Core DAOs (Family-Scoped Queries) ✅ (17 tests)
- **Red**: `test/core/database/daos/{account,transaction,category}_dao_test.dart` — family isolation, soft delete filtering, date range queries, kind filtering
- **Green**: `lib/core/database/daos/{account,transaction,category}_dao.dart`

### 1.7 — Account Balance Rules ✅ (17 tests)
- **Red**: `test/core/financial/balance_rules_test.dart` — INCOME/SALARY/DIVIDEND add, EXPENSE/EMI/INSURANCE subtract, TRANSFER two-step, atomicity (rollback on failure), self-transfer no-op
- **Green**: `lib/core/financial/balance_rules.dart`

### 1.8 — Google Sign-In Wrapper ✅ (12 tests)
- **Red**: `test/core/auth/google_auth_test.dart` — mock signIn/signOut, error handling, auth headers
- **Green**: `lib/core/auth/google_auth_service.dart`, `lib/core/auth/google_auth_result.dart`

### 1.9 — Navigation Shell (AdaptiveScaffold) ✅ (16 tests)
- **Red**: `test/shared/layout/adaptive_scaffold_test.dart` — <600dp=BottomNav, 600-900=NavigationRail, >900=persistent drawer, 6 destinations
- **Green**: `lib/shared/layout/adaptive_scaffold.dart`, `lib/shared/layout/breakpoints.dart`

### 1.10 — Theme System ✅ (9 tests)
- **Red**: `test/shared/theme/theme_test.dart` — light/dark tokens, WCAG contrast, amount colors (green/red/gray)
- **Green**: `lib/shared/theme/app_theme.dart`, `lib/shared/theme/color_tokens.dart`

---

## Phase 2: Core Features (Weeks 3-5)

### 2.1 — Riverpod Provider Architecture
- **Red**: `test/core/providers/account_providers_test.dart` — stream from DAO, rebuild on change, netWorthProvider filters by visibility
- **Green**: `lib/core/providers/{account,database}_providers.dart`
- Establish convention: StreamProvider for DB entities, FutureProvider for one-shot computations
- **Depends on**: 1.6

### 2.2 — Dashboard Aggregation Logic
- **Red**: `test/core/financial/dashboard_aggregation_test.dart` — net worth (assets-liabilities-CC), account grouping, family vs personal scope, monthly summary
- **Red**: `test/features/dashboard/dashboard_providers_test.dart` — combined provider, scope toggle
- **Green**: `lib/core/financial/dashboard_aggregation.dart`, `lib/features/dashboard/providers/dashboard_providers.dart`
- **Depends on**: 1.7, 2.1

### 2.3 — Account CRUD UI
- **Red**: `test/features/accounts/{account_list_screen,account_form}_test.dart` — grouped list, balance formatting, visibility badge, form validation, CRUD
- **Green**: `lib/features/accounts/{screens,providers,widgets}/`
- Extract `lib/shared/widgets/currency_input.dart` for reuse
- **Depends on**: 2.1, 1.9

### 2.4 — Transaction CRUD UI
- **Red**: `test/features/transactions/{transaction_list,transaction_form,transaction_cascade}_test.dart` — date/category filters, kind selector, TRANSFER dual-picker, cascade tests (create/edit/delete -> balance updates)
- **Green**: `lib/features/transactions/{screens,providers,widgets}/`
- **Depends on**: 2.1, 2.3, 1.7

### 2.5 — Budget Logic and UI
- **Red**: `test/core/financial/budget_summary_test.dart` — actuals by group, remaining/overspent, unbudgeted groups, expense-only filter, shared-accounts-only
- **Red**: `test/features/budgets/budget_screen_test.dart` — groups with bars, overspent highlighting, inline limit editing
- **Green**: `lib/core/financial/budget_summary.dart`, `lib/features/budgets/{screens,providers}/`, `lib/core/database/{daos/budget_dao,tables/budgets}.dart`
- **Depends on**: 2.4, 1.6

### 2.6 — Goals Logic and UI
- **Red**: `test/core/financial/goal_tracking_test.dart` — inflation-adjusted target, required SIP, status inference, investment linking
- **Red**: `test/features/goals/goal_screen_test.dart` — cards with progress bars, status badges, form
- **Green**: `lib/core/financial/goal_tracking.dart`, `lib/features/goals/{screens,providers}/`, `lib/core/database/{daos/goal_dao,tables/goals}.dart`
- **Depends on**: 1.3, 2.1

### 2.7 — Loan Detail and Amortization UI
- **Red**: `test/features/loans/{loan_detail,emi_payment}_test.dart` — summary, amortization table, prepayment simulation, EMI split (principal+interest)
- **Green**: `lib/features/loans/{screens,providers}/`, `lib/core/database/{daos/loan_dao,tables/loan_details}.dart`
- **Depends on**: 1.4, 2.4

### 2.8 — Dashboard UI
- **Red**: `test/features/dashboard/dashboard_screen_test.dart` — net worth card, monthly summary, goals section, upcoming, scope toggle, adaptive layout
- **Green**: `lib/features/dashboard/{screens,widgets}/`
- **Depends on**: 2.2, 2.6, 1.9

### Phase 2 Dependency Graph
```
2.1 (Providers) ← 1.6
├── 2.2 (Dashboard Aggregation) ← 1.7, 2.1
├── 2.3 (Account CRUD UI) ← 2.1, 1.9
├── 2.6 (Goals Logic) ← 1.3, 2.1
└── 2.4 (Transaction CRUD UI) ← 2.1, 2.3, 1.7
    ├── 2.5 (Budget Logic) ← 2.4, 1.6
    └── 2.7 (Loan Detail UI) ← 1.4, 2.4
2.8 (Dashboard UI) ← 2.2, 2.6, 1.9
```

### Phase 2 Exit Criteria
- All core screens functional on phone + tablet layouts
- Transaction cascade verified end-to-end
- 90%+ coverage on `core/financial/`

---

## Phase 3: Encryption + Sync (Weeks 6-8)

### Crypto Track (sequential)

**3.1 — PBKDF2 Key Derivation**
- **Red**: `test/core/crypto/key_derivation_test.dart` — deterministic output, 100k iterations, SHA-256, salt sensitivity, 256-bit output
- **Green**: `lib/core/crypto/key_derivation.dart`

**3.2 — AES-256-GCM Encrypt/Decrypt**
- **Red**: `test/core/crypto/aes_gcm_test.dart` — round-trip, random IV (non-deterministic ciphertext), wrong key fails, tampered ciphertext fails, empty/large plaintext, ciphertext format (IV||ct||tag)
- **Green**: `lib/core/crypto/aes_gcm.dart`

**3.3 — FEK Management**
- **Red**: `test/core/crypto/fek_manager_test.dart` — generate (random 32B), wrap/unwrap round-trip, wrong KEK fails
- **Green**: `lib/core/crypto/fek_manager.dart`
- **Depends on**: 3.1, 3.2

**3.4 — Key Storage**
- **Red**: `test/core/crypto/key_storage_test.dart` — store/retrieve/delete/overwrite, namespaced by family_id
- **Green**: `lib/core/crypto/key_storage.dart` (wraps flutter_secure_storage, mocked in tests)

**3.5 — Passphrase Setup Flow (First Device)**
- **Red**: `test/core/crypto/setup_flow_test.dart` + `test/features/settings/passphrase_setup_screen_test.dart`
- **Green**: `lib/core/crypto/crypto_orchestrator.dart`, `lib/features/settings/screens/passphrase_setup_screen.dart`
- **Depends on**: 3.3, 3.4

**3.6 — Join Flow** → **3.7 — Passphrase Change** → **3.8 — SQLCipher Integration**
- Each extends `crypto_orchestrator.dart`. SQLCipher test requires integration_test (native).

### Sync Track (parallel with crypto after 3.2)

**3.9 — Sync Changelog + State Tables/DAOs**
- **Red**: `test/core/database/daos/{sync_changelog,sync_state}_dao_test.dart`
- **Green**: `lib/core/database/{tables,daos}/sync_{changelog,state}.dart`
- **Depends on**: 1.5

**3.10 — Changeset Serialization**
- **Red**: `test/core/sync/changeset_serializer_test.dart` — round-trip, INSERT/UPDATE(with prev)/DELETE
- **Green**: `lib/core/sync/changeset_serializer.dart`
- **Depends on**: 3.9

**3.11 — Push** | **3.12 — Pull** (parallel)
- **Red**: `test/core/sync/{sync_push,sync_pull}_test.dart` — batch, encrypt, upload/download, mark synced, error handling
- **Green**: `lib/core/sync/{sync_push,sync_pull}.dart`
- **Depends on**: 3.10, 3.2

**3.13 — Conflict Resolution**
- **Red**: `test/core/sync/conflict_resolution_test.dart` — last-writer-wins, additive merge, delete wins, deterministic mock clocks, schema version mismatch
- **Green**: `lib/core/sync/conflict_resolver.dart`
- **Depends on**: 3.12

**3.14 — Full Snapshot** (parallel with sync track)
- **Red**: `test/core/sync/snapshot_test.dart` — export->encrypt->decrypt->restore round-trip
- **Green**: `lib/core/sync/snapshot_manager.dart`

**3.15 — Drive API Client**
- **Red**: `test/core/sync/drive_client_test.dart` — list/upload/download/folder creation/manifest/errors
- **Green**: `lib/core/sync/drive_client.dart`
- **Depends on**: 1.8

**3.16 — Sync Orchestrator + Settings UI** (joins both tracks)
- **Red**: `test/core/sync/sync_orchestrator_test.dart` + `test/features/settings/sync_status_test.dart`
- **Green**: `lib/core/sync/sync_orchestrator.dart`, `lib/features/settings/{screens/sync_status_screen,providers/sync_providers}.dart`

### Phase 3 Exit Criteria
- All crypto round-trip tests pass
- Sync push/pull with mocked Drive API
- Conflict resolution with deterministic clocks
- 90%+ coverage on `core/crypto/`, `core/sync/`

---

## Phase 4: Advanced Features (Weeks 9-11)

### 4.1 — Recurring Rules (Schema + Engine)
- **Red**: DAO tests (float frequency, pause/resume, escalation) + engine tests (monthly/annual/biweekly generation, escalation, idempotency)
- **Green**: `lib/core/database/{tables/recurring_rules,daos/recurring_rule_dao}.dart`, `lib/core/financial/recurring_engine.dart`

### 4.2 — Recurring Rules UI
- **Red**: list (grouped, human-readable freq, pause toggle) + form (kind, frequency slider, escalation, dates)
- **Green**: `lib/features/recurring/{screens,providers}/`
- **Depends on**: 4.1

### 4.3 — 60-Month Projection Engine
- **Red**: `test/core/financial/projection_engine_test.dart` — salary+hikes, expense escalation, deficit handling, investment drawdown, 3 scenarios, loan EMI cessation
- **Green**: `lib/core/financial/projection_engine.dart`
- **Depends on**: 1.3, 1.4, 4.1

### 4.4 — Projection UI
- **Red**: line chart (60mo), scenario toggle, data table, deficit warning, adaptive layout
- **Green**: `lib/features/projections/{screens,providers,widgets}/`
- **Depends on**: 4.3

### 4.5 — Investment Holdings (Bucket-Based)
- **Red**: DAO (CRUD, bucket types, portfolio sum) + baselines (lookup priority, defaults, normalization) + UI (summary, bucket cards, linked goals)
- **Green**: `lib/core/database/{tables/investment_holdings,daos/investment_dao}.dart`, `lib/core/financial/investment_baselines.dart`, `lib/features/investments/{screens,providers}/`
- **Depends on**: 1.6, 2.6

### 4.6 — Statement Import Parsers
- **Red**: `test/core/imports/{hdfc,sbi,icici,csv}_parser_test.dart` + dedup + normalizer — against real anonymized fixtures
- **Green**: `lib/core/imports/{statement_parser,hdfc_parser,sbi_parser,icici_parser,csv_parser,transaction_normalizer,dedup}.dart`
- Test fixtures in `test/fixtures/`

### 4.7 — Statement Import UI
- **Red**: wizard flow (file pick -> preview -> categorize -> commit), duplicate warning, adaptive layout
- **Green**: `lib/features/imports/{screens,providers,widgets}/`
- **Depends on**: 4.6, 2.4

### 4.8 — Balance Reconciliation
- **Red**: sum transactions vs stored balance, log discrepancy, create snapshot
- **Green**: `lib/core/financial/balance_reconciliation.dart`

### 4.9 — Planning Insights
- **Red**: 3-month budget drift (mild/moderate/severe), at-risk goal flags
- **Green**: `lib/core/financial/planning_insights.dart`
- **Depends on**: 2.5, 2.6

### 4.10 — Scenario Sandbox
- **Red**: DAO (scenarios + changes), engine (overlay on projection), UI (builder, preview, accept)
- **Green**: `lib/core/database/{tables,daos}/scenario*.dart`, `lib/core/financial/scenario_engine.dart`, `lib/features/projections/screens/scenario_screen.dart`
- **Depends on**: 4.3

### 4.11 — Vault, Milestones, Notifications Tables
- **Red**: CRUD + search (vault), progress + crossed detection (milestones), prefs (notifications)
- **Green**: `lib/core/database/{tables,daos}/{vault,milestone,notification_prefs}*.dart`

### 4.12 — Data Migration (Storely Import)
- **Red**: pg_dump COPY parser, type conversions, dependency ordering, row count verification
- **Green**: `lib/core/migration/{pg_dump_parser,migration_orchestrator}.dart`
- Fixture: `test/fixtures/storely_sample.sql`

### Phase 4 Parallelization
4.1/4.2, 4.5, 4.6/4.7, 4.8, 4.9, 4.11, 4.12 are all independent. 4.3 needs 4.1. 4.10 needs 4.3.

### Phase 4 Exit Criteria
- Recurring rules generate transactions idempotently
- 60-month projection with 3 scenarios
- Statement import with dedup
- 90%+ coverage on `core/financial/`, `core/imports/`

---

## Phase 5: Polish + Distribution (Weeks 12-14)

### 5.1 — Onboarding Flow
- Sign-In → Create/Join Family → Passphrase → Optional Migration → Dashboard

### 5.2 — Family Management UI
- Member list, role management, invite instructions

### 5.3 — Settings Screen
- Theme, sync status, passphrase change, manual backup, about

### 5.4 — Accessibility
- Semantic labels, dynamic type, WCAG AA contrast, screen reader tests

### 5.5 — Edge Case & Integration Tests
- Offline sync round-trip, cascade integrity (account→txn→budget→dashboard), 10k transaction performance

### 5.6 — CI/CD Pipeline
- `.github/workflows/ci.yml` (analyze, test, build on PR)
- `.github/workflows/release.yml` (Fastlane → App Store, Play Store, Mac App Store)

### Phase 5 Exit Criteria
- Full onboarding flow functional
- CI green on all platforms
- Accessibility audit passing

---

## Key Architectural Decisions

1. **Sync changelog trigger**: Use a DAO mixin that auto-inserts changelog entries on every write — prevents forgotten entries
2. **Provider convention**: StreamProvider (DB entities), FutureProvider (computations), StateNotifierProvider (UI state)
3. **Balance atomicity**: All balance updates inside `database.transaction()` — especially TRANSFER two-step
4. **Test DB strategy**: drift `NativeDatabase.memory()` for unit/widget tests; SQLCipher for integration tests only

---

## Verification Strategy

| Domain | Method |
|--------|--------|
| Financial math | Exact integer assertions against Excel reference values |
| Encryption | Round-trip tests; verify non-deterministic ciphertext (random IV) |
| Sync | Two mock devices, both edit offline, reconnect, verify consistency |
| Adaptive layout | Widget tests at 3 breakpoints: 400dp, 750dp, 1200dp |
| Cascade integrity | Create/edit/delete chain verifying balance→budget→dashboard consistency |
| Performance | 10k transaction insert → dashboard < 2s |
| Security | SQLCipher DB unreadable without passphrase; Drive files are opaque |
