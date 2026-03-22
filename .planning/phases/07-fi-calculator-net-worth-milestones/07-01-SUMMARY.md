---
phase: 07-fi-calculator-net-worth-milestones
plan: 01
subsystem: financial-engine, database
tags: [fi-calculator, milestones, drift, dart, pure-math, tdd]

# Dependency graph
requires:
  - phase: 06-life-profile-income-model
    provides: LifeProfiles table, FinancialMath primitives, IncomeGrowthEngine
provides:
  - FiCalculator static engine (computeFiNumber, yearsToFi, coastFi)
  - MilestoneEngine static engine (projectNetWorthAtAge, determineStatus, defaultTargets)
  - NetWorthMilestones Drift table with DAO (watchForUser, getForUser, getByAge, upsertMilestone, softDelete)
  - Schema v10 migration
affects: [07-02-PLAN, 07-03-PLAN]

# Tech tracking
tech-stack:
  added: []
  patterns: [pure-static-engine-composing-FinancialMath, decade-age-milestone-projection]

key-files:
  created:
    - lib/core/financial/fi_calculator.dart
    - lib/core/financial/milestone_engine.dart
    - lib/core/database/tables/net_worth_milestones.dart
    - lib/core/database/daos/net_worth_milestone_dao.dart
    - lib/core/database/daos/net_worth_milestone_dao.g.dart
    - test/core/financial/fi_calculator_test.dart
    - test/core/financial/milestone_engine_test.dart
    - test/core/database/daos/net_worth_milestone_dao_test.dart
  modified:
    - lib/core/database/database.dart
    - lib/core/database/database.g.dart
    - test/core/database/migration_test.dart

key-decisions:
  - "FiCalculator.yearsToFi uses month-by-month iteration (up to 1200 months) for accuracy over closed-form approximation"
  - "MilestoneEngine.determineStatus uses 1.05x/0.90x thresholds for ahead/onTrack/behind classification"
  - "defaultTargets uses fixed decade ages [30,40,50,60,70] filtered by current age"

patterns-established:
  - "Pure static engine pattern: private constructor, static methods, composes from FinancialMath"
  - "Milestone status enum with past (reached/missed) and future (ahead/onTrack/behind) states"

requirements-completed: [FI-01, FI-02, FI-03, MILE-01, MILE-02, MILE-03, MILE-04]

# Metrics
duration: 6min
completed: 2026-03-23
---

# Phase 7 Plan 1: FI Calculator & Net Worth Milestones Summary

**Pure-math FI/Coast-FI/years-to-FI engines + milestone projection with Drift persistence layer (schema v10)**

## Performance

- **Duration:** 6 min
- **Started:** 2026-03-22T20:07:53Z
- **Completed:** 2026-03-22T20:13:24Z
- **Tasks:** 2
- **Files modified:** 11

## Accomplishments
- FiCalculator computes FI number (inflation-adjusted expenses / SWR), years-to-FI (month-by-month iteration), and Coast FI (PV of FI number)
- MilestoneEngine projects net worth at decade ages and classifies milestone status (ahead/onTrack/behind/reached/missed)
- Both engines are pure static with zero DB dependencies, composing from existing FinancialMath primitives
- NetWorthMilestones Drift table with full CRUD DAO and schema v10 migration
- 28 tests passing (19 engine + 9 DAO/migration)

## Task Commits

Each task was committed atomically:

1. **Task 1: FiCalculator and MilestoneEngine pure-math engines** - `40fbfb7` (feat)
2. **Task 2: NetWorthMilestones Drift table, DAO, and schema migration v9->v10** - `3b7fb11` (feat)

## Files Created/Modified
- `lib/core/financial/fi_calculator.dart` - Pure static FI math engine (computeFiNumber, yearsToFi, coastFi)
- `lib/core/financial/milestone_engine.dart` - Pure static milestone projection engine (projectNetWorthAtAge, determineStatus, defaultTargets)
- `lib/core/database/tables/net_worth_milestones.dart` - Drift table with 10 columns
- `lib/core/database/daos/net_worth_milestone_dao.dart` - DAO with watch/get/upsert/softDelete
- `lib/core/database/daos/net_worth_milestone_dao.g.dart` - Drift codegen
- `lib/core/database/database.dart` - Schema v10 migration, table + DAO registration
- `lib/core/database/database.g.dart` - Drift codegen
- `test/core/financial/fi_calculator_test.dart` - 10 tests for FiCalculator
- `test/core/financial/milestone_engine_test.dart` - 9 tests for MilestoneEngine
- `test/core/database/daos/net_worth_milestone_dao_test.dart` - 6 DAO tests
- `test/core/database/migration_test.dart` - Updated schema version assertion to v10

## Decisions Made
- FiCalculator.yearsToFi uses month-by-month iteration (up to 1200 months / 100 years) for accuracy over closed-form approximation
- MilestoneEngine.determineStatus uses 1.05x ahead / 0.90x onTrack thresholds per plan spec
- defaultTargets uses fixed decade ages [30,40,50,60,70] filtered by current age

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- FiCalculator and MilestoneEngine ready for UI consumption in Plans 02 and 03
- NetWorthMilestones table ready for milestone CRUD in Plan 02
- All 900 existing tests continue to pass with new code

---
*Phase: 07-fi-calculator-net-worth-milestones*
*Completed: 2026-03-23*
