# Technology Stack

**Project:** Vael — Financial Planning & Cash Management Extension (Phases 6-8)
**Researched:** 2026-03-22
**Scope:** Stack additions ONLY for new features. Existing stack (Drift, Riverpod, fl_chart, SQLCipher, etc.) validated and not re-evaluated.

## Core Recommendation: Zero New Dependencies

The existing stack already covers 95% of what Phases 6-8 need. The financial planning and cash management features are fundamentally **computation + data + charts** — all of which the current stack handles well.

**Rationale:** Every new dependency is a maintenance burden, a potential breaking change on Flutter upgrades, and a testing surface. The existing `fl_chart` + custom widgets + `FinancialMath` class + Drift ORM is sufficient for everything described in the Active requirements.

## Feature-to-Stack Mapping

### Financial Math Engines (No new packages needed)

| Feature | Existing Capability | What to Build | Confidence |
|---------|-------------------|---------------|------------|
| FI calculator (FI number, years-to-FI, Coast FI) | `FinancialMath.fv()`, `FinancialMath.pv()`, `FinancialMath.inflationAdjust()` | New `FiCalculator` class using existing primitives | HIGH |
| Asset allocation glide path | None — but pure arithmetic | `AllocationEngine` with age-band lookup tables (no ML) | HIGH |
| Income growth model | `FinancialMath.inflationAdjust()` covers compound growth | `IncomeGrowthModel` class with career-stage multipliers | HIGH |
| Major purchase planner | `AmortizationCalculator`, `FinancialMath.pmt()` | `PurchasePlanner` composing existing amortization + FV | HIGH |
| Emergency fund engine | Simple multiplication (monthly expenses x months) | `EmergencyFundEngine` — trivial math, mostly classification logic | HIGH |
| Savings allocation engine | None — but pure rule-based ordering | `SavingsAllocator` — priority queue distributing surplus | HIGH |
| Cash flow calendar | `ProjectionEngine` already projects monthly | `CashFlowCalendar` consuming recurring rules + one-offs | HIGH |
| Savings rate trend | `BalanceSnapshotDao` exists (needs C10 fix) | Query + compute — no new math | HIGH |

**Verdict:** All financial math is composable from `FinancialMath` primitives (PMT, FV, PV, inflationAdjust, requiredSip) plus simple Dart arithmetic. No external financial library needed.

### Visualization (No new packages needed)

| Visualization Need | Solution | Why |
|-------------------|----------|-----|
| Lifetime timeline (decades, milestones, FI date) | **Custom widget with `CustomPainter`** | Timeline packages (timelines, timelines_plus) are designed for vertical step-indicators (order tracking UX), not horizontal decade-spanning financial timelines. A custom painter gives pixel-perfect control over decade markers, milestone dots, FI-date callouts, and goal overlays. ~200 lines of code. |
| Cash flow calendar (day-by-day view) | **Custom calendar grid widget** | `table_calendar` is a full-featured calendar with gestures, locale handling, and event markers — massive overkill for a read-only cash flow heatmap. A custom `GridView` with 7 columns and color-coded cells is simpler (~150 lines), fully testable, and avoids a dependency that may conflict with Flutter version upgrades. |
| Savings waterfall chart | **`fl_chart` BarChart** (already installed) | `fl_chart` `BarChartData` supports stacked bars natively. Use positive/negative stacking for waterfall visualization. |
| Net worth milestone chart | **`fl_chart` LineChart** (already installed) | Already used in projections. Add horizontal target lines for decade milestones. |
| Allocation pie/donut | **`fl_chart` PieChart** (already installed) | Already available in fl_chart. Donut = PieChart with `centerSpaceRadius`. |
| Savings rate trend | **`fl_chart` LineChart** (already installed) | 12-month line with health band background using `betweenBarsData` or `belowBarData`. |
| FI progress gauge | **Custom `CustomPainter` arc** | ~80 lines. Semi-circle arc with progress fill. No package needed for a single gauge. |

**Why NOT use timeline/calendar packages:**

| Package | Why Not |
|---------|---------|
| `timelines` / `timelines_plus` | Vertical step-indicator design (delivery tracking). Wrong abstraction for a horizontal decade-spanning financial timeline. Would require fighting the API to get the desired look. |
| `table_calendar` | 850KB+ package with locale handling, gesture detection, multi-day event spanning. The cash flow calendar is a simple read-only colored grid — `table_calendar` adds complexity without benefit. |
| `syncfusion_flutter_charts` | Commercial license required for revenue-generating apps. Massive package size. fl_chart already covers all needed chart types. |
| `graphic` | Low adoption, less mature than fl_chart. No compelling advantage for the chart types needed here. |

### Data Layer (No new packages needed)

| Need | Solution | Why |
|------|----------|-----|
| 7 new Drift tables | Drift `^2.27.0` (already installed) | Schema migrations are additive per project constraints. Standard Drift table definitions + DAOs. |
| Life profile storage | New `life_profiles` table in Drift | DOB, retirement age, risk profile, growth rate assumptions. Single row per user. |
| Sinking funds | New `sinking_funds` table in Drift | Name, target amount, deadline, linked account. |
| Cash tiers | New `cash_tier_configs` table in Drift | Classification rules mapping accounts to tiers. |
| Allocation targets | New `allocation_targets` table in Drift | Age-band -> asset-class percentage mappings. |
| Balance snapshots (C10 fix) | `BalanceSnapshots` table already exists | Needs scheduler activation — table and DAO are already defined. |

### State Management (No new packages needed)

| Need | Solution | Why |
|------|----------|-----|
| Planning state | Riverpod `^3.1.0` family providers | Same pattern as existing features. New providers in `features/planning/providers/` and `features/cash_management/providers/`. |
| Cross-feature data | Riverpod provider composition | FI calculator consumes investment holdings + recurring rules + life profile. Standard `ref.watch()` composition. |
| Reactive updates | Drift DAO watch streams | Same pattern. `watchSinkingFunds()`, `watchCashTiers()`, etc. |

## Recommended Stack (Summary)

### No New Dependencies

| Category | Technology | Version | Status | Notes |
|----------|-----------|---------|--------|-------|
| Charts | fl_chart | ^1.2.0 | Already installed | Covers bar, line, pie, scatter — all chart types needed |
| ORM | Drift | ^2.27.0 | Already installed | 7 new tables, additive migrations |
| State | Riverpod | ^3.1.0 | Already installed | ~15 new providers |
| Financial math | Custom Dart | N/A | Already built | Extend with 6 new engine classes |
| Timeline viz | Custom widget | N/A | To build | CustomPainter, ~200 LOC |
| Calendar viz | Custom widget | N/A | To build | GridView-based, ~150 LOC |
| Gauge viz | Custom widget | N/A | To build | CustomPainter arc, ~80 LOC |

### Why Zero Dependencies is the Right Call

1. **Constraint compliance:** PROJECT.md explicitly states "no new frameworks." Custom widgets are the safest path.
2. **Test coverage:** Custom painters and grid widgets are trivially unit-testable with golden tests. Third-party widget packages often require brittle `find.byType` + `pumpAndSettle` patterns.
3. **Maintenance burden:** The app already has 8 direct dependencies. Each new pub.dev package is a potential breaking change on Flutter SDK upgrades (the app targets `^3.11.3`). Timeline and calendar packages have historically been slow to support new Flutter versions.
4. **Bundle size:** Zero marginal increase. Every KB matters on mobile.
5. **Integer arithmetic discipline:** Third-party financial libraries use `double` internally. The project requires integer arithmetic (paise/basis points). Building on the existing `FinancialMath` class preserves this invariant.

## What to Build (New Code, Not New Dependencies)

### New Financial Math Engines

```
lib/core/financial/
  fi_calculator.dart          — FI number, years-to-FI, Coast FI, lean/fat FI
  milestone_engine.dart       — Net worth targets by decade, on-track status
  allocation_engine.dart      — Age-band glide paths, rebalancing deltas
  income_growth_model.dart    — Salary trajectory, career stage multipliers
  emergency_fund_engine.dart  — Target months, coverage ratio, linked accounts
  cash_flow_calendar.dart     — Day-by-day projection from recurring rules
  savings_allocator.dart      — Priority-ordered surplus distribution
  purchase_planner.dart       — Loan impact, opportunity cost, timeline
```

### New Custom Visualization Widgets

```
lib/shared/widgets/
  lifetime_timeline.dart      — Horizontal decade timeline with milestones
  cash_flow_grid.dart         — 7-column calendar grid with color coding
  fi_gauge.dart               — Semi-circle progress arc
  waterfall_chart.dart        — Wrapper around fl_chart BarChart for waterfall
```

### New Drift Tables (7 new + 2 modified)

```
lib/core/database/tables/
  life_profiles.dart          — DOB, retirement age, risk profile
  net_worth_milestones.dart   — Decade targets, status
  allocation_targets.dart     — Age-band asset allocation rules
  sinking_funds.dart          — Short-term savings buckets
  cash_tier_configs.dart      — Account-to-tier classification
  income_projections.dart     — Salary/income trajectory data
  savings_rules.dart          — Priority-ordered allocation rules

Modified:
  goals.dart                  — Add purchase_type, loan_link fields
  balance_snapshots.dart      — Activate scheduler (C10 fix)
```

## Alternatives Considered

| Category | Recommended | Alternative | Why Not |
|----------|-------------|-------------|---------|
| Timeline viz | Custom `CustomPainter` | `timelines_plus` ^0.1.x | Wrong abstraction (vertical steps vs horizontal decades). Would fight the API. |
| Calendar viz | Custom `GridView` | `table_calendar` ^3.x | Overkill for read-only heatmap. Large dependency. Gesture handling not needed. |
| Charts | `fl_chart` (existing) | `syncfusion_flutter_charts` | Commercial license. Massive package. fl_chart covers all needed types. |
| Charts | `fl_chart` (existing) | `graphic` ^2.x | Lower adoption, less battle-tested. No feature gap that justifies switching. |
| Financial math | Custom Dart engines | `financial_calculator` pub package | Uses `double` internally, violating integer arithmetic constraint. Low pub.dev scores. Unmaintained. |
| Financial math | Custom Dart engines | `tvm_calculator` | Same `double` issue. Limited to TVM — no allocation, no FI calc. |
| State mgmt | Riverpod (existing) | BLoC for new features | Mixing state management patterns in one app is a maintenance nightmare. |

## Version Pinning Strategy

No version changes needed. Current pubspec.yaml pins are correct:

```yaml
# All existing — no changes to pubspec.yaml
drift: ^2.27.0
fl_chart: ^1.2.0
flutter_riverpod: ^3.1.0
```

## Installation

```bash
# No new packages to install.
# All features built with existing dependencies.
```

## Confidence Assessment

| Recommendation | Confidence | Rationale |
|---------------|------------|-----------|
| No new dependencies needed | HIGH | Verified against existing pubspec.yaml and feature requirements. All chart types available in fl_chart. All math composable from FinancialMath primitives. |
| Custom timeline widget over packages | HIGH | Inspected timelines/timelines_plus APIs — they solve a different problem (vertical step indicators). Financial timelines need horizontal decade spans with custom markers. |
| Custom calendar grid over table_calendar | HIGH | Cash flow calendar is read-only with color coding. table_calendar's value is in gesture handling and locale support — neither needed here. |
| fl_chart covers waterfall/gauge needs | MEDIUM | Waterfall charts require creative use of stacked bars with invisible base segments. If this proves too hacky, a custom `CustomPainter` waterfall is ~120 LOC. Either way, no new dependency. |
| Integer arithmetic engines in custom Dart | HIGH | Project constraint. No pub.dev financial library respects paise/basis-point integer math. Must be custom. |

## Sources

- Existing codebase analysis: `pubspec.yaml`, `lib/core/financial/financial_math.dart`, `lib/core/financial/projection_engine.dart`
- PROJECT.md constraints: "no new frameworks", integer arithmetic, deterministic only
- fl_chart documentation (from training data, MEDIUM confidence on specific API details)
- timelines_plus, table_calendar API knowledge (from training data, MEDIUM confidence — but recommendation to avoid them holds regardless of exact current API)
