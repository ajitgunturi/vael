---
phase: 06-life-profile-income-model
plan: 02
subsystem: financial-engine, database
tags: [projection-engine, income-growth, career-stage, secondary-income, golden-file, drift]

# Dependency graph
requires:
  - phase: 06-01
    provides: "IncomeGrowthEngine with buildSalaryTrajectory and career-stage multipliers"
provides:
  - "threeScenariosCashFlowWithIncomeSpread method on ProjectionEngine"
  - "Precision assertion guard (runningNW < 2^53) in projectFromCashFlows"
  - "Golden-file precision tests at 25yr and 40yr horizons"
  - "isSecondaryIncome boolean column on recurring_rules table"
  - "watchSecondaryIncome DAO query method"
affects: [06-03, projections-ui, recurring-rules-ui]

# Tech tracking
tech-stack:
  added: []
  patterns: ["callback-based scenario builder (buildIncomeFlows function parameter avoids coupling)", "precision assertion guard for long-range financial projections"]

key-files:
  created:
    - test/core/financial/projection_engine_extended_test.dart
  modified:
    - lib/core/financial/projection_engine.dart
    - lib/core/database/tables/recurring_rules.dart
    - lib/core/database/database.dart
    - lib/core/database/daos/recurring_rule_dao.dart
    - lib/core/database/database.g.dart
    - test/core/database/daos/recurring_rule_dao_test.dart

key-decisions:
  - "threeScenariosCashFlowWithIncomeSpread uses callback pattern (buildIncomeFlows function) to avoid coupling ProjectionEngine to IncomeGrowthEngine"
  - "Income growth spread is +/-2% (matching return rate spread) for symmetric scenario generation"
  - "isSecondaryIncome added to v8->v9 migration block alongside life_profiles table creation"
  - "watchSecondaryIncome filters on isSecondaryIncome=true + deletedAt IS NULL (no kind filter)"

patterns-established:
  - "Callback-based scenario builders: pass growth-rate-to-flows function rather than coupling engine classes"
  - "Precision assertions in financial loops: guard against silent overflow above 2^53"

requirements-completed: [INCOME-03, INCOME-04]

# Metrics
duration: 16min
completed: 2026-03-22
---

# Phase 06 Plan 02: Projection + Income Integration Summary

**Career-aware income projection with 3-scenario growth spread, precision guards, golden-file tests at 25yr/40yr, and isSecondaryIncome tagging on recurring rules**

## Performance

- **Duration:** 16 min
- **Started:** 2026-03-22T18:46:45Z
- **Completed:** 2026-03-22T19:03:39Z
- **Tasks:** 2
- **Files modified:** 7

## Accomplishments
- Extended projection engine with `threeScenariosCashFlowWithIncomeSpread` that varies both income growth (+/-2%) and return rate (+/-2%) across scenarios
- Added precision assertion guard to prevent silent double-precision overflow beyond 2^53 in long-range projections
- Golden-file tests validate deterministic 25-year and 40-year projection results within 1 rupee tolerance
- Added `isSecondaryIncome` boolean column to recurring_rules with DB migration and `watchSecondaryIncome` DAO query

## Task Commits

Each task was committed atomically:

1. **Task 1: Extend projection engine with career-aware income scenarios and golden-file precision tests** - `39334d6` (feat)
2. **Task 2: Add isSecondaryIncome column to recurring_rules for side income tagging** - `e5eddea` (feat)

## Files Created/Modified
- `lib/core/financial/projection_engine.dart` - Added threeScenariosCashFlowWithIncomeSpread method + precision assertion
- `test/core/financial/projection_engine_extended_test.dart` - 6 tests: golden-file 25yr/40yr, 3-scenario spread, precision guards
- `lib/core/database/tables/recurring_rules.dart` - Added isSecondaryIncome boolean column (default false)
- `lib/core/database/database.dart` - Added column to v8->v9 migration
- `lib/core/database/database.g.dart` - Regenerated drift code
- `lib/core/database/daos/recurring_rule_dao.dart` - Added watchSecondaryIncome query
- `test/core/database/daos/recurring_rule_dao_test.dart` - 4 new tests for isSecondaryIncome

## Decisions Made
- Callback pattern for `buildIncomeFlows` avoids coupling ProjectionEngine to IncomeGrowthEngine
- Income growth spread at +/-2% matches return rate spread for symmetric scenarios
- watchSecondaryIncome does not filter on `kind='income'` -- the flag is a tag independent of kind

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed Plan 01 wizard save test (pumpAndSettle timing)**
- **Found during:** Task 1 (pre-commit hook running full test suite)
- **Issue:** Life profile wizard "saving calls upsertProfile" test failed because async _save() needed explicit pump timing and buttons needed ensureVisible due to Stepper layout
- **Fix:** Added ensureVisible for step navigation, increased surface size, added pump with duration after save tap
- **Files modified:** test/features/planning/screens/life_profile_wizard_screen_test.dart
- **Verification:** All 8 planning tests pass
- **Committed in:** 39334d6 (Task 1 commit)

**2. [Rule 1 - Bug] Fixed settings screen tests (Sign Out and app version scroll)**
- **Found during:** Task 1 (pre-commit hook running full test suite)
- **Issue:** New "Financial Planning" section in settings pushed Sign Out and App Info below viewport fold, breaking tap/find assertions
- **Fix:** Added ensureVisible before Sign Out tap, scrollUntilVisible for app version section
- **Files modified:** test/features/settings/settings_screen_test.dart, test/integration/phase5_e2e_test.dart
- **Verification:** All 10 settings tests and E2E Sign Out test pass
- **Committed in:** 39334d6 (Task 1 commit)

**3. [Rule 3 - Blocking] Included uncommitted Plan 01 UI files**
- **Found during:** Task 1 (pre-commit format check)
- **Issue:** Plan 01 UI files (wizard screen, providers, widgets, settings integration) were created but not committed
- **Fix:** Staged and committed alongside Task 1
- **Files modified:** lib/features/planning/ (screens, providers, widgets), lib/features/settings/screens/settings_screen.dart
- **Committed in:** 39334d6 (Task 1 commit)

---

**Total deviations:** 3 auto-fixed (2 bugs, 1 blocking)
**Impact on plan:** All fixes necessary for pre-commit hook to pass. No scope creep.

## Issues Encountered
- Pre-commit hook runs full test suite (875 tests) on every commit, which requires all tests to pass including unrelated ones affected by Plan 01 UI changes

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Projection engine now supports career-aware income scenarios -- ready for Plan 03 (savings allocation engine)
- isSecondaryIncome column available for recurring rules UI enhancement

---
*Phase: 06-life-profile-income-model*
*Completed: 2026-03-22*
