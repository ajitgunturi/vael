---
phase: 06-life-profile-income-model
plan: 01
subsystem: database, financial
tags: [drift, dao, career-stage, basis-points, income-growth, projection]

requires:
  - phase: 04-advanced-features
    provides: projection_engine with ProjectionCashFlow
provides:
  - life_profiles Drift table (schema v9) with family+user-scoped DAO
  - IncomeGrowthEngine with career-stage-adjusted growth rates
  - Basis-point conversion helpers (bpToRate, bpToPercent, percentToBp)
  - CareerStage enum with multipliers
affects: [06-02, 06-03, fi-calculations, milestone-planning, allocation-engine]

tech-stack:
  added: []
  patterns: [basis-point integer storage, career-stage segmented trajectories, soft-delete via deletedAt]

key-files:
  created:
    - lib/core/database/tables/life_profiles.dart
    - lib/core/database/daos/life_profile_dao.dart
    - lib/core/financial/income_growth_engine.dart
    - test/core/database/daos/life_profile_dao_test.dart
    - test/core/financial/income_growth_engine_test.dart
  modified:
    - lib/core/database/database.dart
    - test/core/database/migration_test.dart

key-decisions:
  - "All rates stored as integer basis points (800 bp = 8%), converted at engine boundary"
  - "Career stage boundaries: Early=[20,30) 1.2x, Mid=[30,45) 1.0x, Late=[45,retirement) 0.6x"
  - "IncomeGrowthEngine is pure static -- no DB imports, no mutable state"

patterns-established:
  - "Basis-point storage: store rates as integer bp in DB, convert with bpToRate/bpToPercent at boundaries"
  - "Career-stage segmentation: buildSalaryTrajectory splits career into stage-aware ProjectionCashFlow segments"
  - "Soft delete pattern: deletedAt nullable column, DAO filters isNull by default"

requirements-completed: [LIFE-01, LIFE-02, LIFE-03, INCOME-01, INCOME-02]

duration: 8min
completed: 2026-03-22
---

# Phase 06 Plan 01: Life Profile & Income Growth Engine Summary

**life_profiles Drift table with family-scoped DAO (schema v9) + IncomeGrowthEngine producing career-stage-adjusted ProjectionCashFlow trajectories with basis-point rate storage**

## Performance

- **Duration:** 8 min
- **Started:** 2026-03-22T18:35:51Z
- **Completed:** 2026-03-22T18:43:42Z
- **Tasks:** 2
- **Files modified:** 7

## Accomplishments
- life_profiles table with 13 columns, schema migration v8->v9, composite index on (user_id, family_id)
- LifeProfileDao with watchForUser, watchAll, getForUser, upsertProfile, softDelete (7 tests)
- IncomeGrowthEngine with stageForAge, adjustedGrowthRate, buildSalaryTrajectory, bp helpers (21 tests)
- 28 total tests passing

## Task Commits

Each task was committed atomically:

1. **Task 1: Life profiles Drift table, DAO, and schema migration v8->v9** - `a082f05` (feat)
2. **Task 2: IncomeGrowthEngine with career-stage multipliers and bp helpers** - `58b7e30` (feat)

## Files Created/Modified
- `lib/core/database/tables/life_profiles.dart` - Drift table with 13 columns (id, userId, familyId, dateOfBirth, plannedRetirementAge, riskProfile, annualIncomeGrowthBp, expectedInflationBp, safeWithdrawalRateBp, hikeMonth, createdAt, updatedAt, deletedAt)
- `lib/core/database/daos/life_profile_dao.dart` - Family+user-scoped CRUD DAO with soft delete
- `lib/core/database/daos/life_profile_dao.g.dart` - Generated Drift mixin
- `lib/core/database/database.dart` - Schema v9, migration guard, index
- `lib/core/database/database.g.dart` - Regenerated database codegen
- `lib/core/financial/income_growth_engine.dart` - Pure static engine with CareerStage enum and bp helpers
- `test/core/database/daos/life_profile_dao_test.dart` - 7 DAO tests
- `test/core/financial/income_growth_engine_test.dart` - 21 engine tests
- `test/core/database/migration_test.dart` - Updated schema version assertion to 9

## Decisions Made
- All rates stored as integer basis points (800 bp = 8%), converted at engine boundary -- avoids floating-point drift in DB
- Career stage boundaries: Early=[20,30) 1.2x, Mid=[30,45) 1.0x, Late=[45,retirement) 0.6x -- matches Indian career progression
- IncomeGrowthEngine is pure static with no DB imports -- keeps financial math testable and reusable

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Updated migration_test schema version assertion**
- **Found during:** Task 1 (commit pre-commit hook)
- **Issue:** Existing test asserted schemaVersion == 8, now fails after bump to 9
- **Fix:** Changed assertion to expect 9
- **Files modified:** test/core/database/migration_test.dart
- **Verification:** Full test suite passes (836 tests, 0 failures)
- **Committed in:** a082f05 (Task 1 commit)

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** Necessary correction for schema version bump. No scope creep.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- life_profiles table and DAO ready for UI forms (Plan 02/03)
- IncomeGrowthEngine ready to feed ProjectionEngine.projectFromCashFlows for FI calculations
- Basis-point helpers available for all future rate storage

---
*Phase: 06-life-profile-income-model*
*Completed: 2026-03-22*
