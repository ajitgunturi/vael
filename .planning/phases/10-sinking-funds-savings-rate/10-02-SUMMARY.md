---
phase: 10-sinking-funds-savings-rate
plan: 02
subsystem: ui
tags: [flutter, riverpod, tabs, sinking-fund, contribution, goal-form]

requires:
  - phase: 10-01
    provides: SinkingFundEngine, GoalDao.watchByCategory, sinkingFundSubType column, GoalCategory.sinkingFund enum

provides:
  - Tabbed GoalListScreen with 3 tabs (Sinking Funds, Investments, Purchases)
  - SinkingFundCard widget with progress, pace, monthly needed
  - GoalTypePicker bottom sheet for FAB
  - GoalFormScreen sinking fund sub-type picker
  - ContributionSheet bottom sheet with tagged transaction creation
  - Category-scoped stream providers (sinkingFundGoalsProvider, investmentGoalsProvider, purchaseGoalsProvider)

affects: [10-03-savings-rate, dashboard]

tech-stack:
  added: []
  patterns: [tab-scoped providers per category, contribution-as-tagged-transaction]

key-files:
  created:
    - lib/features/goals/widgets/sinking_fund_card.dart
    - lib/features/goals/widgets/goal_type_picker.dart
    - lib/features/goals/widgets/contribution_sheet.dart
  modified:
    - lib/features/goals/screens/goal_list_screen.dart
    - lib/features/goals/screens/goal_form_screen.dart
    - lib/features/goals/providers/goal_providers.dart
    - test/features/goals/goal_list_screen_test.dart
    - test/shared/shell/home_shell_test.dart

key-decisions:
  - "Sinking fund form hides category segmented button since user pre-selected via GoalTypePicker"
  - "Contribution flow uses tagged transaction with metadata JSON for goalId traceability"
  - "Tab-scoped providers (sinkingFundGoalsProvider etc.) replace monolithic goalListProvider for tab content"

patterns-established:
  - "Tab-scoped providers: separate StreamProvider.family per goal category tab"
  - "Contribution-as-transaction: sinking fund contributions create transfer transactions with goalId metadata"

requirements-completed: [SINK-03, SINK-04, NAV-04]

duration: 11min
completed: 2026-03-24
---

# Phase 10 Plan 02: Sinking Fund UI Summary

**Tabbed GoalListScreen with SinkingFundCard progress widget, GoalTypePicker FAB, sub-type form extension, and contribution flow via tagged transactions**

## Performance

- **Duration:** 11 min
- **Started:** 2026-03-24T04:12:23Z
- **Completed:** 2026-03-24T04:23:30Z
- **Tasks:** 2
- **Files modified:** 8

## Accomplishments
- Refactored GoalListScreen from section-based ListView to 3-tab layout (Sinking Funds default, Investments, Purchases)
- SinkingFundCard shows name, sub-type chip, pace-colored progress bar, amounts, days remaining, monthly contribution needed
- GoalFormScreen extended with sinking fund sub-type picker (9 types) and proper field hiding
- ContributionSheet creates tagged transactions and updates goal progress with completion detection

## Task Commits

Each task was committed atomically:

1. **Task 1: Tabbed GoalListScreen + SinkingFundCard + GoalTypePicker + providers** - `c070d5d` (feat)
2. **Task 2: GoalFormScreen sinking fund extension + contribution flow** - `30eb359` (feat)

## Files Created/Modified
- `lib/features/goals/widgets/sinking_fund_card.dart` - Card with progress bar, pace color, monthly needed, days remaining
- `lib/features/goals/widgets/goal_type_picker.dart` - Bottom sheet for FAB goal type selection
- `lib/features/goals/widgets/contribution_sheet.dart` - Bottom sheet for sinking fund contributions
- `lib/features/goals/screens/goal_list_screen.dart` - Refactored to 3-tab layout with TabController
- `lib/features/goals/screens/goal_form_screen.dart` - Extended with sinking fund sub-type picker
- `lib/features/goals/providers/goal_providers.dart` - Added category-scoped stream providers
- `test/features/goals/goal_list_screen_test.dart` - Rewritten for tabbed layout (7 tests)
- `test/shared/shell/home_shell_test.dart` - Updated with new provider overrides

## Decisions Made
- Sinking fund form hides category segmented button since user pre-selected via GoalTypePicker
- Contribution flow uses tagged transaction with metadata JSON `{"goalId": id, "type": "sinkingFundContribution"}` for traceability
- Tab-scoped providers replace monolithic goalListProvider for each tab's content
- Completed sinking funds show in collapsed ExpansionTile section

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Fixed existing tests broken by GoalListScreen refactor**
- **Found during:** Task 1
- **Issue:** Existing goal_list_screen_test.dart used goalListProvider override and pumpAndSettle which timed out with new TabController
- **Fix:** Rewrote tests to override category-scoped providers and use pump() instead of pumpAndSettle()
- **Files modified:** test/features/goals/goal_list_screen_test.dart
- **Verification:** All 7 tests pass
- **Committed in:** c070d5d (Task 1 commit)

**2. [Rule 3 - Blocking] Fixed home_shell_test Goals tab navigation timeout**
- **Found during:** Task 1
- **Issue:** HomeShell test "navigates to Goals tab on tap" used pumpAndSettle which timed out because GoalListScreen TabController keeps ticker running
- **Fix:** Added new provider overrides and switched to pump() for Goals tab navigation test
- **Files modified:** test/shared/shell/home_shell_test.dart
- **Verification:** All 8 home shell tests pass
- **Committed in:** c070d5d (Task 1 commit)

---

**Total deviations:** 2 auto-fixed (2 blocking)
**Impact on plan:** Both fixes required for test suite to pass. No scope creep.

## Issues Encountered
None beyond the test fixes documented above.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Sinking fund UI complete, ready for Plan 03 (savings rate dashboard)
- ContributionSheet pattern can be extended for investment goal contributions

---
*Phase: 10-sinking-funds-savings-rate*
*Completed: 2026-03-24*
