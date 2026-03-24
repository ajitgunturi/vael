---
phase: 12-planning-dashboard-lifetime-timeline
plan: 02
subsystem: ui
tags: [flutter, custom-painter, timeline, cash-flow, waterfall-chart, riverpod]

requires:
  - phase: 07-fi-milestones
    provides: MilestoneEngine, FiCalculator, milestone/FI providers
  - phase: 11-cash-flow-savings-allocation
    provides: CashFlowEngine, SavingsAllocationEngine, allocation providers

provides:
  - LifetimeTimelineScreen with horizontal scrollable decade visualization
  - TimelinePainter CustomPainter with diamond FI marker and colored nodes
  - timelineNodesProvider combining milestones, purchases, FI date
  - CashFlowHealthScreen with income/expenses bars, waterfall, 7-day view
  - SavingsWaterfallChart stacked bar with color-coded allocation segments
  - CashFlowMiniView compact 7-day projection with threshold alerts

affects: [12-03-PLAN, dashboard-navigation]

tech-stack:
  added: []
  patterns:
    - FractionallySizedBox for proportional bar charts avoiding overflow
    - TimelinePainter.decadeRange static method for shared range computation
    - hitTestNode pattern on CustomPainter for tap detection

key-files:
  created:
    - lib/features/planning/providers/timeline_provider.dart
    - lib/features/planning/widgets/timeline_painter.dart
    - lib/features/planning/screens/lifetime_timeline_screen.dart
    - lib/features/planning/screens/cash_flow_health_screen.dart
    - lib/features/planning/widgets/savings_waterfall_chart.dart
    - lib/features/planning/widgets/cash_flow_mini_view.dart
    - test/features/planning/lifetime_timeline_test.dart
    - test/features/planning/cash_flow_health_test.dart
  modified: []

key-decisions:
  - "FractionallySizedBox with Expanded for income/expense bars to prevent overflow in constrained widths"
  - "TimelinePainter stores nodePositions list for external hit-testing via hitTestNode method"
  - "Purchase goals compute age from targetDate difference rather than stored age field"

patterns-established:
  - "TimelinePainter.decadeRange() shared between painter and screen for width/scroll computation"
  - "FractionallySizedBox pattern for proportional bars within Row layouts"

requirements-completed: [TIME-01, TIME-02, TIME-03, HEALTH-01, HEALTH-02, HEALTH-03]

duration: 7min
completed: 2026-03-24
---

# Phase 12 Plan 02: Lifetime Timeline and Cash Flow Health Summary

**Horizontal decade timeline with colored milestone/purchase/FI nodes, and cash flow health screen with income bars, savings waterfall, and 7-day mini-view**

## Performance

- **Duration:** 7 min
- **Started:** 2026-03-24T13:42:54Z
- **Completed:** 2026-03-24T13:49:54Z
- **Tasks:** 2
- **Files modified:** 8

## Accomplishments
- Lifetime timeline screen with horizontal scroll, decade grid, colored circle/diamond nodes, and tap-to-navigate
- Cash flow health screen with income vs expenses proportional bars, savings waterfall stacked chart, and 7-day mini-view with alert indicators
- 8 widget tests passing across both screens

## Task Commits

Each task was committed atomically:

1. **Task 1: Lifetime timeline provider, CustomPainter, and screen** - `fcb54ef` (feat)
2. **Task 2: Cash flow health screen with bar chart, savings waterfall, and 7-day mini-view** - `7d6cab3` (feat)

## Files Created/Modified
- `lib/features/planning/providers/timeline_provider.dart` - TimelineNode model, timelineNodesProvider combining milestones/purchases/FI
- `lib/features/planning/widgets/timeline_painter.dart` - CustomPainter with decade grid, circles, diamond FI marker, hit-testing
- `lib/features/planning/screens/lifetime_timeline_screen.dart` - Horizontal scroll timeline with auto-center on current age
- `lib/features/planning/screens/cash_flow_health_screen.dart` - Three-section health screen with bars, waterfall, mini-view
- `lib/features/planning/widgets/savings_waterfall_chart.dart` - Stacked horizontal bar with color-coded allocation segments
- `lib/features/planning/widgets/cash_flow_mini_view.dart` - 7-day compact projection list with warning icons
- `test/features/planning/lifetime_timeline_test.dart` - 4 widget tests for timeline screen
- `test/features/planning/cash_flow_health_test.dart` - 4 widget tests for cash flow health screen

## Decisions Made
- FractionallySizedBox with Expanded for income/expense bars to prevent overflow in constrained test widths
- TimelinePainter stores nodePositions for external hit-testing via hitTestNode method
- Purchase goal age computed from targetDate difference (no stored age field on Goal)

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Missing MilestoneStatus import in timeline_provider.dart**
- **Found during:** Task 1
- **Issue:** MilestoneStatus enum imported from milestone_provider.dart but it comes from milestone_engine.dart
- **Fix:** Added explicit import of milestone_engine.dart
- **Files modified:** lib/features/planning/providers/timeline_provider.dart
- **Committed in:** fcb54ef

**2. [Rule 1 - Bug] Row overflow in income/expenses bar section**
- **Found during:** Task 2
- **Issue:** Fixed-width Container in Row caused 40px overflow in test viewport
- **Fix:** Replaced with Expanded + FractionallySizedBox using fraction-based sizing
- **Files modified:** lib/features/planning/screens/cash_flow_health_screen.dart
- **Committed in:** 7d6cab3

---

**Total deviations:** 2 auto-fixed (2 bugs)
**Impact on plan:** Both fixes necessary for correctness. No scope creep.

## Issues Encountered
None beyond the auto-fixed items above.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Timeline and cash flow health screens ready for integration into planning dashboard navigation (Plan 03)
- Both screens consume existing engine outputs with provider overrides for testing

---
*Phase: 12-planning-dashboard-lifetime-timeline*
*Completed: 2026-03-24*
