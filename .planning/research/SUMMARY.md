# Project Research Summary

**Project:** Vael -- Financial Planning & Cash Management Extension (Phases 6-8)
**Domain:** Personal finance planning for Indian households (FI calculators, emergency funds, cash tiers, savings allocation, milestone tracking)
**Researched:** 2026-03-22
**Confidence:** HIGH

## Executive Summary

Vael's Phases 6-8 extend an already mature Flutter finance app (5 completed phases, 350+ tests, 15 tables, 14 feature modules) with a financial planning intelligence layer and cash management system. The research conclusively shows that **zero new dependencies are needed** -- every feature (FI calculators, allocation engines, cash flow calendars, milestone timelines) is composable from the existing stack: Drift for persistence, Riverpod for state, fl_chart for visualization, and custom `FinancialMath` primitives for integer arithmetic. The recommended approach is to build 8 new pure-math engine classes in `core/financial/`, 7 new Drift tables across 2-3 schema versions, and ~15 new providers and screens following the identical patterns already established in the codebase.

The key architectural insight is that planning engines form a strict computation DAG (directed acyclic graph) that must be layered: raw data (accounts, transactions, profile) feeds derived metrics (net worth, savings rate) which feed single-engine calculations (FI number, emergency target) which feed composite views (dashboard, timeline). Violating this layering creates circular Riverpod dependencies -- the single highest-cost pitfall identified. The build order is dependency-driven: Life Profile first (everything depends on it), then parallel tracks for FI/milestones/allocation (planning) and emergency fund/cash tiers/sinking funds (cash management), then aggregation screens last.

The primary risks are India-specific domain correctness (FI formulas must use 3% SWR not 4%, inflation-adjust targets, show ranges not single numbers), integer arithmetic precision over 30-40 year horizons (validate against Excel at long horizons), and schema migration fragility when adding 7 tables across multiple versions. All three are addressable with upfront design decisions and golden-file tests, not architectural changes.

## Key Findings

### Recommended Stack

No changes to `pubspec.yaml`. The entire planning layer is built with existing dependencies plus custom Dart code. This is the right call: the project mandates integer arithmetic (paise/basis points), which no pub.dev financial library respects, and the visualization needs (horizontal timeline, cash flow heatmap, FI gauge) are better served by ~430 lines of `CustomPainter` code than by packages designed for different use cases.

**Core technologies (all existing):**
- **Drift ^2.27.0**: 7 new tables (life profiles, milestones, sinking funds, cash tiers, allocation targets, emergency configs, savings rules) + 2 modified tables
- **Riverpod ^3.1.0**: ~15 new providers following existing StreamProvider.family pattern
- **fl_chart ^1.2.0**: Waterfall (stacked bar), allocation (pie/donut), savings trend (line), milestone (line with targets)
- **Custom FinancialMath engines**: 8 new engine classes (FI calculator, milestone, allocation, income growth, emergency fund, cash flow, savings allocator, purchase planner) -- all pure functions, no DB imports

### Expected Features

**Must have (table stakes -- users who completed Phases 1-5 expect these):**
- **Life Profile** -- DOB, retirement age, risk tolerance. Foundation for all planning math. ~1-2 days.
- **Emergency Fund Tracker** -- Months covered from real account balances, income-stability-parameterized target. Universal expectation.
- **FI Calculator** -- FI number with India-calibrated defaults (3% SWR, inflation-adjusted, three scenarios). Most requested number.
- **Savings Rate Trend** -- 12-month rolling chart with health bands. Requires C10 gap fix (balance snapshots).
- **Cash Flow Calendar** -- Day-by-day projection from recurring rules. Daily-use feature.
- **Sinking Funds** -- Short-term deterministic savings buckets. Reuses goal infrastructure.
- **Net Worth Milestones** -- Decade targets with on-track/behind/ahead status.

**Should have (differentiators -- India-native, privacy-first advantages):**
- **Asset Allocation Glide Path** -- Age-band targets with India-specific asset classes (PPF, EPF, NPS, Gold mapped to equity/debt/gold/cash). No Indian competitor does this offline.
- **Unified "5 Numbers" Dashboard** -- NW, savings rate, emergency coverage, FI progress, next milestone. 10-second financial health check.
- **Savings Allocation Rules** -- Priority-ordered surplus distribution (emergency first, then sinking funds, then goals). Advisory only.
- **Income Growth Model** -- Career-stage multipliers, April hike month (Indian fiscal year). Enriches projection engine (C7 gap).
- **Cash Tier Classification** -- Account-to-tier mapping (immediate/short-term/medium-term access).

**Defer (high complexity or dependency-heavy):**
- **Major Purchase Planner** -- Depends on M5 gap (goal-investment linking). Ship after core planning works.
- **Lifetime Timeline** -- Visualization-heavy capstone. Depends on all Phase 6 data.
- **Savings Allocation Rules** -- Depends on emergency fund + sinking funds being populated.
- **Unified Dashboard** -- Aggregation of all features. By definition, ship last.

### Architecture Approach

The planning layer follows the exact same pattern as existing features: pure engines in `core/financial/` (no DB access), DAOs in `core/database/daos/`, providers in `features/{name}/providers/` that wire DAO streams to engines, and screens that consume providers via `ref.watch().when()`. Two new feature modules (`features/planning/` and `features/cash_management/`) each with their own providers, screens, and widgets. No new tabs -- entry via dashboard cards (Planning Health Card and Cash Health Card) that push to hub screens, max 3 levels deep.

**Major components:**
1. **Pure Financial Engines (8 classes)** -- Stateless computation: FI numbers, milestones, allocation deltas, emergency targets, cash flow maps. Private constructors, static methods only. No DB imports.
2. **Data Layer (7 new tables + DAOs)** -- Life profiles, milestones, sinking funds, cash tiers, allocation targets, emergency configs, savings rules. Additive schema migrations (v9, v10).
3. **Feature Modules (2 new)** -- `features/planning/` (long-term: FI, milestones, allocation, income, purchases, timeline) and `features/cash_management/` (short-term: emergency, cash tiers, sinking funds, cash flow, savings rate, allocation rules).
4. **Dashboard Integration** -- Planning Health Card and Cash Health Card on existing dashboard. Navigation via `Navigator.push()` to hub screens, then to sub-features.

### Critical Pitfalls

1. **Circular provider dependencies** -- Planning engines have a natural circular dependency graph (FI needs savings rate needs emergency allocation needs income needs projections needs FI). **Avoid by:** defining a strict 4-layer computation DAG (raw data -> derived metrics -> single-engine calcs -> composite views). Each layer only depends downward. Document and enforce before writing any engine.

2. **Integer arithmetic precision over long horizons** -- `FinancialMath` uses `double` intermediates with `.round()`. At 30-40 year horizons with Indian income levels, intermediate values can exceed 2^53 where `double` loses precision. **Avoid by:** adding `assert(intermediateValue.abs() < (1 << 53))` guards, stepping year-by-year for long horizons, and golden-file tests against Excel at 25yr and 40yr.

3. **India-specific FI formula correctness** -- The 4% SWR / 25x rule is US-calibrated. India's 6-7% inflation and 4-5% real returns require 3% SWR (33x expenses), inflation-adjusted targets, and scenario ranges. **Avoid by:** defaulting to 3% SWR, always showing inflation-adjusted numbers, displaying conservative/moderate/aggressive ranges.

4. **Schema migration fragility** -- Adding 7 tables across multiple versions creates combinatorial upgrade paths. **Avoid by:** grouping tables into 2-3 schema versions max (v9 for Phase 6, v10 for Phase 7), testing every `from` version (v6->latest through v8->latest), creating tables in FK dependency order.

5. **Navigation spaghetti with 15+ new screens** -- Without a hub pattern, screens get pushed from multiple entry points with inconsistent back stacks. **Avoid by:** establishing Planning Hub and Cash Health Hub as single canonical entry points from dashboard cards, keeping navigation max 3 levels deep.

## Implications for Roadmap

### Phase 6: Planning Foundation
**Rationale:** Life Profile is the root dependency for every planning calculation. FI calculator and milestones are the highest-value features. This phase establishes the computation DAG pattern that all subsequent engines follow.
**Delivers:** Life Profile setup, FI calculator (with India-calibrated defaults), net worth milestones, asset allocation glide path, income growth model.
**Addresses:** 5 of 7 table-stakes features; resolves C7 gap (income growth enriches projection engine).
**Avoids:** Circular dependencies (DAG defined upfront), FI formula errors (India defaults from day one), schema migration fragility (establish migration test pattern with v9).
**Stack:** 3 new Drift tables (life_profiles, net_worth_milestones, purchase_plans), 5 new engines, 6 new screens, custom timeline/gauge widgets (~280 LOC).

### Phase 7: Cash Management
**Rationale:** Emergency fund and cash management features are independent of most Phase 6 engines (only depend on life profile for income stability). Can leverage existing account and transaction data immediately.
**Delivers:** Emergency fund tracker, cash tier classification, sinking funds, balance snapshot fix (C10), savings rate trend, cash flow calendar, savings allocation rules.
**Addresses:** Remaining table-stakes features (emergency fund, savings rate, cash flow calendar, sinking funds); differentiators (cash tiers, allocation rules).
**Avoids:** Emergency fund without family context (parameterized by income stability from life profile), C10 gap (must fix before savings rate trend).
**Stack:** 4 new Drift tables (emergency_fund_configs, cash_tiers, sinking_funds, savings_allocation_rules), 3 new engines, 7 new screens, calendar grid widget (~150 LOC).

### Phase 8: Integration and Polish
**Rationale:** Aggregation screens (Planning Dashboard, Cash Health Dashboard, Lifetime Timeline) depend on all Phase 6+7 engines being complete. Dashboard card integration, cross-feature navigation, and the "5 Numbers" view are the capstone.
**Delivers:** Unified Planning Dashboard ("5 Numbers"), Cash Health summary, Lifetime Timeline visualization, dashboard card integration, cross-feature deep links (account detail -> cash tier, goal detail -> purchase planner).
**Addresses:** Major Purchase Planner (if M5 gap resolved), Opportunity Fund tracking.
**Avoids:** Navigation spaghetti (hub pattern established in Phases 6-7), god provider anti-pattern (each dashboard metric from independent providers).

### Phase Ordering Rationale

- Life Profile must come first because FI calculator, milestones, allocation, income growth, and emergency fund all require age/retirement/risk data.
- FI Calculator before milestones because milestones consume FI number for the FI-date milestone marker.
- Emergency fund and cash tiers can parallelize with FI/milestones because they depend on different data (accounts/expenses vs. life profile + net worth).
- Savings rate trend is blocked by C10 gap (balance snapshots) -- this must be fixed in Phase 7 before the trend chart.
- Aggregation screens (dashboard, timeline) must come last because they consume all other engines' outputs.
- The dependency chain is: Life Profile -> (FI + Milestones + Allocation) || (Emergency Fund + Cash Tiers + Sinking Funds) -> (Savings Allocation + Cash Flow Calendar + Savings Rate) -> (Dashboard + Timeline).

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 6 (FI Calculator):** Validate India-specific SWR assumptions against Freefincal research. Golden-file test values need Excel verification. Coast FI formula needs careful derivation.
- **Phase 6 (Purchase Planner):** Complex cross-cutting feature. Depends on M5 gap resolution. May need research-phase to design loan-EMI-to-projection feedback loop.
- **Phase 7 (Balance Snapshot Scheduler):** C10 gap resolution. Need to understand why the existing scheduler is not activating and design the background job pattern for Flutter (no background execution on iOS without special entitlements).

Phases with standard patterns (skip research-phase):
- **Phase 6 (Life Profile):** Simple CRUD form + Drift table. Well-established pattern in the codebase.
- **Phase 7 (Sinking Funds):** Reuses goal infrastructure. CRUD with progress tracking.
- **Phase 7 (Cash Tier Classification):** Per-account metadata. Simple enum column + classification screen.
- **Phase 8 (Dashboard Integration):** Follows existing dashboard card pattern exactly.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Zero new dependencies. All capabilities verified against existing pubspec.yaml and codebase. |
| Features | HIGH | Feature list derived from first-party extension plan + competitive analysis. India-native defaults validated against domain knowledge. |
| Architecture | HIGH | All patterns verified against existing codebase (ProjectionEngine, GoalTracking, DashboardAggregation). No architectural novelty -- more of the same. |
| Pitfalls | HIGH | Pitfalls identified from codebase analysis (integer math patterns, schema version history, navigation structure). India-specific FI pitfalls from domain expertise. |

**Overall confidence:** HIGH

### Gaps to Address

- **C10 Gap (Balance Snapshots):** Table exists but scheduler never fires. Need to investigate why and design activation strategy. Blocks savings rate trend in Phase 7.
- **M5 Gap (Goal-Investment Linking):** Purchase planner needs goals linked to investments. Gap acknowledged in PROJECT.md but not yet resolved. Blocks full purchase planner in Phase 8.
- **C5 Gap (Lock Screen):** Planning data (income, FI number, retirement plans) is sensitive. Lock screen should be resolved before or alongside Phase 6.
- **C1 Gap (SQLCipher Verification):** New tables are automatically encrypted (same DB), but no test verifies this. Add a test that reads raw DB bytes.
- **India SWR Validation:** 3% SWR default is based on domain consensus, not a specific verified study. Should validate against Freefincal or similar Indian FI research during Phase 6 implementation.
- **fl_chart Waterfall Rendering:** Using stacked bars with invisible base segments for waterfall charts is a workaround. May need fallback to CustomPainter (~120 LOC) if fl_chart's API makes this too hacky. MEDIUM confidence.

## Sources

### Primary (HIGH confidence)
- Existing codebase: `pubspec.yaml`, `lib/core/financial/financial_math.dart`, `lib/core/financial/projection_engine.dart`, `lib/core/database/database.dart`
- First-party design documents: `docs/EXTENSION_PLAN_FINANCIAL_PLANNING.md`, `docs/INTENT.md`, `docs/agents/Lifetime-Planner.md`, `docs/agents/Risk-Planner.md`
- PROJECT.md constraints: integer arithmetic, additive migrations, TDD, 5-tab limit, no new frameworks

### Secondary (MEDIUM confidence)
- India personal finance patterns: SEBI guidelines, RBI inflation targets, Indian IT compensation patterns (domain knowledge, not web-verified)
- Competitor analysis: ET Money, Groww, YNAB, Money Manager feature sets (training data as of mid-2025)
- fl_chart API specifics: stacked bar waterfall technique, betweenBarsData for health bands

### Tertiary (LOW confidence)
- India-specific safe withdrawal rate (3% vs 4%): community consensus from FI/FIRE India discussions, not peer-reviewed study. Validate during implementation.

---
*Research completed: 2026-03-22*
*Ready for roadmap: yes*
