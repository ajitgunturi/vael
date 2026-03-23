# Requirements: Vael Financial Planning Extension

**Defined:** 2026-03-22
**Core Value:** Privacy is non-negotiable. Data never leaves the device unencrypted. Zero-cost operation. Deterministic math only.

## v1 Requirements

Requirements for the financial planning extension (Phases 6-8). Each maps to roadmap phases.

### Life Profile

- [x] **LIFE-01**: User can create a life profile with date of birth, planned retirement age, and risk profile (conservative/moderate/aggressive)
- [x] **LIFE-02**: User can set annual income growth rate, expected inflation rate, and safe withdrawal rate (default 3% for India)
- [x] **LIFE-03**: Life profile is per-user within a family, respecting existing visibility boundaries
- [x] **LIFE-04**: User can edit their life profile at any time and see downstream calculations update

### Net Worth Milestones

- [x] **MILE-01**: User can see projected net worth milestones at ages 30, 40, 50, 60, and 70 based on current data and growth assumptions
- [x] **MILE-02**: Each milestone shows ON_TRACK, BEHIND, or AHEAD status comparing actual vs projected trajectory
- [x] **MILE-03**: Milestone projections use compound growth formula with blended return rates from actual investment holdings
- [x] **MILE-04**: User can set custom target amounts for any milestone age

### Financial Independence

- [x] **FI-01**: User can see their FI number (annual expenses / SWR adjusted for inflation to retirement)
- [x] **FI-02**: User can see years-to-FI based on current portfolio, savings rate, and returns
- [x] **FI-03**: User can see Coast FI number (portfolio value today that compounds to FI number with zero additional contributions)
- [x] **FI-04**: User can adjust withdrawal rate, return rate, and inflation via sliders to see sensitivity impact
- [x] **FI-05**: FI Calculator works as standalone even without life profile (editable placeholder inputs)

### Asset Allocation

- [x] **ALLOC-01**: User can see target asset allocation by age band (equity/debt/gold/cash) based on risk profile
- [x] **ALLOC-02**: Default India-native glide paths provided for conservative, moderate, and aggressive profiles
- [x] **ALLOC-03**: Current portfolio allocation computed from investment_holdings mapped to asset classes (MF/stocks→equity, PPF/EPF/FD/bonds→debt, etc.)
- [x] **ALLOC-04**: User can see rebalancing delta (actual % vs target %) as advisory output
- [x] **ALLOC-05**: User can customize allocation targets for any age band

### Income Growth

- [x] **INCOME-01**: User can model salary hike rate with career stage multipliers (early 1.2x, mid 1.0x, late 0.6x)
- [x] **INCOME-02**: User can set hike application month (default April for Indian fiscal year)
- [x] **INCOME-03**: Income growth model feeds into projection engine replacing flat income assumption (fixes GAP C7)
- [x] **INCOME-04**: User can model side income as separate recurring rules tagged as secondary income

### Major Purchase Planning

- [x] **PURCH-01**: User can create a major purchase goal (home, car, education) with target amount, target date, and down payment percentage
- [x] **PURCH-02**: Purchase goal shows impact on net worth trajectory and FI date (e.g., "buying house at 35 delays FI by 3 years")
- [x] **PURCH-03**: User can optionally create a linked loan with EMI that feeds back into recurring expenses post-purchase
- [x] **PURCH-04**: Education goals support year-specific cost escalation rate

### Emergency Fund

- [x] **EF-01**: User can configure emergency fund with target months (default based on income stability: stable=3, moderate=6, volatile=9-12)
- [x] **EF-02**: Monthly essential expenses auto-computed from budget ESSENTIAL group (3-month rolling average)
- [x] **EF-03**: User can link savings accounts to the emergency fund and see total coverage (months covered)
- [x] **EF-04**: User can manually override the target amount if auto-computation doesn't match their situation
- [x] **EF-05**: Emergency fund progress shows current balance vs target with visual progress indicator

### Cash Tiers

- [x] **TIER-01**: User can assign each account a liquidity tier (IMMEDIATE/0 days, SHORT_TERM/30 days, MEDIUM_TERM/90 days)
- [x] **TIER-02**: User can see aggregate balance by tier (interest rate display deferred — no interestRateBp column)
- [x] **TIER-03**: App suggests optimal tier distribution based on emergency fund target (1mo immediate, 2mo short-term, rest medium-term)
- [x] **TIER-04**: Account detail screen shows cash tier badge when tier is assigned

### Sinking Funds

- [ ] **SINK-01**: User can create sinking fund goals with target amount, deadline, and sub-type (car repair, medical, travel, insurance, tax, home maintenance, custom)
- [ ] **SINK-02**: Sinking funds show simple monthly savings target: (target - current) / months remaining
- [ ] **SINK-03**: Sinking funds display separately from investment goals on the Goals screen
- [ ] **SINK-04**: User can add contributions to sinking funds via pre-filled transaction form

### Cash Flow Calendar

- [ ] **FLOW-01**: User can see day-by-day income/expense map for any month based on recurring rules and known upcoming expenses
- [ ] **FLOW-02**: Running balance computed daily showing when balance dips below configurable threshold
- [ ] **FLOW-03**: Threshold alerts flag dates where running balance goes negative or below minimum
- [ ] **FLOW-04**: Tapping an income/expense item navigates to the source recurring rule or transaction

### Savings Allocation

- [ ] **SAVE-01**: User can create priority-ordered savings allocation rules targeting emergency fund, sinking funds, investment goals, or opportunity fund
- [ ] **SAVE-02**: Rules support fixed amount or percentage of surplus allocation types
- [ ] **SAVE-03**: Allocation engine processes rules in priority order, skipping targets that are already met
- [ ] **SAVE-04**: Output is advisory (shows where money should go) — does NOT auto-create transactions

### Savings Rate

- [ ] **RATE-01**: User can see monthly savings rate: (income - expenses) / income as percentage
- [ ] **RATE-02**: 12-month trend line displayed with health bands (green >= 20%, amber 10-20%, red < 10%)
- [ ] **RATE-03**: Historical monthly metrics stored for trend computation (requires GAP C10 balance snapshot resolution)
- [ ] **RATE-04**: Current month rate shown even with insufficient history for trend

### Opportunity Fund

- [ ] **OPP-01**: User can designate an account as opportunity fund with a target amount
- [ ] **OPP-02**: Opportunity fund tracked separately from emergency fund on settings/planning screens
- [ ] **OPP-03**: Opportunity fund can be a target in savings allocation rules

### Planning Dashboard

- [ ] **DASH-01**: User can see 5-number financial health view: Net Worth, Savings Rate, Emergency Coverage, FI Progress, Milestone Status
- [ ] **DASH-02**: Each metric is a tappable card drilling into its respective detail screen
- [ ] **DASH-03**: Dashboard shows only available metrics with "Set up" CTAs for unconfigured features (graceful degradation)
- [ ] **DASH-04**: "Financial Health" summary card added to main dashboard with "View All" link to planning dashboard

### Lifetime Timeline

- [ ] **TIME-01**: User can see horizontal scrollable decade timeline with current age, decade milestones, purchase goals, and FI date marker
- [ ] **TIME-02**: Timeline elements color-coded: green (on track), amber (at risk), red (behind)
- [ ] **TIME-03**: Tapping milestone/goal nodes navigates to respective detail screens

### Cash Flow Health

- [ ] **HEALTH-01**: User can see monthly cash flow health summary with total income vs expenses bar chart
- [ ] **HEALTH-02**: Savings waterfall visualization: income → expenses → EF → sinking funds → investments → unallocated
- [ ] **HEALTH-03**: Next 7-day cash flow mini-view with threshold alerts

### Planning Insights

- [ ] **INSIGHT-01**: "Emergency fund below target" alert shown with severity (months short)
- [ ] **INSIGHT-02**: "Asset allocation off-target" alert shown with severity (% deviation from glide path)
- [ ] **INSIGHT-03**: "FI date slipping" alert shown when projected FI date moves later than previous month
- [ ] **INSIGHT-04**: "Sinking fund underfunded" alert shown when monthly contribution is insufficient to meet deadline
- [ ] **INSIGHT-05**: All alerts are deterministic threshold calculations, not predictions

### Horizontal Integration

- [ ] **NAV-01**: All new screens reachable from HomeShell via tap navigation (no dead-end screens)
- [ ] **NAV-02**: Dashboard quick actions extended with "Cash Flow" and "Life Plan" buttons
- [ ] **NAV-03**: Settings screen extended with "Financial Planning" section (Life Profile, Allocation, EF Setup, Cash Tiers, Savings Rules, Opportunity Fund)
- [ ] **NAV-04**: Goals screen split into sections: Milestones, Sinking Funds, Investment Goals, Purchase Goals
- [x] **NAV-05**: Account detail shows cash tier and emergency fund badges when assigned
- [x] **NAV-06**: Budget screen shows monthly essentials row linking to emergency fund
- [x] **NAV-07**: Investment portfolio shows "Allocation vs Target" banner linking to allocation screen
- [ ] **NAV-08**: Every new screen has empty-state with navigable CTA when prerequisites are missing
- [ ] **NAV-09**: Navigation integration tests at 3 breakpoints (400dp, 750dp, 1200dp) — minimum 32 tests
- [ ] **NAV-10**: Cross-feature round-trip navigation tests verify back stack coherence

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### Advanced Planning

- **LEGACY-01**: Estate planning / wealth transfer modeling
- **MONTE-01**: Monte Carlo retirement simulation (if deterministic principle is relaxed)

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| AI/ML spending predictions | INTENT.md principle 3: deterministic over intelligent |
| Bank API integrations (Plaid/Yodlee) | INTENT.md principle 1: privacy non-negotiable |
| Auto-create transactions from savings rules | User is the intelligence; Vael is the instrument |
| Tax optimization suggestions | Tax law changes annually; regulatory risk |
| Social comparison / benchmarking | INTENT.md anti-vision: not a social app |
| Gamification (streaks, badges) | Trivializes financial decisions |
| Real-time market data / NAV updates | Server dependency, API costs, zero-cost violation |
| High-yield savings recommendations | Product recommendations introduce liability |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| LIFE-01 | Phase 6 | Complete |
| LIFE-02 | Phase 6 | Complete |
| LIFE-03 | Phase 6 | Complete |
| LIFE-04 | Phase 6 | Pending |
| INCOME-01 | Phase 6 | Complete |
| INCOME-02 | Phase 6 | Complete |
| INCOME-03 | Phase 6 | Complete |
| INCOME-04 | Phase 6 | Complete |
| FI-01 | Phase 7 | Complete |
| FI-02 | Phase 7 | Complete |
| FI-03 | Phase 7 | Complete |
| FI-04 | Phase 7 | Complete |
| FI-05 | Phase 7 | Complete |
| MILE-01 | Phase 7 | Complete |
| MILE-02 | Phase 7 | Complete |
| MILE-03 | Phase 7 | Complete |
| MILE-04 | Phase 7 | Complete |
| ALLOC-01 | Phase 8 | Complete |
| ALLOC-02 | Phase 8 | Complete |
| ALLOC-03 | Phase 8 | Complete |
| ALLOC-04 | Phase 8 | Complete |
| ALLOC-05 | Phase 8 | Complete |
| PURCH-01 | Phase 8 | Complete |
| PURCH-02 | Phase 8 | Complete |
| PURCH-03 | Phase 8 | Complete |
| PURCH-04 | Phase 8 | Complete |
| NAV-07 | Phase 8 | Complete |
| EF-01 | Phase 9 | Complete |
| EF-02 | Phase 9 | Complete |
| EF-03 | Phase 9 | Complete |
| EF-04 | Phase 9 | Complete |
| EF-05 | Phase 9 | Complete |
| TIER-01 | Phase 9 | Complete |
| TIER-02 | Phase 9 | Complete |
| TIER-03 | Phase 9 | Complete |
| TIER-04 | Phase 9 | Complete |
| NAV-05 | Phase 9 | Complete |
| NAV-06 | Phase 9 | Complete |
| SINK-01 | Phase 10 | Pending |
| SINK-02 | Phase 10 | Pending |
| SINK-03 | Phase 10 | Pending |
| SINK-04 | Phase 10 | Pending |
| RATE-01 | Phase 10 | Pending |
| RATE-02 | Phase 10 | Pending |
| RATE-03 | Phase 10 | Pending |
| RATE-04 | Phase 10 | Pending |
| NAV-04 | Phase 10 | Pending |
| FLOW-01 | Phase 11 | Pending |
| FLOW-02 | Phase 11 | Pending |
| FLOW-03 | Phase 11 | Pending |
| FLOW-04 | Phase 11 | Pending |
| SAVE-01 | Phase 11 | Pending |
| SAVE-02 | Phase 11 | Pending |
| SAVE-03 | Phase 11 | Pending |
| SAVE-04 | Phase 11 | Pending |
| OPP-01 | Phase 11 | Pending |
| OPP-02 | Phase 11 | Pending |
| OPP-03 | Phase 11 | Pending |
| DASH-01 | Phase 12 | Pending |
| DASH-02 | Phase 12 | Pending |
| DASH-03 | Phase 12 | Pending |
| DASH-04 | Phase 12 | Pending |
| TIME-01 | Phase 12 | Pending |
| TIME-02 | Phase 12 | Pending |
| TIME-03 | Phase 12 | Pending |
| HEALTH-01 | Phase 12 | Pending |
| HEALTH-02 | Phase 12 | Pending |
| HEALTH-03 | Phase 12 | Pending |
| NAV-02 | Phase 12 | Pending |
| INSIGHT-01 | Phase 13 | Pending |
| INSIGHT-02 | Phase 13 | Pending |
| INSIGHT-03 | Phase 13 | Pending |
| INSIGHT-04 | Phase 13 | Pending |
| INSIGHT-05 | Phase 13 | Pending |
| NAV-01 | Phase 13 | Pending |
| NAV-03 | Phase 13 | Pending |
| NAV-08 | Phase 13 | Pending |
| NAV-09 | Phase 13 | Pending |
| NAV-10 | Phase 13 | Pending |

**Coverage:**
- v1 requirements: 79 total
- Mapped to phases: 79
- Unmapped: 0

---
*Requirements defined: 2026-03-22*
*Last updated: 2026-03-22 after roadmap creation*
