# Roadmap: Vael Financial Planning Extension

## Overview

This roadmap extends Vael's existing 5-phase foundation (multi-account management, encrypted sync, budgets, goals, projections, investments, reconciliation, app shell) with a financial planning intelligence layer and cash management system. The extension builds 8 new pure-math engines, 7 new Drift tables, and ~15 new screens across Phases 6-13. The dependency chain flows from Life Profile (root) through parallel planning and cash management tracks, converging at aggregation dashboards and cross-feature integration.

## Milestones

- v1.0 Foundation (Phases 1-5) -- SHIPPED
- v2.0 Financial Planning Extension (Phases 6-13) -- IN PROGRESS

## Phases

**Phase Numbering:**
- Phases 1-5: Completed foundation (not shown in detail)
- Phases 6-13: Financial Planning Extension (current scope)
- Decimal phases (e.g., 7.1): Urgent insertions if needed

- [x] **Phase 6: Life Profile & Income Model** - User establishes personal financial identity and income trajectory
- [x] **Phase 7: FI Calculator & Net Worth Milestones** - User can see their FI number and decade-by-decade wealth trajectory (completed 2026-03-22)
- [x] **Phase 8: Asset Allocation & Purchase Planning** - User can see allocation targets, model major purchase impact, and simulate life decisions with the Decision Modeling Framework (completed 2026-03-23)
- [x] **Phase 9: Emergency Fund & Cash Tiers** - User has safety-net tracking with liquidity classification (completed 2026-03-23)
- [x] **Phase 10: Sinking Funds & Savings Rate** - User can track short-term savings goals and monitor savings health (completed 2026-03-24)
- [x] **Phase 11: Cash Flow & Savings Allocation** - User can see daily cash flow and get advisory surplus distribution (completed 2026-03-24)
- [ ] **Phase 12: Planning Dashboard & Lifetime Timeline** - User has unified financial health view and visual life plan
- [ ] **Phase 13: Planning Insights & Integration Polish** - Deterministic alerts and cross-feature navigation coherence

## Phase Details

### Phase 6: Life Profile & Income Model
**Goal**: User establishes their personal financial identity (age, retirement target, risk profile) and income growth trajectory, providing the root data that powers all downstream planning calculations
**Depends on**: Phase 5 (existing app shell, settings infrastructure)
**Requirements**: LIFE-01, LIFE-02, LIFE-03, LIFE-04, INCOME-01, INCOME-02, INCOME-03, INCOME-04
**Success Criteria** (what must be TRUE):
  1. User can create and edit a life profile with DOB, retirement age, and risk profile from the Settings screen
  2. User can set growth rates (income, inflation, SWR) with India-calibrated defaults pre-filled
  3. Each family member has their own life profile respecting existing visibility boundaries
  4. User can model salary trajectory with career-stage multipliers and April hike month
  5. Editing life profile or income model causes downstream calculations to update reactively
**Plans**: 3 plans

Plans:
- [x] 06-01-PLAN.md -- Core data foundation: life_profiles table, DAO, schema migration v8->v9, IncomeGrowthEngine
- [x] 06-02-PLAN.md -- Projection integration: career-aware income scenarios, golden-file precision tests, side income tagging
- [x] 06-03-PLAN.md -- UI layer: 3-step wizard, risk profile cards, rate sliders, Settings integration, providers

**GAP Resolution**: INCOME-03 resolves C7 (projection engine consumes income growth model instead of flat assumption). M5 (goal-investment linking) partially addressed here via schema prep.

### Phase 7: FI Calculator & Net Worth Milestones
**Goal**: User can see their Financial Independence number, years-to-FI, Coast FI, and projected net worth at each decade milestone with on-track status
**Depends on**: Phase 6 (life profile provides age, retirement, risk, SWR; income model provides growth rates)
**Requirements**: FI-01, FI-02, FI-03, FI-04, FI-05, MILE-01, MILE-02, MILE-03, MILE-04
**Success Criteria** (what must be TRUE):
  1. User can see FI number (annual expenses / SWR, inflation-adjusted to retirement) on a dedicated FI screen
  2. User can adjust withdrawal rate, return rate, and inflation via sliders and see FI number, years-to-FI, and Coast FI update in real time
  3. FI Calculator works standalone with editable placeholder inputs even without a life profile configured
  4. User can see projected net worth at ages 30, 40, 50, 60, 70 with ON_TRACK/BEHIND/AHEAD status
  5. User can set custom target amounts for any milestone age and see status recalculate
**Plans**: 3 plans

Plans:
- [ ] 07-01-PLAN.md -- Pure-math engines (FiCalculator, MilestoneEngine), Drift table, DAO, schema v10 migration
- [ ] 07-02-PLAN.md -- FI Calculator screen with hero card, secondary cards, 4 sensitivity sliders, standalone mode
- [ ] 07-03-PLAN.md -- Milestone Dashboard screen with decade cards, status chips, edit sheet, Settings navigation wiring

### Phase 8: Asset Allocation & Purchase Planning
**Goal**: User can see target vs actual asset allocation with rebalancing guidance, model the financial impact of major life purchases, and use the Decision Modeling Framework to simulate any life decision before committing it
**Depends on**: Phase 7 (milestones provide trajectory context; FI number needed for purchase impact on FI date)
**Requirements**: ALLOC-01, ALLOC-02, ALLOC-03, ALLOC-04, ALLOC-05, PURCH-01, PURCH-02, PURCH-03, PURCH-04, NAV-07
**Success Criteria** (what must be TRUE):
  1. User can see target asset allocation (equity/debt/gold/cash) by age band based on their risk profile
  2. Current portfolio allocation is auto-computed from investment holdings mapped to asset classes (MF/stocks to equity, PPF/EPF/FD/bonds to debt)
  3. User can see rebalancing delta (actual % vs target %) and customize targets for any age band
  4. User can create a major purchase goal (home/car/education) and see its impact on net worth trajectory and FI date
  5. Investment portfolio screen shows "Allocation vs Target" banner linking to the allocation detail screen
  6. User can simulate life decisions (job change, purchase, withdrawal, etc.) via 4-step wizard and implement or preview them
**Plans**: 5 plans

Plans:
- [ ] 08-01-PLAN.md -- Pure-math engines: AllocationEngine + PurchasePlannerEngine with TDD, enums, Indian tax constants
- [ ] 08-02-PLAN.md -- Schema v11 migration: allocation_targets + decisions tables, Goals/RecurringRules column extensions, DAOs
- [ ] 08-03-PLAN.md -- DecisionModelerEngine (composition engine) with TDD + Riverpod providers for allocation/purchase/decisions
- [ ] 08-04-PLAN.md -- Allocation UI: AllocationScreen with donut charts, GlidePathEditorScreen, AllocationBanner (NAV-07), Settings tile
- [ ] 08-05-PLAN.md -- Decision Modeler UI: 4-step wizard screen, purchase goal form extensions, goal list category sectioning

**GAP Resolution**: PURCH-03 resolves M5 (goal-investment linking) for purchase goals with linked loans.

### Phase 9: Emergency Fund & Cash Tiers
**Goal**: User has complete safety-net visibility -- emergency fund coverage, account liquidity classification, and opportunity fund tracking
**Depends on**: Phase 6 (life profile provides income stability for EF target defaults)
**Requirements**: EF-01, EF-02, EF-03, EF-04, EF-05, TIER-01, TIER-02, TIER-03, TIER-04, NAV-05, NAV-06
**Success Criteria** (what must be TRUE):
  1. User can configure emergency fund with target months based on income stability, see auto-computed monthly essentials from budget ESSENTIAL group
  2. User can link savings accounts to emergency fund and see total coverage (months covered) with visual progress
  3. User can assign each account a liquidity tier (immediate/short-term/medium-term) and see aggregate balance by tier
  4. Account detail screen shows cash tier badge and emergency fund badge when assigned
  5. Budget screen shows monthly essentials row linking to emergency fund setup
**Plans**: 3 plans

Plans:
- [ ] 09-01-PLAN.md -- EmergencyFundEngine TDD + enums, schema v12 migration (accounts + life_profiles columns), AccountDao EF/tier methods
- [ ] 09-02-PLAN.md -- Riverpod providers for EF state/tier summary, EF detail screen with progress ring, account linking, tier summary
- [ ] 09-03-PLAN.md -- Navigation wiring: account detail EF/tier badges, budget essentials EF link, Settings Emergency Fund tile

### Phase 10: Sinking Funds & Savings Rate
**Goal**: User can track short-term deterministic savings goals separately from investment goals, and monitor their savings health over time
**Depends on**: Phase 9 (emergency fund must exist for savings rate context; sinking funds are next savings priority after EF)
**Requirements**: SINK-01, SINK-02, SINK-03, SINK-04, RATE-01, RATE-02, RATE-03, RATE-04, NAV-04
**Success Criteria** (what must be TRUE):
  1. User can create sinking fund goals with target amount, deadline, and sub-type, displayed separately from investment goals
  2. Sinking funds show simple monthly savings target and accept contributions via pre-filled transaction form
  3. User can see current month savings rate (income - expenses / income) as a percentage
  4. User can see 12-month savings rate trend line with health bands (green >= 20%, amber 10-20%, red < 10%)
  5. Goals screen is split into sections: Milestones, Sinking Funds, Investment Goals, Purchase Goals
**Plans**: 4 plans

Plans:
- [x] 10-01-PLAN.md -- SinkingFundEngine TDD + enums, schema v13 migration (MonthlyMetrics table + sinkingFundSubType column), DAOs
- [x] 10-02-PLAN.md -- Tabbed GoalListScreen (3 tabs), SinkingFundCard, GoalTypePicker, GoalFormScreen SF extension, contribution flow
- [x] 10-03-PLAN.md -- Savings rate detail screen, CustomPainter trend chart, on-demand metrics caching, dashboard badge navigation
- [ ] 10-04-PLAN.md -- Gap closure: Add Milestones tab to GoalListScreen (NAV-04)

**GAP Resolution**: RATE-03 resolves C10 (balance snapshots activated for historical savings rate computation).

### Phase 11: Cash Flow & Savings Allocation
**Goal**: User can see day-by-day cash flow projections with threshold alerts and get advisory surplus distribution across their savings targets
**Depends on**: Phase 10 (sinking funds and EF must exist as allocation targets; savings rate feeds allocation context)
**Requirements**: FLOW-01, FLOW-02, FLOW-03, FLOW-04, SAVE-01, SAVE-02, SAVE-03, SAVE-04, OPP-01, OPP-02, OPP-03
**Success Criteria** (what must be TRUE):
  1. User can see day-by-day income/expense map for any month based on recurring rules and known upcoming expenses
  2. Running balance is computed daily with threshold alerts flagging dates where balance goes negative or below minimum
  3. User can create priority-ordered savings allocation rules targeting EF, sinking funds, investment goals, or opportunity fund
  4. Allocation engine processes rules in priority order, showing advisory output (where surplus should go) without auto-creating transactions
  5. User can designate an account as opportunity fund with target amount, tracked separately from emergency fund
**Plans**: 4 plans

Plans:
- [ ] 11-01-PLAN.md -- CashFlowEngine + SavingsAllocationEngine TDD, schema v14 migration, savings_allocation_rules table, account columns, DAOs
- [ ] 11-02-PLAN.md -- Cash flow screen with vertical timeline, day row widgets, alert rows, providers, month navigation
- [ ] 11-03-PLAN.md -- Savings allocation screen with advisory output, opportunity fund screen, Settings wiring
- [ ] 11-04-PLAN.md -- Gap closure: Wire FLOW-04 item tap navigation to RecurringFormScreen

### Phase 12: Planning Dashboard & Lifetime Timeline
**Goal**: User has a unified financial health view (the "5 numbers") and a visual lifetime plan showing decades, milestones, purchases, and FI date
**Depends on**: Phases 7-11 (all planning and cash management features must exist to populate dashboard metrics and timeline)
**Requirements**: DASH-01, DASH-02, DASH-03, DASH-04, TIME-01, TIME-02, TIME-03, HEALTH-01, HEALTH-02, HEALTH-03, NAV-02
**Success Criteria** (what must be TRUE):
  1. User can see 5-number financial health view: Net Worth, Savings Rate, Emergency Coverage, FI Progress, Milestone Status
  2. Each metric is a tappable card that drills into its respective detail screen; unconfigured features show "Set up" CTAs
  3. User can see horizontal scrollable decade timeline with current age, milestones, purchase goals, and FI date marker (color-coded by status)
  4. User can see monthly cash flow health summary with income vs expenses bar chart and savings waterfall visualization
  5. Main dashboard shows "Financial Health" summary card with "View All" link; quick actions include "Cash Flow" and "Life Plan"
**Plans**: 3 plans

Plans:
- [ ] 12-01: TBD
- [ ] 12-02: TBD
- [ ] 12-03: TBD

### Phase 13: Planning Insights & Integration Polish
**Goal**: User receives deterministic threshold-based alerts for financial health issues, and all new features are navigable, tested, and polished across breakpoints
**Depends on**: Phase 12 (all features and dashboards must exist for insights to reference and navigation to connect)
**Requirements**: INSIGHT-01, INSIGHT-02, INSIGHT-03, INSIGHT-04, INSIGHT-05, NAV-01, NAV-03, NAV-08, NAV-09, NAV-10
**Success Criteria** (what must be TRUE):
  1. User sees deterministic alerts for: EF below target, allocation off-target, FI date slipping, sinking fund underfunded (with severity levels)
  2. All new screens are reachable from HomeShell via tap navigation with no dead-end screens
  3. Settings screen has "Financial Planning" section with links to Life Profile, Allocation, EF Setup, Cash Tiers, Savings Rules, Opportunity Fund
  4. Every new screen has empty-state with navigable CTA when prerequisites are missing
  5. Navigation integration tests pass at 3 breakpoints (400dp, 750dp, 1200dp) with minimum 32 tests and cross-feature round-trip verification
**Plans**: 3 plans

Plans:
- [ ] 13-01: TBD
- [ ] 13-02: TBD
- [ ] 13-03: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 6 -> 7 -> 8 -> 9 -> 10 -> 11 -> 12 -> 13
Note: Phases 9-10-11 (cash management track) depend on Phase 6 but not on Phases 7-8. Parallel execution is possible if inserting phases.

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 6. Life Profile & Income Model | 3/3 | Complete | 2026-03-23 |
| 7. FI Calculator & Net Worth Milestones | 3/3 | Complete   | 2026-03-22 |
| 8. Asset Allocation & Purchase Planning | 5/5 | Complete   | 2026-03-23 |
| 9. Emergency Fund & Cash Tiers | 3/3 | Complete   | 2026-03-23 |
| 10. Sinking Funds & Savings Rate | 4/4 | Complete    | 2026-03-24 |
| 11. Cash Flow & Savings Allocation | 3/4 | In Progress | 2026-03-24 |
| 12. Planning Dashboard & Lifetime Timeline | 0/? | Not started | - |
| 13. Planning Insights & Integration Polish | 0/? | Not started | - |
