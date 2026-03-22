# Vael — TDD Implementation Roadmap

## Context

Vael is a greenfield Flutter family finance app being ported from a Java/PostgreSQL monolith to a local-first, zero-server native app. This roadmap implements the full app using strict TDD (Red-Green-Refactor) across 5 phases, ~14 weeks.

**Governing docs**: `docs/INTENT.md` (constitutional), `docs/ARCHITECTURE.md`, `docs/DATA_MODEL.md`, `docs/ENCRYPTION.md`, `docs/SYNC.md`, `docs/UI_DESIGN.md`
**Extension plans**: `docs/EXTENSION_PLAN_FINANCIAL_PLANNING.md` (Phases 6-8)

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

## Phase 2: Core Features (Weeks 3-5) — COMPLETE ✅

> **293 tests, all green. Committed: 318f93a**

### 2.1 — Riverpod Provider Architecture ✅ (11 tests)
- **Red**: `test/core/providers/account_providers_test.dart` — stream from DAO, rebuild on change, netWorthProvider filters by visibility
- **Green**: `lib/core/providers/{account,database}_providers.dart`
- Established convention: StreamProvider for DB entities, FutureProvider for one-shot computations
- **Depends on**: 1.6

### 2.2 — Dashboard Aggregation Logic ✅ (16 tests)
- **Red**: `test/core/financial/dashboard_aggregation_test.dart` — net worth (assets-liabilities-CC), account grouping, family vs personal scope, monthly summary
- **Red**: `test/features/dashboard/dashboard_providers_test.dart` — combined provider, scope toggle
- **Green**: `lib/core/financial/dashboard_aggregation.dart`, `lib/features/dashboard/providers/dashboard_providers.dart`
- **Depends on**: 1.7, 2.1

### 2.3 — Account CRUD UI ✅ (13 tests)
- **Red**: `test/features/accounts/{account_list_screen,account_form}_test.dart` — grouped list, balance formatting, visibility badge, form validation, CRUD
- **Green**: `lib/features/accounts/{screens,providers}/`
- Extracted `lib/shared/widgets/currency_input.dart` for reuse
- **Depends on**: 2.1, 1.9

### 2.4 — Transaction CRUD UI ✅ (25 tests)
- **Red**: `test/features/transactions/{transaction_list,transaction_form,transaction_cascade}_test.dart` — kind selector, TRANSFER dual-picker, cascade tests (create → balance updates), Indian number formatting
- **Green**: `lib/features/transactions/{screens,providers}/`
- **Depends on**: 2.1, 2.3, 1.7

### 2.5 — Budget Logic and UI ✅ (20 tests)
- **Red**: `test/core/financial/budget_summary_test.dart` (9) — actuals by group, remaining/overspent, unbudgeted groups, expense-only filter, shared-accounts-only, MISSING group for uncategorized
- **Red**: `test/core/database/daos/budget_dao_test.dart` (5) — CRUD, month filtering, family isolation
- **Red**: `test/features/budgets/budget_screen_test.dart` (6) — groups with bars, overspent highlighting, Indian notation, empty state
- **Green**: `lib/core/financial/budget_summary.dart`, `lib/features/budgets/{screens,providers}/`, `lib/core/database/{daos/budget_dao,tables/budgets}.dart`
- Schema bumped to v3
- **Depends on**: 2.4, 1.6

### 2.6 — Goals Logic and DAO ✅ (21 tests)
- **Red**: `test/core/financial/goal_tracking_test.dart` (15) — inflation-adjusted target, required SIP, status inference (active/onTrack/atRisk/completed)
- **Red**: `test/core/database/daos/goal_dao_test.dart` (6) — CRUD, status filtering, progress updates
- **Green**: `lib/core/financial/goal_tracking.dart`, `lib/core/database/{daos/goal_dao,tables/goals}.dart`
- Schema bumped to v2
- **Depends on**: 1.3, 2.1

### 2.7 — Loan Detail and Amortization UI ✅ (14 tests)
- **Red**: `test/core/database/daos/loan_dao_test.dart` (5) — CRUD, outstanding update, family isolation
- **Red**: `test/features/loans/loan_detail_test.dart` (5) — summary card, EMI split bar, amortization table, not-found state, remaining tenure
- **Red**: `test/features/loans/prepayment_simulation_test.dart` (4) — tenure reduction, interest saved, zero prepayment no-op, early > late savings
- **Green**: `lib/features/loans/{screens,providers}/`, `lib/core/database/{daos/loan_dao,tables/loan_details}.dart`
- Schema bumped to v4
- **Depends on**: 1.4, 2.4

### 2.8 — Dashboard UI ✅ (8 tests)
- **Red**: `test/features/dashboard/dashboard_screen_test.dart` — net worth card (signed, colored), monthly summary (income/expenses/net savings), goals section with progress bars, scope toggle (Family/Personal), negative net worth in red, hidden goals when empty
- **Green**: `lib/features/dashboard/screens/dashboard_screen.dart`
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

### Phase 2 Exit Criteria ✅
- All core screens functional on phone + tablet layouts
- Transaction cascade verified end-to-end (7 cascade tests)
- 90%+ coverage on `core/financial/`

### Phase 2 Retroactive E2E Simulator Tests

> Gaps identified against existing E2E coverage (29 feature + 23 journey tests). These fill missing CRUD editing/deletion, Goals, and Loans flows.

**2.E2E.1 — Goals Flow** (~4 tests)
- `integration_test/goals_flow_test.dart`
  - Create goal via form (name, target amount, target date) → verify list display
  - Goal progress: seed goal with linked SIP transactions → verify progress bar and status (ON_TRACK/AT_RISK)
  - Edit goal: modify target amount → verify recalculated required SIP
  - Goal completion: seed goal at 100%+ → verify COMPLETED status badge
- Both iPhone + iPad Pro

**2.E2E.2 — Account Edit + Delete Flow** (~3 tests)
- `integration_test/account_edit_delete_test.dart`
  - Edit account: tap existing account → modify name → save → verify updated name in list
  - Soft delete account: delete → verify removed from list, balance excluded from net worth
  - Account type variety: create wallet, credit card, investment accounts → verify type icons
- Both iPhone + iPad Pro

**2.E2E.3 — Transaction Edit + Delete Journey** (~3 tests)
- `integration_test/journey_transaction_edit_delete_test.dart`
  - Edit transaction amount → verify account balance recalculated (old amount reversed, new applied)
  - Delete transaction → verify balance cascade reversal on Accounts and Dashboard
  - Transfer edit: modify transfer amount → verify both accounts updated
- Both iPhone + iPad Pro

**2.E2E.4 — Loan Detail + Amortization Journey** (~3 tests)
- `integration_test/journey_loan_detail_test.dart`
  - View amortization table for seeded loan → verify EMI split display (principal vs interest)
  - Prepayment simulation: enter prepayment amount → verify interest saved + tenure reduction
  - Loan summary card: outstanding principal, rate, remaining tenure
- Both iPhone + iPad Pro
- *(Previously deferred from Phase 3 simulator tests)*

**2.E2E.5 — Form Validation** (~3 tests)
- `integration_test/form_validation_test.dart`
  - Account form: submit empty name → verify error message
  - Transaction form: submit zero amount → verify validation error
  - Budget form: submit negative limit → verify rejection
- Both iPhone + iPad Pro

---

## Phase 2.5: UX Implementation (Week 5.5-6)

> **Implements `docs/UI_DESIGN.md` design system. Target: ~395 tests.**

Bridges the gap between Phase 2's functional-but-stock-M3 screens and the full design spec in `docs/UI_DESIGN.md`. All future UI work (Phases 3-5) inherits the design system established here.

### Wave 1: Design System Foundation

**2.5.1 — Semantic ColorTokens (dark-aware)** (~8 tests)
- **Red**: `test/shared/theme/color_tokens_test.dart` — light/dark return correct hex, WCAG AA contrast on all text/surface pairs, regression on old statics
- **Green**: `lib/shared/theme/color_tokens.dart` — `ColorTokens.of(BuildContext)` returning full token set from `UI_DESIGN.md` §1.1 (surface, text, semantic, action, chart tokens)
- Keep existing `static const` fields as deprecated aliases for backward compat

**2.5.2 — Inter Font + Card Style + Spacing Tokens** (~8 tests)
- **Red**: `test/shared/theme/app_theme_test.dart` — font family, tabular figures, card radius 12, spacing values
- **Green**: `lib/shared/theme/app_theme.dart` (updated), NEW `lib/shared/theme/text_styles.dart`, NEW `lib/shared/theme/spacing.dart`
- Add `google_fonts` to pubspec. Inter type scale from `UI_DESIGN.md` §1.3, spacing/radius from §1.4
- Card: 12dp radius, `surfaceContainer` fill, `outline` border, no shadows

**2.5.3 — Dark Mode Wiring** (~3 tests)
- **Red**: `test/app_test.dart` — uses AppTheme.light(), AppTheme.dark(), ThemeMode.system
- **Green**: `lib/app.dart` — wire themes, integrate AdaptiveScaffold as home
- **Depends on**: 2.5.1, 2.5.2

**2.5.4 — 5-Item Bottom Nav** (~4 tests, updates existing)
- **Red**: Update `test/shared/layout/adaptive_scaffold_test.dart` — 5 items, Settings absent
- **Green**: `lib/shared/layout/adaptive_scaffold.dart` — remove Settings destination, add AppBar gear icon
- **Depends on**: 2.5.3

**2.5.5 — Skeleton Loading Widget** (~4 tests)
- **Red**: `test/shared/widgets/skeleton_loading_test.dart` — renders, dimensions, theme color, animation
- **Green**: NEW `lib/shared/widgets/skeleton_loading.dart` — `SkeletonBox` + `SkeletonCard` with shimmer (1500ms linear loop per spec §1.5)

### Wave 2: Dashboard Redesign

**2.5.6 — BalanceSnapshotDao + Net Worth History** (~8 tests)
- **Red**: `test/core/database/daos/balance_snapshot_dao_test.dart`, `test/core/financial/dashboard_aggregation_test.dart` (additions)
- **Green**: NEW `lib/core/database/daos/balance_snapshot_dao.dart`, `lib/core/financial/dashboard_aggregation.dart` (add `computeNetWorthHistory()`)
- **Depends on**: 1.5

**2.5.7 — Expanded DashboardData + Savings Rate** (~5 tests)
- **Red**: `test/features/dashboard/dashboard_providers_test.dart` (additions) — savings rate edge cases, new fields
- **Green**: `lib/features/dashboard/providers/dashboard_providers.dart`, `lib/core/financial/dashboard_aggregation.dart` (add `computeSavingsRate()`)
- **Depends on**: 2.5.6

**2.5.8 — Hero Net Worth Card** (~4 tests)
- **Red**: `test/features/dashboard/dashboard_screen_test.dart` (updates) — large amount, delta display
- **Green**: `lib/features/dashboard/screens/dashboard_screen.dart` — hero layout per `UI_DESIGN.md` §2.2
- **Depends on**: 2.5.7, 2.5.1

**2.5.9 — Compact Income/Expense Tiles** (~3 tests)
- Replace `_MonthlySummaryCard` with side-by-side `Row` of three compact cards
- **Depends on**: 2.5.8

**2.5.10 — Quick Actions Row** (~3 tests)
- "Add Transaction" and "View Accounts" tonal buttons on dashboard
- **Depends on**: 2.5.8

**2.5.11 — Savings Rate Badge** (~3 tests)
- Chip: green ≥20%, amber 10-20%, red <10%
- **Depends on**: 2.5.7

**2.5.12 — Net Worth Trend Line Chart** (~4 tests)
- **Red**: `test/features/dashboard/net_worth_chart_test.dart`
- **Green**: NEW `lib/features/dashboard/widgets/net_worth_chart.dart` — fl_chart `LineChart`, 6 months, chart tokens from spec
- **Depends on**: 2.5.7

### Wave 3: Screen Improvements

**2.5.13 — Transaction List Grouping + Search + Filters** (~10 tests)
- **Red**: `test/core/financial/transaction_grouping_test.dart`, `test/features/transactions/transaction_list_screen_test.dart` (updates)
- **Green**: NEW `lib/core/financial/transaction_grouping.dart`, `lib/features/transactions/screens/transaction_list_screen.dart` (updated)
- Groups: "Today", "Yesterday", "dd MMM". Provider-level grouping. SearchBar + FilterChips.
- **Depends on**: 2.5.1

**2.5.14 — Budget Screen Interactivity** (~6 tests)
- **Green**: `lib/features/budgets/screens/budget_screen.dart` (updated), NEW `lib/features/budgets/screens/budget_form_screen.dart`
- FAB to create, tappable cards to edit, remaining amount display
- **Depends on**: 2.5.1

**2.5.15 — Budget Donut Chart** (~4 tests)
- **Green**: NEW `lib/features/budgets/widgets/budget_donut_chart.dart` — fl_chart `PieChart` per category group
- **Depends on**: 2.5.14

**2.5.16 — Account Type Icons + Balance Coloring** (~5 tests)
- **Green**: `lib/features/accounts/screens/account_list_screen.dart` (updated), NEW `lib/shared/utils/account_icons.dart`
- Icons per type, balance red for liabilities
- **Depends on**: 2.5.1

**2.5.17 — Amortization Table Pagination** (~4 tests)
- Show first 12 rows, "Show More" to expand
- **Depends on**: 2.5.1

### Wave 4: Polish

**2.5.18 — Card Tap Feedback + Navigation** (~3 tests)
- InkWell on all dashboard cards, navigate to detail screens

**2.5.19 — Standardized Empty States** (~4 tests)
- NEW `lib/shared/widgets/empty_state.dart` — reusable across all screens

**2.5.20 — Pull-to-Refresh** (~3 tests)
- RefreshIndicator on all list screens, `ref.invalidate()` on refresh

**2.5.21 — Page Transitions** (~2 tests)
- NEW `lib/shared/layout/page_transitions.dart` — 300ms easeInOutCubic per spec §1.5

**2.5.22 — Live Currency Formatting** (~4 tests)
- Update `lib/shared/widgets/currency_input.dart` — Indian comma formatting as user types

### Phase 2.5 Exit Criteria
- All ~395 tests green
- Widget tests at 3 breakpoints (400dp, 750dp, 1200dp)
- WCAG AA contrast verified for all dark-mode token pairs
- Dashboard matches `UI_DESIGN.md` §2.2 wireframe
- No regressions on Phase 2 screens

### Phase 2.5 Retroactive E2E Simulator Tests

> Design system and UX improvements that are testable via simulator.

**2.5.E2E.1 — Dark Mode Toggle** (~3 tests)
- `integration_test/dark_mode_flow_test.dart`
  - Toggle dark mode via Settings gear → verify background color changes to dark surface
  - Verify amount colors (green/red) render correctly in dark mode
  - Toggle back to light → verify restoration
- Both iPhone + iPad Pro

**2.5.E2E.2 — Dashboard Chart + Savings Rate** (~3 tests)
- `integration_test/journey_dashboard_charts_test.dart`
  - Seed 6 months of balance snapshots → navigate to Dashboard → verify net worth chart widget renders (LineChart present)
  - Savings rate badge: seed income ₹1L, expenses ₹60K → verify green badge (40%)
  - Savings rate warning: seed income ₹1L, expenses ₹95K → verify red badge (5%)
- Both iPhone + iPad Pro

**2.5.E2E.3 — Transaction Search + Filters** (~3 tests)
- `integration_test/transaction_filter_test.dart`
  - Seed 10 transactions with varied kinds → search by description text → verify filtered results
  - Filter by kind (EXPENSE only) → verify only expense transactions visible
  - Clear filter → verify all transactions return
- Both iPhone + iPad Pro

**2.5.E2E.4 — Empty States + Pull-to-Refresh** (~3 tests)
- `integration_test/empty_state_refresh_test.dart`
  - Fresh app with no data → verify EmptyState widget on each tab (Accounts, Transactions, Budget)
  - Add account → pull-to-refresh on Accounts tab → verify account still present (no data loss)
  - Empty budget tab → verify CTA button navigates to budget form
- Both iPhone + iPad Pro

**2.5.E2E.5 — Adaptive Layout Breakpoints** (~3 tests)
- `integration_test/adaptive_layout_test.dart`
  - Phone size (400dp): verify BottomNavigationBar visible, no NavigationRail
  - Tablet size (iPad Pro): verify NavigationRail visible, no BottomNavigationBar
  - Verify Settings gear icon accessible on both layouts
- iPhone + iPad Pro (validates the breakpoint difference)

### Cross-Phase Design System Directive

**All future UI work (Phases 3-5) MUST use the design system from this phase:**
- Color: `ColorTokens.of(context)` — never raw hex in widgets
- Typography: Inter font, spec type scale, tabular figures for money
- Cards: 12dp radius, surfaceContainer fill, outline border, no shadows
- Spacing: `Spacing.xs/sm/md/lg/xl/xxl` constants
- Loading: Shimmer skeletons via `SkeletonBox`/`SkeletonCard`, never spinners
- Empty: `EmptyState` widget, never bare text
- Nav: 5-item adaptive scaffold + AppBar actions for overflow

---

## Phase 3: Encryption + Sync (Weeks 6-8)

> **Note**: All UI screens in this phase (3.5, 3.16) use the design system from Phase 2.5.

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

### Phase 3 + 3.5 Retroactive E2E Simulator Tests

> Crypto internals are unit-tested. E2E tests here cover the UI-facing flows: passphrase setup, sync status, and admin backup dashboard.

**3.E2E.1 — Passphrase Setup Flow** (~3 tests)
- `integration_test/passphrase_setup_test.dart`
  - Enter passphrase + confirm → verify success indicator and navigation to next step
  - Mismatched passphrase confirmation → verify error message
  - Passphrase visibility toggle (eye icon) → verify text obscured/revealed
- Both iPhone + iPad Pro

**3.E2E.2 — Sync Status Screen** (~3 tests)
- `integration_test/sync_status_test.dart`
  - Navigate to Settings → Sync Status → verify device ID, last sync timestamp display
  - Pending changes indicator: seed unsynced changelog entries → verify pending count shown
  - Manual sync button: tap → verify loading state appears
- Both iPhone + iPad Pro

**3.E2E.3 — Passphrase Change Flow** (~2 tests)
- `integration_test/passphrase_change_test.dart`
  - Enter current passphrase → enter new → confirm → verify success
  - Wrong current passphrase → verify error message
- Both iPhone + iPad Pro

**3.5.E2E.1 — Admin Backup Dashboard** (~3 tests)
- `integration_test/admin_backup_dashboard_test.dart`
  - Admin views member list → verify member names, roles, sync status columns
  - Remove member: tap remove → confirm dialog → verify member removed from list
  - Ownership transfer: tap transfer → confirm → verify role swap in UI
- Both iPhone + iPad Pro
- **Note**: Requires mock Drive permission service (no real Google Drive in simulator)

**3.5.E2E.2 — Member Invite + Join Journey** (~2 tests)
- `integration_test/journey_member_invite_test.dart`
  - Admin enters member email → verify invite sent confirmation
  - New member enters passphrase → verify FEK unwrap success → data loads
- Both iPhone + iPad Pro

---

## Phase 4: Advanced Features (Weeks 9-11)

> **Note**: All UI screens in this phase (4.2, 4.4, 4.5, 4.7, 4.10) use the design system from Phase 2.5. Follow `UI_DESIGN.md` wireframes with established tokens.

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

### Phase 4 E2E Simulator Tests

> Extends `SimulatorTestApp` and `e2e_helpers.dart`. All tests run on both iPhone and iPad Pro. Add new seed helpers as needed (e.g., `seedRecurringRule`, `seedInvestmentHolding`, `seedScenario`).

**4.E2E.1 — Recurring Rules Flow** (~5 tests)
- `integration_test/recurring_flow_test.dart`
  - Create recurring rule via form (monthly salary, ₹50,000)
  - Verify rule appears in list with human-readable frequency
  - Pause toggle: tap pause → verify visual state change
  - Trigger engine manually → verify generated transaction appears in Transactions tab
  - Escalation: create rule with 10% annual escalation → verify next-year amount
- **Depends on**: 4.2

**4.E2E.2 — Projection & Scenario Journey** (~4 tests)
- `integration_test/journey_projection_test.dart`
  - Seed salary income + expense rules + loan → navigate to Projections → verify 60-month chart renders
  - Toggle between Conservative/Moderate/Aggressive → verify chart updates with different endpoint values
  - Deficit warning: seed scenario where expenses exceed income at month 36 → verify deficit badge
  - Scenario sandbox: create "Buy Car" scenario → overlay on projection → verify divergence point
- **Depends on**: 4.4, 4.10

**4.E2E.3 — Investment Holdings Flow** (~4 tests)
- `integration_test/investment_flow_test.dart`
  - Create investment holding (PPF bucket, ₹5,00,000)
  - Verify portfolio summary displays correct total
  - Edit holding: update value → verify summary recalculates
  - Link investment to goal → verify linked goal badge on investment card
- **Depends on**: 4.5

**4.E2E.4 — Statement Import Journey** (~4 tests)
- `integration_test/journey_import_test.dart`
  - Load fixture CSV → preview screen shows correct row count and parsed amounts
  - Categorize: assign category to uncategorized row → verify category chip updates
  - Commit: import transactions → navigate to Transactions tab → verify imported rows appear
  - Duplicate detection: re-import same file → verify duplicate warning with skip option
- **Depends on**: 4.7

**4.E2E.5 — Planning Insights + Reconciliation Journey** (~4 tests)
- `integration_test/journey_planning_insights_test.dart`
  - Seed 3 months of overspent budgets → navigate to insights → verify "severe drift" badge
  - Seed at-risk goal (behind SIP schedule) → verify at-risk flag on dashboard
  - Balance reconciliation: seed account with mismatched balance vs txn sum → trigger reconciliation → verify discrepancy logged and snapshot created
  - Post-reconciliation: verify corrected balance on Accounts screen
- **Depends on**: 4.8, 4.9

**4.E2E.6 — Cross-Feature Consistency: Recurring → Projection → Budget** (~3 tests)
- `integration_test/journey_recurring_projection_test.dart`
  - Create recurring expense rule → run engine → verify new transactions cascade to budget actuals
  - Navigate to Projections → verify recurring rules reflected in 60-month forecast
  - Modify recurring rule amount → re-run → verify projection chart updates accordingly
- **Depends on**: 4.2, 4.4

### Phase 4 Parallelization
4.1/4.2, 4.5, 4.6/4.7, 4.8, 4.9, 4.11, 4.12 are all independent. 4.3 needs 4.1. 4.10 needs 4.3.
E2E tests run after their feature dependencies: 4.E2E.1 after 4.2; 4.E2E.2 after 4.4+4.10; 4.E2E.3 after 4.5; 4.E2E.4 after 4.7; 4.E2E.5 after 4.8+4.9; 4.E2E.6 after 4.2+4.4.

### Phase 4 Exit Criteria
- Recurring rules generate transactions idempotently
- 60-month projection with 3 scenarios
- Statement import with dedup
- 90%+ coverage on `core/financial/`, `core/imports/`
- All E2E simulator tests green on both iPhone and iPad Pro
- Cross-feature cascade verified: recurring rule → transaction → budget → projection pipeline

---

## Phase 5: Polish + Distribution (Weeks 12-14)

> **Note**: All UI screens use the design system from Phase 2.5. WCAG AA contrast already verified by Phase 2.5 color token tests. Theme toggle already wired.

### 5.1 — Onboarding Flow
- Sign-In → Create/Join Family → Passphrase → Optional Migration → Dashboard
- Use `EmptyState`, `SkeletonBox`, design system cards/spacing

### 5.2 — Family Management UI
- Member list, role management, invite instructions

### 5.3 — Settings Screen
- Theme toggle (already wired in 2.5.3), sync status, passphrase change, manual backup, about

### 5.4 — Accessibility
- Semantic labels, dynamic type, screen reader tests (WCAG AA contrast already covered by Phase 2.5)

### 5.5 — Edge Case & Integration Tests
- Offline sync round-trip, cascade integrity (account→txn→budget→dashboard), 10k transaction performance

### 5.6 — CI/CD Pipeline
- `.github/workflows/ci.yml` (analyze, test, build on PR)
- `.github/workflows/release.yml` (Fastlane → App Store, Play Store, Mac App Store)

### Phase 5 E2E Simulator Tests

> Final E2E layer — validates end-to-end user journeys that span the entire app lifecycle. Extends SimulatorTestApp with onboarding/settings screens. All tests run on both iPhone and iPad Pro.

**5.E2E.1 — Onboarding Journey** (~5 tests)
- `integration_test/journey_onboarding_test.dart`
  - Fresh app launch → onboarding screen appears (not dashboard)
  - Sign-In → Create Family → set passphrase → arrives at empty dashboard
  - Join Family flow: enter passphrase → FEK unwraps → data loads on dashboard
  - Optional migration: select Storely import during onboarding → verify data appears post-import
  - Back navigation: pressing back from passphrase returns to family selection (no data loss)
- Both iPhone + iPad Pro
- **Depends on**: 5.1

**5.E2E.2 — Settings & Family Management Flow** (~4 tests)
- `integration_test/settings_flow_test.dart`
  - Navigate to Settings via gear icon → verify all sections render (theme, sync, passphrase, about)
  - Theme toggle: switch dark → verify dark mode activates immediately
  - Passphrase change: enter old → new → confirm → verify success feedback
  - Family management: view member list → verify roles displayed → navigate back
- Both iPhone + iPad Pro
- **Depends on**: 5.2, 5.3

**5.E2E.3 — Full App Lifecycle Journey** (~4 tests)
- `integration_test/journey_full_lifecycle_test.dart`
  - Golden path: seed family → add accounts → add transactions → set budget → create goal → create recurring rule → view projection → verify all screens consistent
  - Deletion cascade: delete an account → verify transactions removed from list, budget actuals updated, dashboard net worth recalculated
  - 100-transaction stress: seed 100 transactions → navigate all tabs → verify no crashes, dashboard loads within 3s
  - Multi-tab consistency: add transaction on Transactions tab → immediately switch to Dashboard → verify net worth updated without refresh
- Both iPhone + iPad Pro
- **Depends on**: all prior phases

**5.E2E.4 — Accessibility E2E** (~3 tests)
- `integration_test/accessibility_test.dart`
  - All interactive elements have semantic labels (check via `find.bySemanticsLabel`)
  - Money amounts use `liveRegion` semantics for screen reader announcements
  - Tab navigation order follows visual layout (Dashboard → Accounts → Transactions → Budget → Goals)
- Both iPhone + iPad Pro
- **Depends on**: 5.4

### Phase 5 Exit Criteria
- Full onboarding flow functional
- CI green on all platforms
- Accessibility audit passing
- All E2E simulator tests green: onboarding journey, settings flow, full lifecycle, accessibility
- Total E2E test count target: ~110+ across all phases (52 existing + ~16 Phase 2 retro + ~15 Phase 2.5 retro + ~13 Phase 3/3.5 retro + ~24 Phase 4 + ~16 Phase 5)

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
| E2E feature flows | Simulator tests on both iPhone + iPad Pro — per-screen CRUD, navigation, form validation |
| E2E journey tests | Simulator tests on both iPhone + iPad Pro — cross-feature cascades, multi-tab consistency |
| E2E lifecycle | Full app lifecycle on both devices: onboarding → daily use → data integrity across all features |
