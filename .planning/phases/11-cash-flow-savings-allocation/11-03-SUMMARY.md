---
phase: 11-cash-flow-savings-allocation
plan: 03
subsystem: ui
tags: [flutter, riverpod, savings-allocation, opportunity-fund, advisory-output]

requires:
  - phase: 11-cash-flow-savings-allocation
    provides: SavingsAllocationEngine, AllocationRule/Target/Advice models, SavingsAllocationRuleDao, AccountDao OPP methods
provides:
  - Savings allocation providers (rules stream, surplus, advisory output)
  - Opportunity fund providers (stream, available accounts)
  - SavingsAllocationScreen with drag-reorder rules and advisory output
  - OpportunityFundScreen with designation and progress tracking
  - Settings integration for both screens
  - Widget tests (6 tests)
affects: [phase-12, dashboard-cards]

tech-stack:
  added: []
  patterns: [engine import alias for AllocationTarget name conflict resolution]

key-files:
  created:
    - lib/features/planning/providers/savings_allocation_providers.dart
    - lib/features/planning/providers/opportunity_fund_providers.dart
    - lib/features/planning/screens/savings_allocation_screen.dart
    - lib/features/planning/screens/opportunity_fund_screen.dart
    - test/features/planning/screens/savings_allocation_screen_test.dart
    - test/features/planning/screens/opportunity_fund_screen_test.dart
  modified:
    - lib/features/settings/screens/settings_screen.dart

key-decisions:
  - "Import alias (engine prefix) resolves AllocationTarget name conflict between drift data class and engine model"
  - "EF target in advisory falls back to 0 (unlimited) when life profile unavailable"
  - "Advisory output uses whenOrNull pattern for surplus since valueOrNull unavailable in Riverpod 3.1"

patterns-established:
  - "engine. prefix pattern for savings_allocation_engine imports to avoid AllocationTarget drift conflict"

requirements-completed: [SAVE-01, SAVE-02, SAVE-03, SAVE-04, OPP-01, OPP-02, OPP-03]

duration: 12min
completed: 2026-03-24
---

# Phase 11 Plan 03: Savings Allocation and Opportunity Fund Screens Summary

**Priority-ordered surplus allocation rules with advisory output screen, and opportunity fund designation with progress tracking -- both advisory-only per SAVE-04**

## Performance

- **Duration:** 12 min
- **Started:** 2026-03-24T09:31:13Z
- **Completed:** 2026-03-24T09:43:21Z
- **Tasks:** 2
- **Files modified:** 7

## Accomplishments
- Savings allocation providers compute advisory output from rules + targets + surplus using SavingsAllocationEngine.distribute
- SavingsAllocationScreen with ReorderableListView for drag-to-reorder rules and advisory surplus distribution display
- OpportunityFundScreen with empty state, designation bottom sheet, progress ring, and remove designation
- Settings wired with "Savings Allocation" and "Opportunity Fund" tiles in Financial Planning section
- 6 widget tests verify advisory rendering, SAVE-04 compliance, and empty/designated states

## Task Commits

Each task was committed atomically:

1. **Task 1: Savings allocation + opportunity fund providers** - `7d067a0` (feat)
2. **Task 2: Screens + Settings wiring + widget tests** - `047385f` (feat)

## Files Created/Modified
- `lib/features/planning/providers/savings_allocation_providers.dart` - allocationRulesProvider, monthlySurplusProvider, allocationAdvisoryProvider
- `lib/features/planning/providers/opportunity_fund_providers.dart` - opportunityFundProvider, availableForOpportunityFundProvider
- `lib/features/planning/screens/savings_allocation_screen.dart` - Rule list with drag-reorder, advisory output, add rule bottom sheet
- `lib/features/planning/screens/opportunity_fund_screen.dart` - Designation, progress ring, change/remove account
- `lib/features/settings/screens/settings_screen.dart` - Two new tiles in Financial Planning section
- `test/features/planning/screens/savings_allocation_screen_test.dart` - 4 tests: advisory, disclaimer, priorities, SAVE-04
- `test/features/planning/screens/opportunity_fund_screen_test.dart` - 2 tests: empty state, designated state

## Decisions Made
- Used `engine.` import alias to resolve AllocationTarget name conflict between drift data class and engine model (same pattern as Phase 8 AllocationTarget)
- EF target in allocationAdvisoryProvider falls back to 0 (unlimited) when life profile is unavailable via try-catch
- Used `whenOrNull` instead of `valueOrNull` for surplus AsyncValue (not available in Riverpod 3.1)

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] AllocationTarget name conflict**
- **Found during:** Task 1 (provider creation)
- **Issue:** AllocationTarget exists in both drift database.dart and savings_allocation_engine.dart
- **Fix:** Import engine with alias `as engine`, prefix all engine types with `engine.`
- **Files modified:** savings_allocation_providers.dart, savings_allocation_screen.dart
- **Verification:** flutter analyze passes with no errors

**2. [Rule 1 - Bug] valueOrNull not available on AsyncValue**
- **Found during:** Task 2 (screen implementation)
- **Issue:** `AsyncValue<int>.valueOrNull` getter does not exist in flutter_riverpod 3.1
- **Fix:** Replaced with `whenOrNull(data: (v) => v) ?? 0` pattern
- **Files modified:** savings_allocation_screen.dart

**3. [Rule 1 - Bug] Account constructor missing required fields in test**
- **Found during:** Task 2 (widget tests)
- **Issue:** Account data class requires currency, visibility, sharedWithFamily, userId fields
- **Fix:** Added all required fields to _fakeAccount helper
- **Files modified:** opportunity_fund_screen_test.dart

---

**Total deviations:** 3 auto-fixed (2 bugs, 1 blocking)
**Impact on plan:** All auto-fixes necessary for compilation and test correctness. No scope creep.

## Issues Encountered
- Pre-commit hook formats all files in working tree; unformatted files from previous plan (cashflow widgets) caused format check failures until staged

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Phase 11 complete: cash flow engine, savings allocation, and opportunity fund all implemented
- Ready for phase evolution and next milestone planning

---
*Phase: 11-cash-flow-savings-allocation*
*Completed: 2026-03-24*
