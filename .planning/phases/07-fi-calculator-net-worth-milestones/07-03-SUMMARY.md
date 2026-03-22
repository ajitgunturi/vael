---
phase: 07-fi-calculator-net-worth-milestones
plan: 03
subsystem: ui
tags: [flutter, riverpod, drift, milestone-engine, settings, navigation]

# Dependency graph
requires:
  - phase: 07-01
    provides: MilestoneEngine static methods, NetWorthMilestoneDao
  - phase: 07-02
    provides: FiCalculatorScreen for Settings navigation
provides:
  - MilestoneDashboardScreen with 5 decade progress cards
  - MilestoneCard widget with status chips and dimmed past styling
  - MilestoneEditSheet bottom sheet for custom target persistence
  - milestoneListProvider combining life profile + DAO data
  - Settings Financial Planning section with FI Calculator and Milestones tiles
affects: [phase-08-asset-allocation, phase-12-dashboard]

# Tech tracking
tech-stack:
  added: []
  patterns: [provider-override-pattern-for-widget-tests, scroll-until-visible-for-deep-listview-tests]

key-files:
  created:
    - lib/features/planning/providers/milestone_provider.dart
    - lib/features/planning/screens/milestone_dashboard_screen.dart
    - lib/features/planning/widgets/milestone_card.dart
    - lib/features/planning/widgets/milestone_edit_sheet.dart
    - test/features/planning/providers/milestone_provider_test.dart
    - test/features/planning/screens/milestone_dashboard_screen_test.dart
  modified:
    - lib/features/settings/screens/settings_screen.dart
    - test/features/settings/settings_screen_test.dart
    - test/integration/phase5_e2e_test.dart

key-decisions:
  - "Risk-profile return rate lookup: conservative 8%, moderate 10%, aggressive 12% with TODO for Phase 8 holdings-weighted replacement"
  - "milestoneListProvider uses StreamProvider.family watching both lifeProfile and DAO watchForUser"
  - "Past milestones show current NW as actual (0 until account data wired) with reached/missed status"

patterns-established:
  - "scrollUntilVisible pattern for Settings tests when new tiles push items off-screen in ListView"

requirements-completed: [MILE-01, MILE-02, MILE-03, MILE-04, FI-01]

# Metrics
duration: 9min
completed: 2026-03-22
---

# Phase 7 Plan 3: Milestone Dashboard & Settings Navigation Summary

**Milestone dashboard with 5 decade cards, status chips, edit-target bottom sheet, and Settings navigation for FI Calculator + Milestones**

## Performance

- **Duration:** 9 min
- **Started:** 2026-03-22T20:45:05Z
- **Completed:** 2026-03-22T20:54:33Z
- **Tasks:** 2
- **Files modified:** 9

## Accomplishments
- MilestoneDashboardScreen renders 5 decade cards (ages 30-70) with on-track/behind/ahead/reached/missed status chips
- MilestoneEditSheet persists custom targets via NetWorthMilestoneDao with upsert
- Settings Financial Planning section now has Life Profile, FI Calculator, and Milestones tiles
- 19 new tests (9 milestone + 10 settings) all passing, 921 total suite green

## Task Commits

Each task was committed atomically:

1. **Task 1: Milestone provider and dashboard screen with 5 decade cards** - `ce56bdd` (feat)
2. **Task 2: Wire FI Calculator and Milestones into Settings navigation** - `56ba36a` (feat)

## Files Created/Modified
- `lib/features/planning/providers/milestone_provider.dart` - MilestoneDisplayItem data class, milestoneListProvider, netWorthMilestoneDaoProvider, risk-profile return rate lookup
- `lib/features/planning/screens/milestone_dashboard_screen.dart` - Dashboard with 5 MilestoneCards, EmptyState, edit sheet integration
- `lib/features/planning/widgets/milestone_card.dart` - Individual card with age badge, progress bar, status chip, edit icon, past dimming
- `lib/features/planning/widgets/milestone_edit_sheet.dart` - Bottom sheet for custom target input with validation and DAO persistence
- `lib/features/settings/screens/settings_screen.dart` - Added FI Calculator and Milestones tiles to Financial Planning section
- `test/features/planning/providers/milestone_provider_test.dart` - 4 provider tests (empty, 5 items, custom overrides, past milestones)
- `test/features/planning/screens/milestone_dashboard_screen_test.dart` - 5 screen tests (cards, empty state, status chips, edit icons, header)
- `test/features/settings/settings_screen_test.dart` - Fixed scroll-to-visible for Sign Out after new tiles
- `test/integration/phase5_e2e_test.dart` - Fixed scroll-to-visible for Sign Out in e2e tests

## Decisions Made
- Risk-profile return rate: conservative=8%, moderate=10%, aggressive=12% with TODO for Phase 8 ALLOC-03 holdings-weighted replacement
- milestoneListProvider uses StreamProvider.family watching both lifeProfile and DAO streams
- Past milestones show currentNwPaise (0 until account data is wired) as actual amount
- Widget tests use provider override pattern to avoid drift stream timer issues (same as FI Calculator)

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed settings and e2e tests broken by new tiles pushing Sign Out off-screen**
- **Found during:** Task 2 (Settings navigation wiring)
- **Issue:** Adding FI Calculator and Milestones tiles to Settings pushed Sign Out below viewport in ListView, causing find.text('Sign Out') to fail in lazy-built list
- **Fix:** Changed ensureVisible to scrollUntilVisible pattern in settings_screen_test.dart and phase5_e2e_test.dart
- **Files modified:** test/features/settings/settings_screen_test.dart, test/integration/phase5_e2e_test.dart
- **Verification:** All 921 tests pass
- **Committed in:** 56ba36a (Task 2 commit)

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** Fix was necessary to prevent test regressions from new Settings tiles. No scope creep.

## Issues Encountered
None beyond the scroll fix above.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Phase 7 complete: all 3 plans (engine, FI calculator, milestones) delivered
- MilestoneEngine, FiCalculator, and all UI screens ready for Phase 8 asset allocation
- Risk-profile return rate has TODO marker for Phase 8 ALLOC-03 holdings-weighted replacement

---
*Phase: 07-fi-calculator-net-worth-milestones*
*Completed: 2026-03-22*
