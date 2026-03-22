# Architecture Patterns

**Domain:** Financial planning intelligence layer for existing Flutter finance app
**Researched:** 2026-03-22

## Existing Architecture (Baseline)

The app follows a strict layered architecture that the planning layer must respect:

```
shared/          Theme, Layout (AdaptiveScaffold), Widgets (EmptyState, SkeletonLoading)
  |
features/        14 feature modules, each with providers/ screens/ widgets/
  |
core/            database/ (Drift + DAOs), financial/ (pure math engines),
                 models/, providers/, crypto/, auth/, sync/
```

**Key conventions already established:**
- Pure financial engines in `core/financial/` (no DB access, pure functions)
- DAOs in `core/database/daos/` (Drift-generated, family-scoped queries)
- Feature providers in `features/{name}/providers/` (Riverpod, wire DAOs to engines)
- Navigation: imperative `Navigator.of(context).push(MaterialPageRoute(...))` throughout
- Dashboard cards with `Navigator.push` to sub-features (projections, investments, recurring)
- 5-tab HomeShell (Dashboard, Accounts, Transactions, Budget, Goals) -- no new tabs allowed
- All amounts in paise (integer), rates in doubles, family-scoped via `familyId`

## Recommended Architecture for Planning Layer

### Principle: Engines are Pure, Providers Wire, Screens Consume

The planning layer follows the exact same pattern as the existing projection engine, goal tracking, and dashboard aggregation. No architectural novelty needed -- just more of the same pattern applied to new domains.

### Component Boundaries

| Component | Layer | Responsibility | Communicates With |
|-----------|-------|---------------|-------------------|
| **LifeProfileTable + DAO** | `core/database` | Store DOB, retirement age, risk profile, growth assumptions | LifeProfileProvider |
| **NetWorthMilestonesTable + DAO** | `core/database` | Store decade-level NW targets, on-track status | MilestoneEngine |
| **SinkingFundsTable + DAO** | `core/database` | Short-term savings buckets (name, target, saved, deadline) | SinkingFundProvider |
| **CashTiersTable + DAO** | `core/database` | Account-to-tier classification (immediate/short/medium) | CashTierProvider |
| **SavingsAllocationRulesTable + DAO** | `core/database` | Priority-ordered surplus distribution rules | AllocationEngine |
| **EmergencyFundConfigTable + DAO** | `core/database` | Target months, income stability, linked accounts | EmergencyFundEngine |
| **PurchasePlansTable + DAO** | `core/database` | Major purchases with loan EMI impact modeling | PurchasePlannerEngine |
| **FICalculatorEngine** | `core/financial` | FI number, years-to-FI, Coast FI (pure math, no DB) | FIProvider |
| **MilestoneEngine** | `core/financial` | Net worth milestones by decade, on-track/behind/ahead | MilestoneProvider |
| **AllocationEngine** | `core/financial` | Compute priority-ordered surplus distribution | AllocationProvider |
| **EmergencyFundEngine** | `core/financial` | Months covered, target by income stability | EmergencyFundProvider |
| **AssetAllocationEngine** | `core/financial` | Glide path targets by age band, current vs target delta | AllocationProvider |
| **CashFlowCalendarEngine** | `core/financial` | Day-by-day income/expense map from recurring rules | CashFlowCalendarProvider |
| **IncomeGrowthEngine** | `core/financial` | Salary trajectory by career stage | IncomeGrowthProvider |
| **PurchasePlannerEngine** | `core/financial` | Loan EMI impact on projections, affordability score | PurchasePlanProvider |
| **PlanningDashboardProvider** | `features/planning` | Aggregate "5 numbers" health view | PlanningDashboardScreen |
| **CashManagementProvider** | `features/cash_management` | Aggregate emergency fund + tiers + sinking funds | CashManagementScreen |

### New Feature Modules

```
features/
  planning/              # Long-term financial planning
    providers/
      life_profile_provider.dart
      fi_calculator_provider.dart
      milestone_provider.dart
      allocation_provider.dart
      income_growth_provider.dart
      purchase_plan_provider.dart
      planning_dashboard_provider.dart
      timeline_provider.dart
    screens/
      life_profile_screen.dart         # DOB, retirement, risk profile setup
      fi_calculator_screen.dart        # FI number, years-to-FI, Coast FI
      milestone_screen.dart            # Decade milestones + status
      asset_allocation_screen.dart     # Current vs target allocation
      income_growth_screen.dart        # Salary trajectory modeling
      purchase_planner_screen.dart     # Major purchase + EMI impact
      planning_dashboard_screen.dart   # "5 numbers" unified view
      lifetime_timeline_screen.dart    # Decades, milestones, FI date
    widgets/
      fi_gauge_widget.dart
      milestone_progress_bar.dart
      allocation_pie_chart.dart
      purchase_impact_card.dart
      timeline_decade_strip.dart

  cash_management/       # Short-term cash health
    providers/
      emergency_fund_provider.dart
      cash_tier_provider.dart
      sinking_fund_provider.dart
      cash_flow_calendar_provider.dart
      savings_allocation_provider.dart
      savings_rate_provider.dart
      cash_health_provider.dart
    screens/
      emergency_fund_screen.dart       # Target, linked accounts, months covered
      cash_tier_screen.dart            # Account-to-tier classification
      sinking_fund_screen.dart         # Short-term savings buckets CRUD
      cash_flow_calendar_screen.dart   # Day-by-day map + threshold alerts
      savings_allocation_screen.dart   # Priority-ordered surplus rules
      savings_rate_screen.dart         # 12-month trend + health bands
      cash_health_screen.dart          # Summary waterfall view
    widgets/
      emergency_gauge_widget.dart
      tier_bar_chart.dart
      sinking_fund_card.dart
      calendar_day_cell.dart
      waterfall_chart.dart
```

## Data Flow

### Pattern 1: Pure Engine Composition (follow existing ProjectionEngine pattern)

All financial engines are pure functions. No DB access. Providers wire DAO streams to engines.

```
DAO.watchX(familyId) → Stream<List<Row>>
  ↓
Provider (Riverpod StreamProvider.family)
  → reads DAO stream
  → calls pure Engine.compute(...)
  → emits computed result
  ↓
Screen (ConsumerWidget)
  → ref.watch(provider(familyId))
  → .when(data:, loading:, error:)
```

**Example -- FI Calculator flow:**

```dart
// core/financial/fi_calculator_engine.dart (PURE, no imports from core/database)
class FICalculatorEngine {
  FICalculatorEngine._();

  /// Annual expenses * multiplier (typically 25x for 4% rule)
  static int fiNumber({required int annualExpenses, double withdrawalRate = 0.04}) {
    return (annualExpenses / withdrawalRate).round();
  }

  /// Months until net worth reaches FI number
  static int yearsToFI({
    required int currentNetWorth,
    required int fiNumber,
    required int monthlySavings,
    required double annualReturnRate,
  }) { ... }
}
```

```dart
// features/planning/providers/fi_calculator_provider.dart
final fiDataProvider = StreamProvider.family<FIData, String>((ref, familyId) {
  final db = ref.watch(databaseProvider);
  final accountDao = AccountDao(db);
  final transactionDao = TransactionDao(db);
  final lifeProfileDao = LifeProfileDao(db);

  return accountDao.watchAll(familyId).asyncMap((accounts) async {
    final netWorth = DashboardAggregation.computeNetWorth(accounts);
    final profile = await lifeProfileDao.get(familyId);
    final expenses = await transactionDao.getMonthlyAverage(familyId, months: 6);

    return FIData(
      fiNumber: FICalculatorEngine.fiNumber(annualExpenses: expenses * 12),
      yearsToFI: FICalculatorEngine.yearsToFI(
        currentNetWorth: netWorth,
        fiNumber: ...,
        monthlySavings: ...,
        annualReturnRate: profile.expectedReturnRate,
      ),
    );
  });
});
```

### Pattern 2: Cross-Feature Data Consumption

New engines consume existing data via providers, never by direct DAO cross-wiring.

```
Existing DAOs (AccountDao, TransactionDao, RecurringRuleDao, GoalDao)
  ↓ watched by existing providers
  ↓
New providers compose existing + new DAOs
  ↓
New engines receive primitive data (ints, lists), not DB types
```

**Critical rule:** Planning engines NEVER import from `core/database`. They receive pre-computed integers and lists. This keeps engines testable without DB mocking.

### Pattern 3: Dashboard Integration via Cards

The existing dashboard uses `Navigator.push` from quick-action buttons. Planning features surface the same way:

```
DashboardScreen
  └─ _PlanningHealthCard (NEW)
     ├─ Shows: FI progress %, savings rate, emergency months
     ├─ onTap → Navigator.push(PlanningDashboardScreen)
     └─ Provider: planningHealthSummaryProvider(familyId)
```

No new tabs. Planning and cash management are accessed via:
1. Dashboard cards (primary entry point)
2. Settings section entries (secondary)
3. Cross-screen deep links (e.g., account detail -> cash tier classification)

### Pattern 4: Schema Migration (Additive Only)

```
Current: schemaVersion = 8, 15 tables

Phase 6 (Planning): schemaVersion = 9
  + life_profiles table
  + net_worth_milestones table
  + purchase_plans table

Phase 7 (Cash Management): schemaVersion = 10
  + emergency_fund_configs table
  + cash_tiers table
  + sinking_funds table
  + savings_allocation_rules table

Modifications (both phases):
  accounts: add cashTier column (nullable TextColumn, default null)
  goals: add linkedInvestmentId column (nullable, resolves M5 gap)
```

Migration strategy follows existing pattern in `database.dart`:

```dart
if (from < 9) {
  await m.createTable(lifeProfiles);
  await m.createTable(netWorthMilestones);
  await m.createTable(purchasePlans);
}
if (from < 10) {
  await m.createTable(emergencyFundConfigs);
  await m.createTable(cashTiers);
  await m.createTable(sinkingFunds);
  await m.createTable(savingsAllocationRules);
  await m.addColumn(accounts, accounts.cashTier);
}
```

## Anti-Patterns to Avoid

### Anti-Pattern 1: Engine-DAO Coupling
**What:** Financial engine importing DAO or database types directly.
**Why bad:** Makes engines untestable without DB, breaks pure-function contract, creates circular dependencies.
**Instead:** Engines receive primitives. Providers do the wiring.

### Anti-Pattern 2: Cross-Feature Direct Import
**What:** `features/planning/` importing from `features/cash_management/` providers.
**Why bad:** Creates horizontal coupling between feature modules. Changes in one break the other.
**Instead:** Both features read from shared `core/` layer. If they need each other's computed data, extract a shared engine to `core/financial/`.

### Anti-Pattern 3: New Navigation Paradigm
**What:** Introducing GoRouter, auto_route, or declarative navigation alongside existing imperative Navigator.push.
**Why bad:** Two navigation systems = maintenance burden, test fragility, inconsistent back-button behavior.
**Instead:** Stay with imperative `Navigator.of(context).push(MaterialPageRoute(...))`. It works, all 32+ existing navigation tests use it, and the app is not complex enough to justify a router.

### Anti-Pattern 4: God Provider
**What:** Single `planningProvider` that loads all planning data at once.
**Why bad:** Slow initial load, unnecessary re-renders, memory waste when user only visits one sub-screen.
**Instead:** One provider per screen/concern. `fiDataProvider`, `milestoneProvider`, `allocationProvider` etc. are independent streams.

### Anti-Pattern 5: Mutable Engine State
**What:** Engine class with fields that accumulate state across calls.
**Why bad:** Non-deterministic results, hard to test, thread-unsafe.
**Instead:** All engines use `ClassName._()` private constructor with only static methods (matching existing `FinancialMath`, `ProjectionEngine`, `GoalTracking` pattern).

## Suggested Build Order (Dependency-Driven)

### Phase 6: Planning Foundation (must come first)

**Build order within phase:**

1. **Life Profile table + DAO + screen** -- No dependencies. Other engines need this data (DOB for age-band allocation, retirement age for FI horizon). Build first.

2. **FI Calculator engine + provider + screen** -- Depends on: life profile (retirement age), existing accounts (net worth), existing transactions (monthly expenses). Pure math, high-value screen.

3. **Milestone engine + provider + screen** -- Depends on: life profile (DOB for decade calculation), existing accounts (net worth). Consumes FI number for FI-date milestone.

4. **Asset Allocation engine + provider + screen** -- Depends on: life profile (DOB for age band, risk profile), existing investment holdings (current allocation). Deterministic glide path tables.

5. **Income Growth engine + provider + screen** -- Depends on: life profile (career stage). Feeds into projection engine enhancement (C7 gap resolution).

6. **Purchase Planner engine + provider + screen** -- Depends on: life profile, existing loan details (amortization engine), existing goals (M5 gap: goal-investment linking). Most cross-cutting, build last.

7. **Enhanced Projection Engine** -- Wire life profile + income growth + recurring rules into existing `ProjectionEngine.projectFromCashFlows()`. Resolves C7 gap.

8. **Planning Dashboard + Timeline** -- Aggregation screens. Depend on all above engines being complete. Build last in phase.

### Phase 7: Cash Management (depends on Phase 6 life profile)

**Build order within phase:**

1. **Emergency Fund engine + table + screen** -- Depends on: life profile (income stability), existing accounts (linked account balances). Standalone, build first.

2. **Cash Tier classification + table + screen** -- Depends on: existing accounts. Adds `cashTier` column. Account-detail cross-link.

3. **Sinking Funds table + CRUD screen** -- No dependencies on other new features. Simple CRUD similar to existing goals. Build early.

4. **Balance Snapshot scheduler fix** -- Resolves C10 gap. Needed for savings rate trend. Wire existing `BalanceSnapshotScheduler` to actually create snapshots.

5. **Savings Rate trend + screen** -- Depends on: balance snapshots (C10), existing transactions. 12-month history calculation.

6. **Cash Flow Calendar engine + screen** -- Depends on: existing recurring rules (dates + amounts), existing transactions. Day-by-day map.

7. **Savings Allocation engine + rules + screen** -- Depends on: emergency fund (priority 1), sinking funds (priority 2+), existing goals. Advisory distribution of surplus.

8. **Cash Health dashboard** -- Aggregation screen. Depends on all above. Build last.

### Phase 8: Integration (depends on Phases 6 + 7)

1. **Planning insights engine** -- Deterministic threshold alerts from all planning data.
2. **Dashboard card integration** -- Planning health card + cash health card on main dashboard.
3. **Cross-feature navigation** -- Deep links between account detail and cash tier, goal detail and purchase planner, etc.
4. **32 navigation integration tests** -- All screens reachable from HomeShell. Three breakpoints.

## Scalability Considerations

| Concern | Current Scale | Planning Layer Impact | Mitigation |
|---------|--------------|----------------------|------------|
| DB queries | ~15 tables, simple family-scoped queries | +7 tables, same query patterns | No concern -- Drift handles this fine |
| Provider count | ~20 providers | +15-20 providers | Each is independent stream, Riverpod disposes unused. No concern. |
| Screen count | ~15 screens | +15 screens | All behind Navigator.push, no preloading. No concern. |
| Engine computation | Projection engine: 60-month loop | FI calculator: simple division. Milestone: loop over decades. Allocation: sort + iterate. | All sub-millisecond. No concern. |
| Navigation depth | Max 2 levels (tab -> detail) | Max 3 levels (tab -> planning dashboard -> FI detail) | Standard Flutter navigator stack. No concern up to 5-6 levels. |

## Navigation Integration Strategy

The app has 5 tabs. New features cannot add tabs (decision from PROJECT.md). Integration points:

```
HomeShell (5 tabs)
  ├── Dashboard (tab 0)
  │   ├── [existing] Quick Actions → Projections, Investments, Recurring
  │   ├── [NEW] Planning Health Card → PlanningDashboardScreen
  │   │   ├── FI Calculator Screen
  │   │   ├── Milestone Screen
  │   │   ├── Asset Allocation Screen
  │   │   ├── Income Growth Screen
  │   │   ├── Purchase Planner Screen
  │   │   └── Lifetime Timeline Screen
  │   └── [NEW] Cash Health Card → CashHealthScreen
  │       ├── Emergency Fund Screen
  │       ├── Cash Tier Screen
  │       ├── Sinking Fund Screen
  │       ├── Cash Flow Calendar Screen
  │       ├── Savings Allocation Screen
  │       └── Savings Rate Screen
  ├── Accounts (tab 1)
  │   └── Account Detail
  │       └── [NEW] Cash Tier badge + tap to classify
  ├── Settings
  │   └── [NEW] Life Profile entry (DOB, retirement, risk)
  └── Goals (tab 4)
      └── Goal Detail
          └── [NEW] Link to Purchase Planner (if major purchase goal)
```

## Sync Implications

All new tables must participate in the existing changeset-based sync:
- Each new DAO must emit to `SyncChangelog` on insert/update/delete
- New tables are encrypted at rest via SQLCipher (automatic, same DB)
- Changeset format is additive -- new table types in changelog are backward-compatible (old clients ignore unknown table types)
- No sync schema changes needed, only new `tableType` enum values in changelog entries

## Sources

- Existing codebase analysis (HIGH confidence -- direct code inspection)
- Drift ORM migration patterns from existing `database.dart` (HIGH confidence)
- Riverpod provider patterns from existing `dashboard_providers.dart` (HIGH confidence)
- Flutter navigation patterns from existing codebase (HIGH confidence)
- PROJECT.md constraints and gap analysis (HIGH confidence)
