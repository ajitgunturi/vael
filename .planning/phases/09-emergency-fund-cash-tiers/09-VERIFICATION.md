---
phase: 09-emergency-fund-cash-tiers
verified: 2026-03-24T00:00:00Z
status: gaps_found
score: 9/11 must-haves verified
gaps:
  - truth: "Given a group-keyed actuals map from BudgetSummary, the engine correctly filters only essential groups by string key"
    status: failed
    reason: "EmergencyFundEngine.essentialGroups uses camelCase keys ('essential', 'homeExpenses', 'livingExpense') but BudgetSummary.computeActualsByGroup produces uppercase slug keys ('ESSENTIAL', 'HOME_EXPENSES', 'LIVING_EXPENSE') from actual DB category records seeded by CategorySeeder. The unit tests use hand-crafted camelCase maps that do not reflect real DB output, so tests pass but runtime will return 0 for monthly essential average."
    artifacts:
      - path: "lib/core/financial/emergency_fund_engine.dart"
        issue: "essentialGroups set contains {'essential', 'homeExpenses', 'livingExpense'} (camelCase enum .name values) but actual category groupName DB values are 'ESSENTIAL', 'HOME_EXPENSES', 'LIVING_EXPENSE'"
      - path: "test/core/financial/emergency_fund_engine_test.dart"
        issue: "String key contract test uses CategoryGroup.name enum values (camelCase) not actual DB slug values — test validates wrong format"
    missing:
      - "Either update EmergencyFundEngine.essentialGroups to {'ESSENTIAL', 'HOME_EXPENSES', 'LIVING_EXPENSE'} to match DB category slugs, OR add a normalization step in monthlyEssentialsProvider before passing actuals to engine"
      - "Update the string key contract test to validate against actual DB slugs emitted by BudgetSummary.computeActualsByGroup"
  - truth: "User can see aggregate balance by tier with weighted-average interest rate (TIER-02)"
    status: partial
    reason: "TIER-02 in REQUIREMENTS.md requires 'aggregate balance by tier WITH weighted-average interest rate' but implementation delivers balance-only aggregation. The plan explicitly scoped out interest rate display due to no interestRateBp column. This is a documented intentional scope reduction but the requirement text is not satisfied as written."
    artifacts:
      - path: "lib/features/planning/providers/emergency_fund_provider.dart"
        issue: "tierSummaryProvider computes balance-only {tier: totalBalancePaise} — no interest rate"
      - path: "lib/features/planning/screens/emergency_fund_screen.dart"
        issue: "Tier summary section shows balance and account count but no weighted-average interest rate"
    missing:
      - "Either add interestRateBp column to accounts table and implement weighted-average computation, OR update REQUIREMENTS.md TIER-02 to reflect the approved scope reduction"
human_verification:
  - test: "Verify EF coverage ring displays correctly with real transaction data"
    expected: "Ring shows accurate X.X/Y months with correct color coding (green >= 90%, amber >= 50%, red < 50%)"
    why_human: "The string key mismatch bug means coverage will show 0.0 months until fixed — human confirmation needed after fix is applied"
  - test: "Navigate to EF screen from Settings > Financial Planning > Emergency Fund tile"
    expected: "Screen opens showing 4 sections: progress ring, target config, linked accounts, tier summary"
    why_human: "Navigation flow requires live app testing"
  - test: "Toggle an account as EF-backing via bottom sheet checkboxes"
    expected: "Account appears in Linked Accounts section with balance contributing to coverage"
    why_human: "Requires live DB write and reactive stream re-render"
---

# Phase 9: Emergency Fund & Cash Tiers Verification Report

**Phase Goal:** User has complete safety-net visibility — emergency fund coverage, account liquidity classification, and opportunity fund tracking
**Verified:** 2026-03-24
**Status:** gaps_found
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|---------|
| 1 | Engine returns correct monthly average in paise from 6 months of essential expenses | ✓ VERIFIED | `EmergencyFundEngine.monthlyEssentialAverage` implemented and 26 unit tests passing |
| 2 | Engine returns appropriate target months (3/6/9/12) from income stability type | ✓ VERIFIED | `suggestedTargetMonths` switch returns 3/6/9/12 per stability string |
| 3 | Engine correctly filters essential groups by string key (string key contract) | ✗ FAILED | Engine uses camelCase `{'essential', 'homeExpenses', 'livingExpense'}` but DB emits uppercase slugs `'ESSENTIAL'`, `'HOME_EXPENSES'`, `'LIVING_EXPENSE'` — runtime EF coverage will always compute 0 |
| 4 | Accounts can be flagged as EF and assigned a liquidity tier | ✓ VERIFIED | `setEmergencyFund` and `setLiquidityTier` DAO methods wired to CheckboxListTile and tier dialog in screen |
| 5 | Schema migrates from v11 to v12 adding 4 new columns without data loss | ✓ VERIFIED | `database.dart` schemaVersion 12 with `if (from < 12)` block adding all 4 columns |
| 6 | User can see EF progress ring with coverage months and color coding | ✓ VERIFIED | `EfProgressRing` widget with green/amber/red color logic; used in `EmergencyFundScreen` Section A |
| 7 | User can toggle accounts as EF-backing via multi-select | ✓ VERIFIED | `_AccountSelectorSheet` with `CheckboxListTile` calling `setEmergencyFund` |
| 8 | User can see and override target months with auto-suggested value shown | ✓ VERIFIED | Section B target config with +/- buttons, `DropdownButtonFormField` for income stability, Save persists to life profile |
| 9 | User can see aggregate balance by liquidity tier | ⚠️ PARTIAL | Balance aggregation works; interest rate display (required by TIER-02 text) intentionally deferred with no schema column |
| 10 | Account detail shows EF badge and tier chip tappable to EF screen | ✓ VERIFIED | `EfBadge` + `LiquidityTierChip` in `_AccountSummaryCard`, `onTap` navigates to `EmergencyFundScreen` |
| 11 | Budget essential row shows coverage subtitle and navigates to EF screen | ✓ VERIFIED | `BudgetScreen` watches `emergencyFundStateProvider`, `isEssential = row.categoryGroup == 'ESSENTIAL'`, `GestureDetector` navigates to `EmergencyFundScreen` |

**Score:** 9/11 truths verified (1 failed — string key mismatch; 1 partial — TIER-02 interest rate)

---

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `lib/core/financial/emergency_fund_engine.dart` | Pure static computation engine | ✓ VERIFIED | 89 lines, private constructor, no DB imports, all 6 methods |
| `test/core/financial/emergency_fund_engine_test.dart` | Unit tests >= 15 cases | ✓ VERIFIED | 215 lines, 26 test() cases |
| `lib/core/models/enums.dart` | LiquidityTier and IncomeStability enums | ✓ VERIFIED | Both enums at lines 78-86 |
| `lib/core/database/tables/accounts.dart` | liquidityTier + isEmergencyFund columns | ✓ VERIFIED | Lines 20-22 |
| `lib/core/database/tables/life_profiles.dart` | incomeStability + efTargetMonthsOverride columns | ✓ VERIFIED | Lines 22-24 |
| `lib/core/database/database.dart` | Schema v12 migration | ✓ VERIFIED | `schemaVersion => 12`, `if (from < 12)` block with 4 addColumn calls |
| `lib/core/database/daos/account_dao.dart` | 4 new EF/tier methods | ✓ VERIFIED | watchEmergencyFundAccounts, setLiquidityTier, setEmergencyFund, watchByLiquidityTier |
| `lib/features/planning/providers/emergency_fund_provider.dart` | 5 providers + EmergencyFundState | ✓ VERIFIED | 189 lines; all 5 providers and data class present |
| `lib/features/planning/screens/emergency_fund_screen.dart` | Full EF screen >= 100 lines | ✓ VERIFIED | 549 lines; 4 sections implemented |
| `lib/features/planning/widgets/ef_progress_ring.dart` | EfProgressRing with CircularProgressIndicator | ✓ VERIFIED | 52 lines, class EfProgressRing with color logic |
| `lib/features/planning/widgets/liquidity_tier_chip.dart` | LiquidityTierChip with Chip | ✓ VERIFIED | 34 lines, GestureDetector + Chip |
| `test/features/planning/providers/emergency_fund_provider_test.dart` | >= 30 lines | ✓ VERIFIED | 261 lines, 8 unit tests |
| `test/features/planning/screens/emergency_fund_screen_test.dart` | >= 40 lines | ✓ VERIFIED | 80 lines, 7 testWidgets |
| `lib/features/planning/widgets/ef_badge.dart` | EfBadge with ActionChip | ✓ VERIFIED | 29 lines, ActionChip with shield_outlined icon |
| `lib/features/accounts/screens/account_detail_screen.dart` | Contains EfBadge, isEmergencyFund | ✓ VERIFIED | Lines 150-170 show conditional EfBadge + LiquidityTierChip |
| `lib/features/accounts/screens/account_list_screen.dart` | Contains isEmergencyFund shield icon | ✓ VERIFIED | Lines 165-168 show shield_outlined icon conditional on isEmergencyFund |
| `lib/features/budgets/screens/budget_screen.dart` | Contains EmergencyFundScreen navigation | ✓ VERIFIED | Imports EmergencyFundScreen, watches emergencyFundStateProvider, navigates on tap |
| `lib/features/settings/screens/settings_screen.dart` | Emergency Fund tile + _openEmergencyFund | ✓ VERIFIED | Lines 111-116 tile, lines 184-190 _openEmergencyFund method |
| `test/features/accounts/screens/account_detail_ef_test.dart` | >= 30 lines | ✓ VERIFIED | 115 lines, 11 testWidgets |
| `test/features/accounts/screens/account_list_ef_test.dart` | >= 20 lines | ✓ VERIFIED | 66 lines, 3 testWidgets |
| `test/features/budgets/screens/budget_ef_nav_test.dart` | >= 20 lines | ✓ VERIFIED | 123 lines, 4 testWidgets |

---

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `emergency_fund_engine.dart` | `emergency_fund_engine_test.dart` | unit test coverage | ✓ WIRED | 26 tests call `EmergencyFundEngine.` static methods |
| `database.dart` | `accounts.dart` | migration adds columns | ✓ WIRED | `if (from < 12)` adds liquidityTier + isEmergencyFund |
| `emergency_fund_provider.dart` | `emergency_fund_engine.dart` | provider calls static methods | ✓ WIRED | `EmergencyFundEngine.monthlyEssentialAverage`, `.suggestedTargetMonths`, `.coverageMonths`, `.targetAmountPaise` used |
| `emergency_fund_screen.dart` | `emergency_fund_provider.dart` | ConsumerWidget reads providers | ✓ WIRED | `ref.watch(emergencyFundStateProvider(...))`, `efAccountsProvider`, `tierAccountsProvider` |
| `account_detail_screen.dart` | `emergency_fund_screen.dart` | EfBadge onTap navigates | ✓ WIRED | `Navigator.push(MaterialPageRoute(builder: (_) => EmergencyFundScreen(...)))` at line 158 |
| `account_list_screen.dart` | `accounts.dart` | reads isEmergencyFund to show badge | ✓ WIRED | `if (account.isEmergencyFund)` at line 165 |
| `budget_screen.dart` | `emergency_fund_screen.dart` | essentials row tap navigates | ✓ WIRED | `onEfTap` triggers `Navigator.push` to `EmergencyFundScreen` |
| `settings_screen.dart` | `emergency_fund_screen.dart` | Settings tile navigates | ✓ WIRED | `_openEmergencyFund` calls `Navigator.push(MaterialPageRoute(builder: (_) => EmergencyFundScreen(...)))` |
| `monthlyEssentialsProvider` | `EmergencyFundEngine.essentialGroups` | string key contract | ✗ BROKEN | Provider passes `BudgetSummary.computeActualsByGroup` output with uppercase slug keys (`'ESSENTIAL'`, `'HOME_EXPENSES'`, `'LIVING_EXPENSE'`) but engine filters on camelCase `{'essential', 'homeExpenses', 'livingExpense'}` — keys will never match |

---

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|------------|-------------|--------|---------|
| EF-01 | 09-01 | User can configure EF with target months based on income stability | ✓ SATISFIED | Income stability dropdown + target months override in EmergencyFundScreen Section B |
| EF-02 | 09-01 | Monthly essential expenses auto-computed from ESSENTIAL group (3-month rolling average) | ✗ BLOCKED | `monthlyEssentialsProvider` computes rolling 6-month average but the string key mismatch means the engine will always return 0 for essential average at runtime |
| EF-03 | 09-01 | User can link savings accounts and see total coverage | ✓ SATISFIED | CheckboxListTile bottom sheet + `setEmergencyFund` DAO + `efAccountsProvider` + coverage display |
| EF-04 | 09-01 | User can manually override the target amount | ✓ SATISFIED | +/- buttons in Section B with `efTargetMonthsOverride` persisted to life profile |
| EF-05 | 09-02 | EF progress shows current balance vs target with visual progress indicator | ✓ SATISFIED | `EfProgressRing` with color-coded `CircularProgressIndicator` and `X.X/Ymo` overlay |
| TIER-01 | 09-01 | User can assign each account a liquidity tier (Instant/Short-term/Long-term) | ✓ SATISFIED | `setLiquidityTier` DAO, tier picker dialog in EmergencyFundScreen, `LiquidityTierChip` |
| TIER-02 | 09-02 | User can see aggregate balance by tier with weighted-average interest rate | ⚠️ PARTIAL | Balance aggregation delivered; interest rate intentionally deferred (no `interestRateBp` column) — requirement text not fully satisfied |
| TIER-03 | 09-01 | App suggests optimal tier distribution (1mo immediate, 2mo short-term, rest medium-term) | ✓ SATISFIED | `EmergencyFundEngine.suggestTierDistribution` + "Suggested split" text in Section D |
| TIER-04 | 09-03 | Account detail screen shows cash tier badge when tier is assigned | ✓ SATISFIED | `LiquidityTierChip` conditionally shown in `_AccountSummaryCard` when `account.liquidityTier != null` |
| NAV-05 | 09-03 | Account detail shows cash tier and emergency fund badges when assigned | ✓ SATISFIED | `EfBadge` + `LiquidityTierChip` in `_AccountSummaryCard` with conditional rendering |
| NAV-06 | 09-03 | Budget screen shows monthly essentials row linking to emergency fund | ✓ SATISFIED | `BudgetScreen` shows "X.X months covered" subtitle on ESSENTIAL group row with tap navigation to `EmergencyFundScreen` |

**Orphaned Requirements:** None. All 11 requirement IDs from plan frontmatter are accounted for in REQUIREMENTS.md and verified.

---

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `lib/core/financial/emergency_fund_engine.dart` | 11 | String key mismatch: `essentialGroups = {'essential', 'homeExpenses', 'livingExpense'}` vs actual DB slugs `'ESSENTIAL'`, `'HOME_EXPENSES'`, `'LIVING_EXPENSE'` | Blocker | `monthlyEssentialAverage` always returns 0 in production; EF coverage always shows 0.0 months |
| `test/core/financial/emergency_fund_engine_test.dart` | 62-79 | String key contract test uses `CategoryGroup.name` camelCase values not actual DB output format | Blocker | Test passes but validates wrong format — false confidence |
| `lib/features/accounts/screens/account_list_screen.dart` | 104 | `// TODO: get from auth provider` (pre-existing, not phase 9) | Info | Unrelated to EF/tier goals |

---

### Human Verification Required

#### 1. EF Coverage Ring with Real Data

**Test:** After fixing the string key mismatch, open the EF screen with at least one EF-linked account and transactions in the essential/home/living categories.
**Expected:** Progress ring shows a non-zero coverage number (e.g., "4.2/6mo") with amber or green color.
**Why human:** Verifying that the full data pipeline — transactions → BudgetSummary → engine → provider → ring — produces correct display requires a running app with real DB state.

#### 2. Settings Navigation End-to-End

**Test:** Settings > Financial Planning > Emergency Fund tile tap.
**Expected:** EmergencyFundScreen opens with correct familyId and userId passed.
**Why human:** Full navigation stack requires running app.

#### 3. Account Selector Bottom Sheet Reactivity

**Test:** Open EF screen, tap "Link Accounts", toggle an account's checkbox, close the sheet.
**Expected:** The linked accounts section immediately reflects the change and total balance updates.
**Why human:** Requires verifying Drift stream reactivity in the full app runtime.

---

### Gaps Summary

**Gap 1 (Blocker): String Key Mismatch Between EmergencyFundEngine and BudgetSummary Output**

This is the most critical gap. The `EmergencyFundEngine.essentialGroups` set was designed to match `CategoryGroup` enum `.name` values (camelCase: `essential`, `homeExpenses`, `livingExpense`), but the actual category seeder (`CategorySeeder.seedDefaults`) stores categories with uppercase slug `groupName` values: `'ESSENTIAL'`, `'HOME_EXPENSES'`, `'LIVING_EXPENSE'`.

When `BudgetSummary.computeActualsByGroup` builds the actuals map, it uses `category.groupName` as keys — producing uppercase slug keys. When `monthlyEssentialsProvider` passes these maps to `EmergencyFundEngine.monthlyEssentialAverage`, the filter `essentialGroups.contains(entry.key)` will never match any key, and the method returns 0 for every month.

This means:
- `monthlyEssentialPaise` will always be 0
- `coverageMonths` will always be 0.0 (division guard)
- `targetAmountPaise` will always be 0
- The EF progress ring will always show 0.0/N months

The unit tests pass because they use hand-crafted input maps with camelCase keys that match `essentialGroups` — but these don't reflect what `BudgetSummary.computeActualsByGroup` actually returns.

**Fix:** Update `EmergencyFundEngine.essentialGroups` to `{'ESSENTIAL', 'HOME_EXPENSES', 'LIVING_EXPENSE'}` to match actual DB category slug format. Update the string key contract test to validate against these uppercase slug keys.

**Gap 2 (Warning): TIER-02 Interest Rate Not Delivered**

`REQUIREMENTS.md` states TIER-02 as "User can see aggregate balance by tier **with weighted-average interest rate**." The implementation delivers balance-only aggregation. The plans explicitly document this as an intentional scope decision (no `interestRateBp` column authorized in CONTEXT.md).

The requirement as written is not satisfied. The correct remediation is to update `REQUIREMENTS.md` TIER-02 to reflect the delivered scope ("balance-only aggregation per tier") and mark interest rate display as a future enhancement, rather than leaving a gap between the requirement text and implementation.

---

*Verified: 2026-03-24*
*Verifier: Claude (gsd-verifier)*
