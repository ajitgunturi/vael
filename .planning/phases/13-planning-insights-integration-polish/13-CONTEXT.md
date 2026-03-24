# Phase 13: Planning Insights & Integration Polish - Context

**Gathered:** 2026-03-24
**Status:** Ready for planning

<domain>
## Phase Boundary

Deterministic threshold-based alerts for financial health issues (EF below target, allocation off-target, FI date slipping, sinking fund underfunded). Navigation polish ensuring all new screens are reachable, no dead-ends, and Settings has a complete Financial Planning section. Integration tests at 3 breakpoints. This is the final milestone phase — ties together all Phases 6-12.

</domain>

<decisions>
## Implementation Decisions

### Navigation Responsiveness
- Single-column responsive: phone (400dp) single column, tablet (750dp+) side-by-side panels, desktop (1200dp+) 3-column
- Planning dashboard grid adjusts column count at breakpoints
- Matches existing responsive patterns from prior phases

### Settings Financial Planning Section
- Single "Financial Planning" section with tiles ordered by setup flow:
  1. Life Profile
  2. Emergency Fund
  3. Cash Tiers
  4. Savings Allocation Rules
  5. Opportunity Fund
  6. Cash Flow
- Order follows the natural setup sequence (profile → safety net → allocation → spending)
- Unconfigured tiles still visible but show "Set up" indicator

### Claude's Discretion
- Alert severity levels and visual treatment (critical/warning/info, colors, icons)
- Alert display location (inline on planning dashboard, separate alerts section, or both)
- Exact thresholds for each alert type (months short for EF, % deviation for allocation, FI date slip amount, sinking fund shortfall)
- Whether alerts are dismissible or persistent
- Dead-end screen identification and back-button behavior fixes
- Integration test structure and assertion patterns
- Breakpoint-specific layout adjustments per screen

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Insights/Alerts
- `.planning/REQUIREMENTS.md` — INSIGHT-01 through INSIGHT-05: alert types, severity, deterministic requirement
- `lib/core/financial/emergency_fund_engine.dart` — EF coverage data for INSIGHT-01
- `lib/core/financial/savings_allocation_engine.dart` — Allocation deviation for INSIGHT-02
- `lib/features/planning/providers/planning_health_providers.dart` — PlanningHealthData aggregation (FI progress for INSIGHT-03)
- `lib/core/financial/sinking_fund_engine.dart` — Sinking fund pace status for INSIGHT-04

### Navigation
- `.planning/REQUIREMENTS.md` — NAV-01, NAV-03, NAV-08, NAV-09, NAV-10
- `lib/shared/shell/home_shell.dart` — HomeShell navigation structure
- `lib/features/settings/screens/settings_screen.dart` — Settings screen (existing Financial Planning tiles)
- `lib/features/dashboard/screens/dashboard_screen.dart` — Main dashboard with Financial Health card + quick actions (Phase 12)

### All Planning Screens (navigation targets)
- `lib/features/planning/screens/planning_dashboard_screen.dart` — 5-number health dashboard
- `lib/features/planning/screens/lifetime_timeline_screen.dart` — Decade timeline
- `lib/features/planning/screens/cash_flow_health_screen.dart` — Cash flow health + waterfall
- `lib/features/planning/screens/milestone_dashboard_screen.dart` — Milestones
- `lib/features/planning/screens/savings_allocation_screen.dart` — Allocation rules
- `lib/features/planning/screens/opportunity_fund_screen.dart` — Opportunity fund
- `lib/features/cashflow/screens/cash_flow_screen.dart` — Cash flow timeline
- `lib/features/dashboard/screens/savings_rate_detail_screen.dart` — Savings rate detail
- `lib/features/goals/screens/goal_list_screen.dart` — 4-tab goals screen

### Prior Phase Patterns
- `lib/features/planning/widgets/health_metric_card.dart` — Metric card with "Set up" CTA pattern
- `lib/shared/widgets/empty_state.dart` — Empty state widget pattern (if exists)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `EmergencyFundEngine.coverageMonths()` — EF alert: compare against target months
- `SavingsAllocationEngine.allocate()` — allocation alert: compare actual vs rule targets
- `SinkingFundEngine.paceStatus()` — sinking fund alert: behind/on-track/ahead
- `PlanningHealthData` — already aggregates all 5 health metrics (net worth, savings rate, EF, FI, milestones)
- `HealthMetricCard` — card widget with `showSetup` parameter for unconfigured features

### Established Patterns
- Pure static engine pattern for computations
- `ActionChip` quick actions on dashboard
- Settings tiles with `ListTile` + leading icon + trailing arrow
- `ColorTokens.of(context)` for theme-aware status colors

### Integration Points
- Planning dashboard — alert cards/badges need to integrate here
- Settings screen — extend Financial Planning section with additional tiles
- All planning screens — verify back button and navigation chain
- HomeShell — verify all screens reachable via tap chain from root

</code_context>

<specifics>
## Specific Ideas

No specific requirements — open to standard approaches for alert visual treatment, threshold values, and test organization. User focused discussion on navigation responsiveness and settings organization.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 13-planning-insights-integration-polish*
*Context gathered: 2026-03-24*
