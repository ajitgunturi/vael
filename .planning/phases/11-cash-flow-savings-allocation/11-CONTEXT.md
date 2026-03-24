# Phase 11: Cash Flow & Savings Allocation - Context

**Gathered:** 2026-03-24
**Status:** Ready for planning

<domain>
## Phase Boundary

Day-by-day cash flow projections from recurring rules with threshold alerts when balances dip below configurable minimums. Advisory surplus distribution across savings targets (EF, sinking funds, goals) with priority-ordered allocation rules. Opportunity fund designation for an account to hold unallocated surplus. No auto-transactions — advisory only (SAVE-04).

</domain>

<decisions>
## Implementation Decisions

### Cash Flow Calendar Layout
- Vertical timeline list, NOT calendar grid or hybrid
- Scrollable list of days, each showing income/expense items and running balance
- Matches existing transaction list pattern but grouped by date with running totals

### Day Row Content
- Grouped items with running balance — date header, then each income/expense item (name, amount, source recurring rule), plus running balance badge on the right
- No expand/collapse — all items visible inline per day
- Threshold alerts shown inline when balance dips

### Threshold Alerts
- Inline warning row inserted between days where the balance dip occurs
- Text format: "Balance drops to ₹X on [date] — below ₹Y minimum"
- Stays in the flow of the timeline — no top banner or persistent summary

### Balance Threshold Configuration
- Per-account configurable — each account gets its own minimum balance threshold
- Set in account settings or directly on the cash flow screen
- Examples: savings ₹50K minimum, current account ₹10K minimum

### Claude's Discretion
- Month navigation (forward/back arrows, swipe, or dropdown)
- Entry point for cash flow screen (dashboard tile, nav item, or account detail)
- Allocation rule creation UI (drag-to-reorder vs numbered priority, percentage vs fixed-amount)
- Opportunity fund designation flow
- Advisory output display format (waterfall chart vs table vs ordered list)
- How "apply" action works for surplus recommendations (pre-fill transactions vs just display)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Cash Flow
- `.planning/REQUIREMENTS.md` — FLOW-01 through FLOW-04: cash flow calendar requirements, threshold alert specs
- `lib/core/database/tables/recurring_rules.dart` — RecurringRules table schema (income/expense recurring items that feed cash flow projections)
- `lib/core/database/daos/recurring_rule_dao.dart` — RecurringRuleDao with `watchAll(familyId)` stream

### Savings Allocation
- `.planning/REQUIREMENTS.md` — SAVE-01 through SAVE-04: allocation rule requirements, advisory-only constraint
- `lib/core/database/tables/allocation_targets.dart` — AllocationTargets table (NOTE: this is for asset glide paths, NOT savings allocation — new table likely needed)
- `lib/core/financial/sinking_fund_engine.dart` — SinkingFundEngine (allocation target — `monthlyNeededPaise`)
- `lib/core/financial/emergency_fund_engine.dart` — EmergencyFundEngine (allocation target — `requiredAmountPaise`)

### Opportunity Fund
- `.planning/REQUIREMENTS.md` — OPP-01 through OPP-04: opportunity fund designation requirements
- `lib/core/database/tables/accounts.dart` — Accounts table (destination for OPP fund designation column)

### Prior Phase Patterns
- `lib/features/dashboard/screens/savings_rate_detail_screen.dart` — Savings rate screen (similar detail screen pattern)
- `lib/features/goals/screens/goal_list_screen.dart` — Tabbed screen pattern (4 tabs)
- `lib/core/database/tables/monthly_metrics.dart` — MonthlyMetrics caching pattern (reusable for cash flow caches)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `RecurringRuleDao.watchAll(familyId)` — already streams all recurring income/expense rules for a family
- `SinkingFundEngine.monthlyNeededPaise()` — calculates monthly target for each sinking fund goal
- `EmergencyFundEngine.requiredAmountPaise()` — calculates EF shortfall (allocation target)
- `MonthlyMetrics` table + `MonthlyMetricsDao.upsert()` — caching pattern for derived computations
- `SavingsRateTrendChart` — CustomPainter chart pattern (reusable for cash flow visualization)

### Established Patterns
- Integer arithmetic only: paise for money, basis points for rates (project-wide)
- Pure static engine classes: `SinkingFundEngine`, `EmergencyFundEngine` — cash flow projection engine should follow same pattern
- Provider-based state management with Riverpod `StreamProvider` for DB-backed streams
- Empty state using `EmptyState` widget

### Integration Points
- Dashboard screen — needs new tile/badge for cash flow health
- Account detail screen — threshold configuration entry point
- Settings > Financial Planning — opportunity fund designation alongside EF setup
- Goals providers — allocation rules reference sinking fund targets

</code_context>

<specifics>
## Specific Ideas

No specific requirements — open to standard approaches for allocation rules, opportunity fund, and advisory display. User focused discussion on cash flow calendar UX only.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 11-cash-flow-savings-allocation*
*Context gathered: 2026-03-24*
