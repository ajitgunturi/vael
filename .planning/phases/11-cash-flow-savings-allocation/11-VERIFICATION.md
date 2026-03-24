---
phase: 11-cash-flow-savings-allocation
verified: 2026-03-24T12:00:00Z
status: passed
score: 11/11 must-haves verified
re_verification:
  previous_status: gaps_found
  previous_score: 10/11
  gaps_closed:
    - "Tapping an income/expense item navigates to the source recurring rule (FLOW-04)"
  gaps_remaining: []
  regressions: []
---

# Phase 11: Cash Flow Savings Allocation Verification Report

**Phase Goal:** User can see day-by-day cash flow projections with threshold alerts and get advisory surplus distribution across their savings targets
**Verified:** 2026-03-24T12:00:00Z
**Status:** passed
**Re-verification:** Yes — after gap closure (Plan 11-04 closed FLOW-04)

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | CashFlowEngine projects day-by-day running balances per account from cash flow items | VERIFIED | `lib/core/financial/cash_flow_engine.dart` — full groupBy + sorted-date loop with `Map.from(runningBalances)` snapshot per day |
| 2 | CashFlowEngine generates threshold alerts when any account balance dips below its minimum | VERIFIED | Lines 113-126: iterates `thresholds.entries`, creates `ThresholdAlert` with `date` field when `balance < entry.value` |
| 3 | ThresholdAlert includes the date the dip occurs for display in locked alert text format | VERIFIED | `class ThresholdAlert` has `final DateTime date` field; `CashFlowAlertRow` formats it as `DateFormat('dd MMM').format(alert.date)` |
| 4 | SavingsAllocationEngine distributes surplus in priority order, skipping met targets | VERIFIED | `distribute()` iterates rules in order, computes `gap`, skips when `gap <= 0` (target met) |
| 5 | SavingsAllocationEngine supports both fixed-amount and percentage-of-surplus allocation types | VERIFIED | Branching on `rule.allocationType`: `'fixed'` uses `rule.amountPaise`, `'percentage'` uses `surplusPaise * percentageBp ~/ 10000` |
| 6 | Schema v14 adds savings_allocation_rules table and three new account columns | VERIFIED | `database.dart`: `schemaVersion => 14`, `if (from < 14)` migration creates `savingsAllocationRules` table and adds `isOpportunityFund`, `opportunityFundTargetPaise`, `minimumBalancePaise` to accounts |
| 7 | User can see day-by-day income/expense items as a vertical scrollable timeline with month navigation | VERIFIED | `CashFlowScreen` with `ListView` of `CashFlowDayRow` widgets; chevron_left/right in AppBar; `selectedCashFlowMonthProvider` via `NotifierProvider` |
| 8 | Inline warning rows appear using locked format "Balance drops to Rs X on [date] -- below Rs Y minimum" | VERIFIED | `CashFlowAlertRow` renders `'Balance drops to Rs $balanceRupees on $dateStr -- below Rs $thresholdRupees minimum'`; test asserts `find.textContaining('Balance drops to Rs 10000 on 15 Mar')` |
| 9 | User can create priority-ordered savings allocation rules and see advisory surplus distribution output | VERIFIED | `SavingsAllocationScreen` with `ReorderableListView` rules, `allocationAdvisoryProvider`, advisory disclaimer "Advisory only — no transactions are created automatically" |
| 10 | Output is advisory only — no auto-transaction buttons exist | VERIFIED | No "Create Transaction" or "Apply" button on screen; SAVE-04 comment in class docstring; test `savings_allocation_screen_test.dart` verifies absence |
| 11 | Tapping an income/expense item navigates to the source recurring rule | VERIFIED | `_onItemTap` in `cash_flow_screen.dart` calls `Navigator.of(context).push(MaterialPageRoute(...RecurringFormScreen(familyId: familyId, editingId: ruleId)))`. No debugPrint stub. Widget test `tapping item navigates to RecurringFormScreen with ruleId` passes (10/10 tests pass). |

**Score:** 11/11 truths verified

---

### Required Artifacts

| Artifact | Status | Details |
|----------|--------|---------|
| `lib/core/financial/cash_flow_engine.dart` | VERIFIED | Exports `CashFlowEngine`, `CashFlowItem`, `DayProjection`, `ThresholdAlert`; pure static with private constructor |
| `lib/core/financial/savings_allocation_engine.dart` | VERIFIED | Exports `SavingsAllocationEngine`, `AllocationRule`, `AllocationTarget`, `AllocationAdvice`; pure static with private constructor |
| `lib/core/database/tables/savings_allocation_rules.dart` | VERIFIED | `class SavingsAllocationRules extends Table` with `targetType`, `allocationType`, `priority`, `amountPaise`, `percentageBp` columns |
| `lib/core/database/daos/savings_allocation_rule_dao.dart` | VERIFIED | `watchByFamily`, `getByFamily`, `insertRule`, `updateRule`, `softDelete`, `reorderPriorities` all implemented |
| `lib/core/database/daos/account_dao.dart` | VERIFIED | `watchOpportunityFund`, `setOpportunityFund`, `clearOpportunityFund`, `setMinimumBalance`, `getThresholds` all implemented |
| `lib/features/cashflow/providers/cash_flow_providers.dart` | VERIFIED | `selectedCashFlowMonthProvider`, `cashFlowProjectionProvider`, `buildCashFlowItems`, `accountNamesProvider` all present |
| `lib/features/cashflow/screens/cash_flow_screen.dart` | VERIFIED | `CashFlowScreen` present; `cashFlowProjectionProvider`, chevrons, `ThresholdConfigSheet` wired; `_onItemTap` calls `Navigator.of(context).push` to `RecurringFormScreen(editingId: ruleId)` — no stub |
| `lib/features/cashflow/widgets/cash_flow_day_row.dart` | VERIFIED | `class CashFlowDayRow` takes `DayProjection day`, renders items with icons and balance chips |
| `lib/features/cashflow/widgets/cash_flow_alert_row.dart` | VERIFIED | `class CashFlowAlertRow` takes `ThresholdAlert alert`, renders locked format with `alert.date` |
| `lib/features/cashflow/widgets/threshold_config_sheet.dart` | VERIFIED | `class ThresholdConfigSheet` fetches thresholds, calls `setMinimumBalance` per account |
| `lib/features/planning/providers/savings_allocation_providers.dart` | VERIFIED | `allocationRulesProvider`, `monthlySurplusProvider`, `allocationAdvisoryProvider` with `SavingsAllocationEngine.distribute` call |
| `lib/features/planning/providers/opportunity_fund_providers.dart` | VERIFIED | `opportunityFundProvider` calls `watchOpportunityFund`; `availableForOpportunityFundProvider` filters EF+OPP accounts |
| `lib/features/planning/screens/savings_allocation_screen.dart` | VERIFIED | 465 lines; `allocationAdvisoryProvider` watched; advisory disclaimer rendered; `ReorderableListView` rules |
| `lib/features/planning/screens/opportunity_fund_screen.dart` | VERIFIED | `class OpportunityFundScreen`; `opportunityFundProvider` watched; `setOpportunityFund` called on save; `clearOpportunityFund` on remove |
| `lib/features/settings/screens/settings_screen.dart` | VERIFIED | "Savings Allocation" and "Opportunity Fund" tiles in Financial Planning section, both imported and navigating |
| `test/core/financial/cash_flow_engine_test.dart` | VERIFIED | 260 lines, substantive unit tests |
| `test/core/financial/savings_allocation_engine_test.dart` | VERIFIED | 355 lines, substantive unit tests |
| `test/features/cashflow/build_cash_flow_items_test.dart` | VERIFIED | 186 lines |
| `test/features/cashflow/cash_flow_screen_test.dart` | VERIFIED | 227 lines; 10 tests — all pass including new navigation test `tapping item navigates to RecurringFormScreen with ruleId` |
| `test/features/planning/screens/savings_allocation_screen_test.dart` | VERIFIED | 160 lines; 4 tests including advisory rendering and SAVE-04 compliance |
| `test/features/planning/screens/opportunity_fund_screen_test.dart` | VERIFIED | 77 lines; 2 tests for empty and designated states |

---

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `cash_flow_engine.dart` | RecurringScheduler output format | `class CashFlowItem` with ruleId, date, accountId, kind fields | VERIFIED | `CashFlowItem` mirrors `PendingTransaction` fields exactly |
| `savings_allocation_engine.dart` | EF/SF engine output | `AllocationTarget.targetPaise` consumed from engine output | VERIFIED | `AllocationTarget` carries `currentPaise` and `targetPaise` in paise |
| `database.dart` | savings_allocation_rules table | schema v14 migration `if (from < 14)` | VERIFIED | `createTable(savingsAllocationRules)` in migration block |
| `cash_flow_providers.dart` | RecurringScheduler + CashFlowEngine | `RecurringScheduler.computeDueDates` + `CashFlowEngine.projectMonth` | VERIFIED | Both static calls present |
| `cash_flow_screen.dart` | `cashFlowProjectionProvider` | `ref.watch(cashFlowProjectionProvider(...))` | VERIFIED | Line 33-35 |
| `cash_flow_screen.dart` | `RecurringFormScreen` | `Navigator.of(context).push(MaterialPageRoute(...RecurringFormScreen(familyId: familyId, editingId: ruleId)))` | VERIFIED | Lines 9 (import) and 156-161 (Navigator.push); `flutter analyze` reports no issues; all 10 tests pass |
| `cash_flow_day_row.dart` | `DayProjection` data class | Constructor `required this.day` typed as `DayProjection` | VERIFIED | `final DayProjection day;` field present |
| `cash_flow_alert_row.dart` | `ThresholdAlert.date` | `DateFormat('dd MMM').format(alert.date)` | VERIFIED | Line 24 reads `alert.date` |
| `savings_allocation_providers.dart` | `SavingsAllocationEngine` | `engine.SavingsAllocationEngine.distribute(...)` | VERIFIED | Line 157 calls `distribute` |
| `savings_allocation_screen.dart` | `allocationAdvisoryProvider` | `ref.watch(allocationAdvisoryProvider(widget.familyId))` | VERIFIED | Lines 33-35 |
| `opportunity_fund_providers.dart` | `AccountDao.watchOpportunityFund` | `StreamProvider` calls `dao.watchOpportunityFund(familyId)` | VERIFIED | Line 17 |

---

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| FLOW-01 | 11-01, 11-02 | User can see day-by-day income/expense map for any month | SATISFIED | `cashFlowProjectionProvider` + `CashFlowScreen` timeline render |
| FLOW-02 | 11-01, 11-02 | Running balance computed daily with configurable threshold | SATISFIED | `CashFlowEngine.projectMonth` + `minimumBalancePaise` column + `ThresholdConfigSheet` |
| FLOW-03 | 11-01, 11-02 | Threshold alerts flag dates where balance goes below minimum | SATISFIED | `ThresholdAlert` with `date` field; `CashFlowAlertRow` renders inline |
| FLOW-04 | 11-02, 11-04 | Tapping item navigates to source recurring rule | SATISFIED | `_onItemTap` pushes `RecurringFormScreen(familyId: familyId, editingId: ruleId)`; widget test passes; zero debugPrint stubs |
| SAVE-01 | 11-01, 11-03 | Priority-ordered savings allocation rules for EF/SF/IG/OPP | SATISFIED | `SavingsAllocationRules` table; `SavingsAllocationScreen` with `ReorderableListView` |
| SAVE-02 | 11-01, 11-03 | Rules support fixed amount and percentage of surplus | SATISFIED | `AllocationRule.allocationType` + engine branches on 'fixed'/'percentage' |
| SAVE-03 | 11-01, 11-03 | Engine processes rules in priority order, skips met targets | SATISFIED | `gap <= 0 continue` in `SavingsAllocationEngine.distribute` |
| SAVE-04 | 11-03 | Output is advisory only, no auto-transaction creation | SATISFIED | No "Apply"/"Create Transaction" button; disclaimer rendered; test verifies |
| OPP-01 | 11-01, 11-03 | User can designate account as opportunity fund with target | SATISFIED | `setOpportunityFund` in AccountDao; `OpportunityFundScreen._save` calls it |
| OPP-02 | 11-03 | Opportunity fund tracked separately from emergency fund | SATISFIED | `OpportunityFundScreen` is distinct from `EmergencyFundScreen`; `isOpportunityFund` column separate from `isEmergencyFund` |
| OPP-03 | 11-01, 11-03 | Opportunity fund can be a target in savings allocation rules | SATISFIED | `targetType = 'opportunityFund'` in `AllocationRule`; `allocationAdvisoryProvider` builds `targets['opportunityFund:null']` from designated account |

All 11 requirements satisfied. No orphaned requirements found.

---

### Anti-Patterns Found

None. The previous blocker (`debugPrint('Navigate to rule: $ruleId')` on line 153 of `cash_flow_screen.dart`) has been removed. `flutter analyze` on the modified file reports no issues.

---

### Human Verification Required

#### 1. Cash Flow Timeline Visual Layout

**Test:** Open the cash flow screen for a month that has recurring rules configured. Scroll through the timeline.
**Expected:** Day cards are readable with date header, item rows (salary/rent/etc.), and running balance chips at the bottom of each card. Alert rows appear visually distinct (amber background, left border) directly before the day card that triggers the alert.
**Why human:** Visual hierarchy and color differentiation cannot be verified programmatically.

#### 2. Item Tap Navigation End-to-End

**Test:** On the cash flow screen, tap any item row (e.g., "Salary"). Observe the screen that opens.
**Expected:** The recurring rule edit form opens pre-populated with the tapped rule's data. Navigating back returns to the cash flow screen in the same month state.
**Why human:** Requires live DB data, actual recurring rule records, and navigator stack behavior on a device/simulator.

#### 3. Threshold Config Sheet Usability

**Test:** Tap the tune icon. Enter a minimum balance value for one account and tap save. Return to the screen. Check if an alert appears on the relevant day.
**Expected:** Bottom sheet shows accounts with current threshold values pre-populated. Save persists the value. Re-projection shows an alert if the balance dips below the new threshold.
**Why human:** End-to-end DAO persistence and re-rendering requires live device/simulator.

#### 4. Savings Allocation Advisory Responsiveness

**Test:** Navigate to Settings > Savings Allocation. Add two rules (one fixed, one percentage). Observe the advisory output section.
**Expected:** Advisory section shows correct allocations in priority order with progress indicators. "No surplus" message shows when monthly metrics show zero surplus.
**Why human:** Requires actual MonthlyMetrics data in DB and live provider evaluation.

#### 5. Opportunity Fund Designation Flow

**Test:** Navigate to Settings > Opportunity Fund. Tap "Designate Account", select an account, enter a target amount, save. Observe the progress ring.
**Expected:** Progress ring shows correct percentage. "Change Account" and "Remove Designation" buttons work.
**Why human:** Requires live DB state and account data.

---

### Re-verification Summary

The single gap from the initial verification has been fully closed by Plan 11-04.

**What changed:**
- `lib/features/cashflow/screens/cash_flow_screen.dart`: import for `RecurringFormScreen` added on line 9; `_onItemTap` method body (lines 153-161) replaced — the `debugPrint` stub and deferral comment are gone, replaced with `Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => RecurringFormScreen(familyId: familyId, editingId: ruleId)))`.
- `test/features/cashflow/cash_flow_screen_test.dart`: `RecurringFormScreen` import added; `allAccountsProvider` override added to `_buildApp` helper; new test `tapping item navigates to RecurringFormScreen with ruleId` added and passing.

**Test result:** 10/10 tests pass in `cash_flow_screen_test.dart`. `flutter analyze` reports no issues. No regressions in existing tests.

All 11 truths verified, all 11 requirements satisfied, all key links wired. Phase goal fully achieved.

---

_Verified: 2026-03-24T12:00:00Z_
_Verifier: Claude (gsd-verifier)_
