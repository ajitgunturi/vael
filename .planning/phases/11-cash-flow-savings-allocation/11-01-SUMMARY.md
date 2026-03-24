---
phase: 11-cash-flow-savings-allocation
plan: 01
subsystem: financial-engine, database
tags: [cash-flow, savings-allocation, drift, paise, threshold-alerts, priority-distribution]

requires:
  - phase: 09-emergency-fund-cash-tiers
    provides: EmergencyFundEngine pure static pattern, isEmergencyFund account column
  - phase: 10-sinking-funds-savings-rate
    provides: SinkingFundEngine pure static pattern, MonthlyMetrics table

provides:
  - CashFlowEngine with day-by-day per-account running balance projection and threshold alerts
  - SavingsAllocationEngine with priority-ordered surplus distribution (fixed/percentage)
  - SavingsAllocationRules drift table with DAO (CRUD, watchByFamily, reorderPriorities)
  - Account columns for opportunity fund designation and minimum balance thresholds
  - Schema v14 migration

affects: [11-02 (cash flow UI), 11-03 (savings allocation UI)]

tech-stack:
  added: []
  patterns: [pure-static-engine-with-private-constructor, priority-ordered-allocation, threshold-alert-with-date]

key-files:
  created:
    - lib/core/financial/cash_flow_engine.dart
    - lib/core/financial/savings_allocation_engine.dart
    - lib/core/database/tables/savings_allocation_rules.dart
    - lib/core/database/daos/savings_allocation_rule_dao.dart
    - test/core/financial/cash_flow_engine_test.dart
    - test/core/financial/savings_allocation_engine_test.dart
  modified:
    - lib/core/database/tables/accounts.dart
    - lib/core/database/database.dart
    - lib/core/database/daos/account_dao.dart
    - lib/core/providers/database_providers.dart
    - test/core/database/migration_test.dart

key-decisions:
  - "CashFlowEngine groups items by date, applies in order, snapshots running balances per day"
  - "SavingsAllocationEngine uses targetPaise=0 convention for unlimited opportunity fund absorption"
  - "ThresholdAlert includes DateTime date field for locked alert text format display"
  - "Allocation targets keyed by '$targetType:$targetId' string for map lookup"

patterns-established:
  - "Threshold alert pattern: alert contains the date of the dip for UI display"
  - "Allocation priority pattern: rules sorted by priority, surplus consumed in order"
  - "Opportunity fund unlimited pattern: targetPaise=0 means absorb all remaining surplus"

requirements-completed: [FLOW-01, FLOW-02, FLOW-03, SAVE-01, SAVE-02, SAVE-03, OPP-01, OPP-03]

duration: 9min
completed: 2026-03-24
---

# Phase 11 Plan 01: Engines & Data Foundation Summary

**CashFlowEngine for day-by-day per-account balance projection with threshold alerts, SavingsAllocationEngine for priority-ordered surplus distribution, schema v14 with savings_allocation_rules table**

## Performance

- **Duration:** 9 min
- **Started:** 2026-03-24T09:16:59Z
- **Completed:** 2026-03-24T09:26:00Z
- **Tasks:** 2
- **Files modified:** 17

## Accomplishments
- CashFlowEngine projects running balances per account with threshold alerts including dip date
- SavingsAllocationEngine distributes surplus by priority with fixed and percentage modes, skipping met targets
- Schema v14 adds savings_allocation_rules table and three new account columns
- SavingsAllocationRuleDao with CRUD, watchByFamily, and atomic reorderPriorities
- AccountDao extended with opportunity fund and threshold methods
- 17 engine unit tests + 118 database tests passing

## Task Commits

Each task was committed atomically:

1. **Task 1: CashFlowEngine + SavingsAllocationEngine with TDD** - `810ce87` (feat)
2. **Task 2: Schema v14 migration + table + DAO** - `7516eb1` (feat)

_Note: Task 1 used TDD flow (RED -> GREEN commits)_

## Files Created/Modified
- `lib/core/financial/cash_flow_engine.dart` - Day-by-day cash flow projection engine with CashFlowItem, DayProjection, ThresholdAlert
- `lib/core/financial/savings_allocation_engine.dart` - Priority-ordered surplus distribution with AllocationRule, AllocationTarget, AllocationAdvice
- `lib/core/database/tables/savings_allocation_rules.dart` - Drift table for savings allocation rules
- `lib/core/database/daos/savings_allocation_rule_dao.dart` - DAO with CRUD, watchByFamily, reorderPriorities
- `lib/core/database/tables/accounts.dart` - Added isOpportunityFund, opportunityFundTargetPaise, minimumBalancePaise
- `lib/core/database/database.dart` - Schema v14 migration, table registration
- `lib/core/database/daos/account_dao.dart` - watchOpportunityFund, setOpportunityFund, clearOpportunityFund, setMinimumBalance, getThresholds
- `lib/core/providers/database_providers.dart` - savingsAllocationRuleDaoProvider
- `test/core/financial/cash_flow_engine_test.dart` - 8 unit tests for projection engine
- `test/core/financial/savings_allocation_engine_test.dart` - 9 unit tests for allocation engine

## Decisions Made
- CashFlowEngine groups items by date using collection groupBy, processes dates ascending
- SavingsAllocationEngine targets keyed by `$targetType:$targetId` string for efficient lookup
- ThresholdAlert includes DateTime date field for locked alert text format display
- Opportunity fund uses targetPaise=0 convention to mean unlimited absorption
- Percentage allocation uses basis points (surplusPaise * percentageBp ~/ 10000) for integer math

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed Account constructor calls in 4 test files for new required isOpportunityFund field**
- **Found during:** Task 2 (schema migration)
- **Issue:** Drift codegen made isOpportunityFund a required parameter on Account data class, breaking existing test helpers
- **Fix:** Added isOpportunityFund: false (and nullable fields where needed) to Account constructors in budget_summary_test, account_list_screen_test, account_list_icons_test, statement_import_test, emergency_fund_provider_test
- **Files modified:** 5 test files
- **Verification:** flutter analyze passes with no errors
- **Committed in:** 7516eb1 (Task 2 commit)

**2. [Rule 1 - Bug] Updated migration_test schema version assertion from 13 to 14**
- **Found during:** Task 2 (schema migration)
- **Issue:** Existing test asserted schemaVersion == 13, which failed after bump to 14
- **Fix:** Changed assertion to expect 14
- **Files modified:** test/core/database/migration_test.dart
- **Verification:** All 118 database tests pass
- **Committed in:** 7516eb1 (Task 2 commit)

---

**Total deviations:** 2 auto-fixed (2 bugs from schema change)
**Impact on plan:** Both auto-fixes necessary for correctness after schema change. No scope creep.

## Issues Encountered
None beyond the auto-fixed test updates.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Engines and data layer ready for 11-02 (cash flow projection UI with recurring scheduler integration)
- SavingsAllocationRuleDao ready for 11-03 (allocation UI with rule management)
- Account threshold columns ready for cash flow alert display

---
*Phase: 11-cash-flow-savings-allocation*
*Completed: 2026-03-24*
