---
phase: 08-asset-allocation-purchase-planning
plan: 02
subsystem: database
tags: [drift, sqlite, migration, dao, allocation, decisions, goals]

requires:
  - phase: 06-life-profile-income-model
    provides: LifeProfiles table (FK target for allocation_targets)
provides:
  - AllocationTargets table with DAO for custom glide-path overrides
  - Decisions table with DAO for what-if financial decision tracking
  - Goals extended with goalCategory, downPaymentPctBp, educationEscalationRateBp
  - RecurringRules extended with decisionId for decision linking
  - GoalDao.watchByCategory for category-scoped goal queries
affects: [08-03-decision-engine, 08-04-purchase-planning-ui, 08-05-allocation-ui]

tech-stack:
  added: []
  patterns: [schema migration v11, DAO with stream + atomic replace]

key-files:
  created:
    - lib/core/database/tables/allocation_targets.dart
    - lib/core/database/tables/decisions.dart
    - lib/core/database/daos/allocation_target_dao.dart
    - lib/core/database/daos/decision_dao.dart
    - test/core/database/daos/allocation_target_dao_test.dart
    - test/core/database/daos/decision_dao_test.dart
  modified:
    - lib/core/database/tables/goals.dart
    - lib/core/database/tables/recurring_rules.dart
    - lib/core/database/database.dart
    - lib/core/database/database.g.dart
    - lib/core/database/daos/goal_dao.dart
    - test/core/database/migration_test.dart

key-decisions:
  - "goalCategory column uses text with default 'investmentGoal' for backward compatibility"
  - "Allocation target percentages stored as basis points (integer) matching project convention"
  - "Decisions table uses soft-delete pattern (deletedAt) consistent with other tables"

patterns-established:
  - "replaceAllForProfile: atomic delete-and-reinsert within transaction for bulk updates"
  - "watchByCategory on GoalDao: category-scoped stream query pattern"

requirements-completed: [ALLOC-05, PURCH-01, PURCH-03]

duration: 10min
completed: 2026-03-23
---

# Phase 08 Plan 02: Schema Migration & DAOs Summary

**Schema v11 migration adding allocation_targets + decisions tables, extending goals/recurring_rules with 4 new columns, and 2 new DAOs with 8 tests**

## Performance

- **Duration:** 10 min
- **Started:** 2026-03-23T03:28:20Z
- **Completed:** 2026-03-23T03:38:12Z
- **Tasks:** 2
- **Files modified:** 14

## Accomplishments
- Non-destructive schema v10->v11 migration creating 2 new tables and adding 4 columns
- AllocationTargetDao with CRUD, stream watching, and atomic bulk replacement
- DecisionDao with CRUD, soft-delete, mark-implemented, and filtered stream watching
- GoalDao extended with watchByCategory for category-scoped goal queries
- 8 new DAO tests all passing, 968 total tests green

## Task Commits

Each task was committed atomically:

1. **Task 1: New tables, Goals extension, RecurringRules extension, schema v11 migration** - `e4fe338` (feat)
2. **Task 2: AllocationTargetDao, DecisionDao, GoalDao extension, DAO tests** - `5410221` (feat)

## Files Created/Modified
- `lib/core/database/tables/allocation_targets.dart` - AllocationTargets Drift table with basis-point allocations per age band
- `lib/core/database/tables/decisions.dart` - Decisions Drift table for what-if financial decision tracking
- `lib/core/database/daos/allocation_target_dao.dart` - DAO with CRUD, watchForProfile, replaceAllForProfile
- `lib/core/database/daos/decision_dao.dart` - DAO with CRUD, watchForUser, markImplemented, softDelete
- `lib/core/database/tables/goals.dart` - Added goalCategory, downPaymentPctBp, educationEscalationRateBp
- `lib/core/database/tables/recurring_rules.dart` - Added decisionId nullable column
- `lib/core/database/database.dart` - Schema v11 migration, new table registrations
- `lib/core/database/daos/goal_dao.dart` - Added watchByCategory method
- `test/core/database/daos/allocation_target_dao_test.dart` - 4 tests for AllocationTargetDao
- `test/core/database/daos/decision_dao_test.dart` - 4 tests for DecisionDao
- `test/core/database/migration_test.dart` - Updated schema version assertion to 11

## Decisions Made
- goalCategory uses text column with default 'investmentGoal' so existing rows get correct default without data migration
- Allocation percentages as basis-point integers (consistent with project-wide bp convention)
- Decisions table follows soft-delete pattern (deletedAt) matching LifeProfiles and NetWorthMilestones

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed Goal constructor in existing tests**
- **Found during:** Task 1 (after codegen)
- **Issue:** Adding goalCategory as a required field in the generated Goal class broke dashboard_screen_test.dart and goal_list_screen_test.dart which construct Goal objects directly
- **Fix:** Added `goalCategory: 'investmentGoal'` to both test helpers
- **Files modified:** test/features/dashboard/dashboard_screen_test.dart, test/features/goals/goal_list_screen_test.dart
- **Verification:** Both test files pass, all 968 tests green
- **Committed in:** e4fe338 (Task 1 commit)

---

**Total deviations:** 1 auto-fixed (1 bug fix)
**Impact on plan:** Required to maintain test suite integrity after schema change. No scope creep.

## Issues Encountered
None - plan executed cleanly after test fix.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Database layer complete for all Phase 8 plans
- AllocationTargetDao ready for glide-path persistence (Plan 03/04)
- DecisionDao ready for decision engine (Plan 03)
- GoalDao.watchByCategory ready for purchase planning UI (Plan 04)

---
*Phase: 08-asset-allocation-purchase-planning*
*Completed: 2026-03-23*
