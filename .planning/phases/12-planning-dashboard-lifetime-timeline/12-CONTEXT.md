# Phase 12: Planning Dashboard & Lifetime Timeline - Context

**Gathered:** 2026-03-24
**Status:** Ready for planning

<domain>
## Phase Boundary

Unified "5 numbers" financial health view, horizontal decade timeline showing milestones/purchases/FI date, monthly cash flow health summary with savings waterfall, and main dashboard integration. All data comes from existing engines (Phases 7-11). This phase is pure visualization and navigation — no new business logic or database tables.

</domain>

<decisions>
## Implementation Decisions

### Lifetime Timeline Design
- Fixed decade columns — each decade gets equal-width regardless of event density
- Current age marker stays centered on initial load
- Horizontal scroll left/right for past/future decades
- Nodes are colored circles (green/amber/red by status) with short labels below (e.g., "₹1Cr", "Car", "FI")
- FI date gets a special diamond shape to distinguish from milestones/purchases
- Tapping a node navigates to its detail screen (milestone detail, purchase goal, FI calculator)

### Savings Waterfall Chart
- Stacked horizontal bar — single bar segmented into: Income (full width) → Expenses (red) → EF (blue) → Sinking Funds (teal) → Investments (green) → Unallocated (gray)
- Labels on each segment showing amount
- Compact, mobile-first — works on phone screens
- Data sourced from SavingsAllocationEngine.allocate() output

### Dashboard Integration
- Financial Health summary card goes at TOP of main dashboard, above net worth
- Only visible if life profile is configured (graceful degradation)
- Shows condensed 5-number view as small chips/badges
- "View All" opens full planning dashboard
- "Cash Flow" and "Life Plan" added to existing quick action chips row (scrollable if needed)

### Claude's Discretion
- 5-number health card layout (grid vs list, card size, metric badge styling)
- "Set up" CTA styling for unconfigured features
- Color palette for waterfall segments beyond the specified mapping
- Timeline age marker styling and empty decade treatment
- Cash flow mini-view layout (7-day preview, bar chart dimensions)
- Animation/transitions between dashboard and detail screens

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Dashboard
- `.planning/REQUIREMENTS.md` — DASH-01 through DASH-04: 5-number view, drill-through, graceful degradation, main dashboard card
- `lib/features/dashboard/screens/dashboard_screen.dart` — Existing main dashboard (net worth, monthly summary, quick actions)
- `lib/features/dashboard/providers/dashboard_providers.dart` — Existing dashboard data providers
- `lib/core/financial/dashboard_aggregation.dart` — DashboardAggregation with computeSavingsRate

### Timeline
- `.planning/REQUIREMENTS.md` — TIME-01 through TIME-03: decade timeline, color coding, tap navigation
- `lib/features/planning/screens/milestone_dashboard_screen.dart` — Existing milestone display (reuse data, different visualization)
- `lib/features/planning/providers/milestone_provider.dart` — MilestoneDisplayItem data model

### Cash Flow Health
- `.planning/REQUIREMENTS.md` — HEALTH-01 through HEALTH-03: income/expense chart, savings waterfall, 7-day mini-view
- `lib/core/financial/cash_flow_engine.dart` — CashFlowEngine.projectMonth() for cash flow data
- `lib/core/financial/savings_allocation_engine.dart` — SavingsAllocationEngine.allocate() for waterfall data
- `lib/features/cashflow/providers/cash_flow_providers.dart` — Existing cash flow providers

### Prior Phase Engines (data sources)
- `lib/core/financial/emergency_fund_engine.dart` — EF coverage metric
- `lib/core/financial/sinking_fund_engine.dart` — Sinking fund progress for waterfall
- `lib/features/dashboard/widgets/savings_rate_trend_chart.dart` — CustomPainter chart pattern (reusable)
- `lib/features/dashboard/screens/savings_rate_detail_screen.dart` — Drill-through pattern

### Navigation
- `.planning/REQUIREMENTS.md` — NAV-02: quick actions extended with Cash Flow and Life Plan
- `lib/shared/shell/home_shell.dart` — HomeShell navigation structure

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `DashboardAggregation.computeSavingsRate()` — savings rate metric already computed
- `MilestoneDisplayItem` — milestone data model with age, amounts, status (from Phase 7)
- `SavingsRateTrendChart` — CustomPainter pattern reusable for timeline and waterfall
- `CashFlowEngine.projectMonth()` — provides DayProjection list for 7-day mini-view
- `SavingsAllocationEngine.allocate()` — provides AllocationAdvice list for waterfall segments
- `EmergencyFundEngine.coverageMonths()` — EF coverage metric

### Established Patterns
- CustomPainter for charts (SavingsRateTrendChart from Phase 10)
- ActionChip for dashboard quick actions (savings rate badge pattern)
- Settings > Financial Planning tiles pattern for navigation entry points
- ColorTokens.of(context) for theme-aware colors

### Integration Points
- Dashboard screen — new Financial Health card at top + quick actions
- Planning dashboard — new screen aggregating all 5 numbers
- Lifetime timeline — new screen with horizontal scrollable CustomPainter
- Cash flow health — new screen or section with bar chart + waterfall

</code_context>

<specifics>
## Specific Ideas

No specific requirements — open to standard approaches for 5-number cards, chart animations, and empty states. User focused discussion on timeline node design, waterfall chart type, and dashboard placement.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 12-planning-dashboard-lifetime-timeline*
*Context gathered: 2026-03-24*
