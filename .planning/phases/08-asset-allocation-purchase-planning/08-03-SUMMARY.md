---
phase: 08-asset-allocation-purchase-planning
plan: 03
subsystem: financial-engine
tags: [decision-modeler, fi-calculator, purchase-planner, tax-computation, riverpod, providers]

requires:
  - phase: 08-01
    provides: AllocationEngine, PurchasePlannerEngine, IndianTaxConstants
  - phase: 08-02
    provides: AllocationTargetDao, DecisionDao, GoalDao.watchByCategory
  - phase: 07
    provides: FiCalculator, MilestoneEngine, IncomeGrowthEngine
provides:
  - DecisionModelerEngine with computeImpact for all 6 decision types
  - Sealed DecisionParameters hierarchy (JobChange, SalaryNegotiation, MajorPurchase, InvestmentWithdrawal, RentalChange, Custom)
  - DecisionImpact with FI delay, cash flow, NW milestones, tax implications
  - Riverpod providers for allocation, purchase goals, and decisions
  - DAO providers for investmentHolding, allocationTarget, goal, decision
affects: [08-04, 08-05]

tech-stack:
  added: []
  patterns: [sealed-class-params, composition-engine, import-alias-for-name-conflicts]

key-files:
  created:
    - lib/core/financial/decision_modeler.dart
    - lib/features/planning/providers/allocation_provider.dart
    - lib/features/planning/providers/purchase_provider.dart
    - lib/features/planning/providers/decision_provider.dart
    - test/core/financial/decision_modeler_test.dart
    - test/features/planning/providers/allocation_provider_test.dart
    - test/features/planning/providers/purchase_provider_test.dart
    - test/features/planning/providers/decision_provider_test.dart

key-decisions:
  - "DecisionModelerEngine uses Dart sealed class for DecisionParameters with 6 subtypes, enabling exhaustive switch"
  - "STCG/LTCG tax computed deterministically using IndianTaxConstants (simplified: gain == withdrawal amount)"
  - "Debt withdrawal tax uses flat 30% slab assumption (no slab engine yet)"
  - "Import alias (db prefix) resolves AllocationTarget name conflict between engine model and drift data class"
  - "NW milestones computed at fixed decade ages [30,40,50,60,70] filtered by currentAge"

patterns-established:
  - "Sealed class hierarchy for typed parameter variants (switch exhaustiveness)"
  - "Import alias pattern for drift vs engine model name conflicts"

requirements-completed: [PURCH-02, PURCH-03]

duration: 9min
completed: 2026-03-23
---

# Phase 08 Plan 03: Decision Modeler Engine + Providers Summary

**DecisionModelerEngine composing FiCalculator/PurchasePlanner/MilestoneEngine for 6 decision types with STCG/LTCG tax, plus Riverpod providers for allocation/purchase/decisions**

## Performance

- **Duration:** 9 min
- **Started:** 2026-03-23T03:41:36Z
- **Completed:** 2026-03-23T03:50:08Z
- **Tasks:** 2
- **Files modified:** 8

## Accomplishments
- DecisionModelerEngine handles all 6 decision types (jobChange, salaryNegotiation, majorPurchase, investmentWithdrawal, rentalChange, custom) by composing existing engines
- Deterministic STCG/LTCG tax computation with exemption for equity investment withdrawals
- NW impact at milestone ages [30,40,50,60,70] computed via MilestoneEngine for all decision types
- 3 provider files with reactive streams wiring engines to DAOs
- 19 total tests (11 engine + 8 provider) all passing

## Task Commits

Each task was committed atomically:

1. **Task 1: DecisionModelerEngine with TDD** - `b456222` (feat)
2. **Task 2: Riverpod providers + provider tests** - `8f053d3` (feat)

## Files Created/Modified
- `lib/core/financial/decision_modeler.dart` - Sealed DecisionParameters, DecisionImpact, DecisionModelerEngine.computeImpact
- `lib/features/planning/providers/allocation_provider.dart` - currentAllocation, targetAllocation, customAllocationTargets, rebalancingDeltas providers
- `lib/features/planning/providers/purchase_provider.dart` - purchaseGoals (category-filtered stream), purchaseImpact providers
- `lib/features/planning/providers/decision_provider.dart` - decisions (stream), decisionImpact (sync) providers
- `test/core/financial/decision_modeler_test.dart` - 11 tests covering all 6 decision types + edge cases
- `test/features/planning/providers/allocation_provider_test.dart` - 3 tests for allocation providers
- `test/features/planning/providers/purchase_provider_test.dart` - 2 tests for purchase providers
- `test/features/planning/providers/decision_provider_test.dart` - 3 tests for decision providers

## Decisions Made
- Used Dart sealed class for DecisionParameters enabling exhaustive pattern matching in switch expression
- Simplified tax model: gain equals withdrawal amount (no cost basis tracking yet)
- Debt withdrawal tax uses flat 30% slab assumption since no income slab engine exists
- Used `import 'database.dart' as db` alias to resolve AllocationTarget naming conflict between drift data class and engine model
- NW milestones at decade ages consistent with MilestoneEngine.defaultTargets pattern

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- DecisionModelerEngine and all providers ready for UI consumption in Plan 04 (screens)
- Provider wiring tested with ProviderContainer + in-memory DB overrides

---
*Phase: 08-asset-allocation-purchase-planning*
*Completed: 2026-03-23*
