# Feature Landscape: Financial Planning & Cash Management

**Domain:** Personal finance planning for Indian households (FI calculators, emergency funds, cash tiers, savings allocation, milestone tracking)
**Researched:** 2026-03-22
**Confidence:** HIGH (based on existing extension plan, India-native financial planning domain expertise, and competitive landscape analysis)

## Table Stakes

Features users expect from any financial planning tool. Missing = product feels incomplete for users who have set up their full financial picture in Phases 1-5 and are asking "am I on track?"

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| **Life Profile** (DOB, retirement age, risk tolerance) | Every planning calculation needs age context. Without it, projections are meaningless timelines with no personal anchor. | Low | Simple form + one Drift table. Minimal math. Foundation for everything else. |
| **Emergency Fund Tracker** | Universal financial advice starts here. Every Indian finance blog, SEBI advisory, and robo-advisor leads with "build 6 months expenses." Users who track budgets already have the data -- they expect the app to surface emergency coverage. | Medium | Needs budget integration (auto-compute essential expenses), account linking, income stability classification. Engine logic is straightforward (multiply + compare). |
| **FI Number Calculator** | The single most requested number in personal finance communities (r/FIREIndia, Freefincal, ET Money). Users manually compute this in spreadsheets -- a planning app without it feels incomplete. | Medium | Core formula is simple (expenses / SWR * inflation adjustment). The value is in years-to-FI iterative solver and Coast FI variant. Integer arithmetic with compound growth. |
| **Net Worth Milestones by Decade** | The "am I on track?" question. Users who track net worth (already built) need targets to compare against. Without milestones, net worth is a number without context. | Medium | Depends on life profile, income growth model, and blended return assumptions. Status computation (ON_TRACK/BEHIND/AHEAD) requires projected vs actual comparison. |
| **Savings Rate Trend** | The single strongest predictor of financial health. Users already have income and expense data -- not showing savings rate over time is leaving money on the table. Every competitor (Walnut, Money Manager, YNAB) shows this. | Medium | Needs balance snapshots (GAP C10). 12-month rolling computation from transaction history. Chart rendering with health bands (< 20% red, 20-30% yellow, > 30% green -- adjustable for India where 30%+ is common). |
| **Cash Flow Calendar** | Users with recurring rules (already built) expect to see when money arrives and leaves. This is the "will I have enough on the 5th when rent is due?" view. Table stakes for anyone managing tight monthly cash flow. | Medium | Day-by-day projection from recurring rules. Core challenge is rendering a calendar with income/expense overlays and running balance. Threshold alerts for low-balance days. |
| **Sinking Funds** | Distinct from investment goals. Users need "car insurance due in November, save 5K/month" buckets. These are short-term, deterministic, no-inflation, no-SIP. Every budgeting app (YNAB, Goodbudget) has these. | Low-Medium | Can reuse goal infrastructure with `goal_type = SINKING_FUND` flag. Different UX: no inflation, no SIP computation, simple target + deadline + progress bar. |

## Differentiators

Features that set Vael apart. Not expected but highly valued -- especially for the India-native, privacy-first, family-scoped context.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| **Asset Allocation Glide Path** (age-band targets with India-native defaults) | No Indian finance app provides deterministic age-based allocation with India-specific asset classes (PPF, EPF, NPS, Gold mapped to equity/debt/gold/cash). ET Money and Groww show current allocation but not targets. Vael would be the only offline, privacy-first app doing this. | Medium | Default glide paths by risk profile (conservative/moderate/aggressive). Maps existing investment_holdings buckets to four asset classes. Rebalancing delta as advisory output. |
| **Unified "5 Numbers" Planning Dashboard** | The BlackRock "one-page dashboard" concept: NW, Savings Rate, Emergency Coverage, FI Progress, Next Milestone. No Indian app distills planning into exactly 5 actionable numbers. This is the "open app, know your financial health in 10 seconds" promise from INTENT.md. | Medium-High | Aggregation screen pulling from 5 independent engines. Graceful degradation (show available metrics, CTA for missing ones). The design challenge is more UX than math. |
| **Savings Allocation Rules** (priority-ordered surplus distribution) | The "pay yourself first" system: when surplus arrives, allocate to Emergency Fund first (until funded), then sinking funds (by deadline), then investment goals (by priority). No Indian app does this deterministically. Vael shows *what to do* with surplus without auto-executing. | Medium | Priority waterfall engine. Advisory only (per INTENT.md -- user makes the judgment call). Consumes emergency fund status, sinking fund targets, goal priorities. |
| **Major Purchase Planner** (home, car, education with loan EMI impact) | Unique because it feeds back into projections. "If I buy a house at 35 with 20% down payment, how does it affect my FI date?" No Indian app connects purchase planning to FI calculations. | High | Needs goal-investment linking (GAP M5). One-time expense injection into projection engine. Optional loan creation post-purchase with EMI impact. Most complex feature in the set. |
| **Income Growth Model** (salary trajectory with career stages) | The projection engine currently uses flat income. Modeling 8-10% annual hikes (Indian IT industry norm), April hike month (Indian fiscal year), and career stage multipliers (early 1.2x, mid 1.0x, late 0.6x) makes projections dramatically more accurate. | Medium | Enriches existing ProjectionEngine (addresses GAP C7). India-specific: April salary hike month, dual-income modeling for families. |
| **Cash Tier Classification** (immediate / short-term / medium-term access) | Unique framing: maps each account to a liquidity tier. "Your savings account is IMMEDIATE (0 days), your liquid MF is SHORT_TERM (3 days), your FD is MEDIUM_TERM (90 days with penalty)." Helps users see their money's accessibility. No Indian app categorizes cash this way. | Low-Medium | Per-account metadata (tier + access days + interest rate). Aggregation by tier. Optimal distribution suggestion (1 month immediate, 2 months short-term, rest medium-term). |
| **Opportunity Fund Tracking** | Separate from emergency fund. "Money set aside for market dips, business opportunities, real estate deals." Distinct purpose prevents emergency fund erosion for non-emergencies. Uncommon feature -- only found in Schwab-style planning. | Low | Simple designation: one account or sub-amount as "opportunity fund" with target. Minimal engine logic. |
| **Lifetime Timeline Visualization** | Horizontal scrollable decade timeline showing: milestones, purchase goals, FI date, retirement. Visual representation of "your entire financial life on one screen." Unique in Indian app space. | High | Complex UI: horizontal scroll, milestone nodes, goal markers, FI marker. Needs all Phase 6 data as input. The engineering is primarily in the visualization, not the math. |
| **Family-Scoped Planning** | Each family member has their own life profile, milestones, and FI number -- but the family sees combined net worth and shared goals. No competitor offers per-member planning within a family boundary while keeping it private. | Medium | Leverages existing family/user/visibility architecture. Each new table is user_id + family_id scoped. The differentiation is architectural (already built), not feature-level. |

## Anti-Features

Features to explicitly NOT build. These violate INTENT.md principles or add complexity without value.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| **AI-powered spending predictions** | Violates INTENT.md principle 3 (deterministic over intelligent). Users should make their own judgments from clear numbers. | Show historical trends and deterministic projections. Let users draw their own conclusions. |
| **Bank API integration for auto-import** | Violates INTENT.md principle 1 (privacy non-negotiable) and anti-vision ("not a bank connector"). Would require sharing credentials with third parties. | Continue with CSV/PDF import. The manual data entry is a feature -- it keeps the trust boundary at the device. |
| **Automated transaction creation from savings rules** | Savings allocation should be advisory. Auto-creating transactions crosses from "instrument" to "agent" -- the user is the intelligence per INTENT.md. | Show allocation recommendations with amounts. User manually records transfers. |
| **Monte Carlo simulation for retirement** | Requires random number generation, probabilistic modeling. Violates deterministic principle. Results are hard to explain and reproduce. | Use deterministic compound growth with user-adjustable rates. Show sensitivity analysis (what if returns are 2% lower?) via slider, not simulation. |
| **Tax optimization suggestions** | Tax law changes annually. Hardcoding Section 80C/80D limits creates maintenance burden and regulatory risk. Would need server-side updates. | Track investments by type (PPF, ELSS, NPS) which users can use for their own tax planning. Do not compute tax liability or suggest tax-saving investments. |
| **Social comparison / benchmarking** | Violates anti-vision ("not a social app"). "You save more than 70% of Indians your age" is a dark pattern that creates anxiety. | Show personal trends over time. The comparison is you vs your own past, not you vs strangers. |
| **Legacy / estate planning** | Wills, trusts, and inheritance are legal documents that vary by religion (Hindu Succession Act, Muslim Personal Law, Indian Succession Act). Getting this wrong has legal consequences. | Track net worth milestones. Users can see what they'll leave behind without the app pretending to be a legal advisor. Originally in the BlackRock assessment but correctly deferred. |
| **High-yield savings account recommendations** | Recommending specific financial products introduces liability and conflicts of interest. Also requires real-time rate data (server dependency). | Show interest rates user enters for their own accounts. Cash tier view shows weighted average. User decides where to park money. |
| **Real-time market data / NAV updates** | Server dependency, API costs, and data licensing issues. Violates zero-cost principle. | User enters investment values during reconciliation. Manual but honest and free forever. |
| **Gamification (streaks, badges, points)** | Trivializes serious financial decisions. "You saved for 30 days in a row!" adds no value to someone planning retirement. | Status indicators (ON_TRACK/BEHIND/AHEAD) are the only feedback needed. Clear, honest, no dopamine tricks. |

## Feature Dependencies

```
Life Profile ─────────────────┬──→ Net Worth Milestones
                              ├──→ FI Calculator
                              ├──→ Asset Allocation Glide Path
                              ├──→ Income Growth Model
                              └──→ Major Purchase Planner

Budget (Essential Group) ─────→ Emergency Fund Tracker (auto-compute monthly essentials)

Accounts ─────────────────────┬──→ Cash Tier Classification (per-account tier)
                              └──→ Emergency Fund Tracker (linked accounts)

Recurring Rules ──────────────→ Cash Flow Calendar (daily projection source)

Balance Snapshots (GAP C10) ──→ Savings Rate Trend (historical monthly data)

Goal-Investment Link (GAP M5) → Major Purchase Planner (loan EMI impact on projections)

Income Growth Model ──────────→ Projection Engine Enhancement (GAP C7)

Emergency Fund Tracker ───┐
Sinking Funds ────────────┼──→ Savings Allocation Rules (priority waterfall targets)
Investment Goals ─────────┘

All Phase 6 features ─────────→ Lifetime Timeline Visualization
All Phase 6 + 7 features ────→ Unified Planning Dashboard ("5 Numbers")
```

### Critical Path

The dependency chain determines build order:

1. **Life Profile** first (everything depends on it)
2. **GAP remediation** (C7, C10, M5) in parallel with Life Profile
3. **Emergency Fund + Cash Tiers** (independent of Life Profile, can run in parallel)
4. **FI Calculator + Milestones + Allocation** (depend on Life Profile)
5. **Income Growth + Purchase Planner** (depend on Life Profile + GAP fixes)
6. **Savings Rate + Cash Flow Calendar** (depend on GAP C10 + Recurring Rules)
7. **Savings Allocation Rules** (depends on Emergency Fund + Sinking Funds + Goals)
8. **Timeline + Dashboard** (aggregation screens, depend on everything)

## MVP Recommendation

### Must ship (table stakes -- users who completed Phases 1-5 expect these):

1. **Life Profile** -- foundation, 1-2 days effort, unlocks everything
2. **Emergency Fund Tracker** -- most universally expected planning feature in India
3. **FI Calculator** -- the "number" everyone wants, high perceived value, medium effort
4. **Savings Rate Trend** -- leverages existing data, high daily utility
5. **Cash Flow Calendar** -- leverages recurring rules, daily-use feature

### Ship next (differentiators with highest value-to-effort ratio):

6. **Net Worth Milestones** -- "am I on track?" context for net worth
7. **Asset Allocation Glide Path** -- India-native defaults are unique
8. **Cash Tier Classification** -- low effort, reframes existing data
9. **Sinking Funds** -- reuses goal infrastructure, fills obvious gap

### Defer (high complexity, lower urgency):

- **Major Purchase Planner**: HIGH complexity, depends on GAP M5. Ship after core planning works.
- **Savings Allocation Rules**: Depends on emergency fund + sinking funds being populated. Ship after users have data.
- **Lifetime Timeline**: Visualization-heavy, depends on all Phase 6 data. Ship last as capstone.
- **Unified Dashboard**: Aggregation of all features. By definition, ship last.
- **Opportunity Fund**: Nice to have. Low effort but also low urgency. Can ship anytime.

## India-Native Context Notes

Features should default to Indian financial patterns:

| Pattern | Default Value | Rationale |
|---------|--------------|-----------|
| Retirement age | 60 | Standard Indian retirement age (government + most corporates) |
| Safe withdrawal rate | 4% (400 bps) | Standard globally; some Indian advisors argue 3-3.5% due to higher inflation |
| Expected inflation | 6% (600 bps) | RBI's long-term target band is 4-6%; realized CPI has averaged 5-7% |
| Income growth rate | 8% (800 bps) | Indian IT industry average annual hike; adjustable per user |
| Salary hike month | April | Indian fiscal year; most companies do April hikes |
| Emergency fund months | 6 (MODERATE stability) | Standard Indian financial advisor recommendation |
| Investment categories | PPF, EPF, NPS, ELSS, Gold, FD | India-specific tax-advantaged and traditional instruments |
| Currency | INR (paise) | Already implemented as integer arithmetic |

## Competitive Landscape (India)

| Competitor | What They Have | What They Lack | Vael's Advantage |
|------------|---------------|----------------|------------------|
| **ET Money** | SIP calculator, insurance analysis, portfolio tracking | No offline mode, server-dependent, no family planning, no FI calculator | Privacy-first, family-scoped, FI + milestones |
| **Groww** | Investment tracking, MF/stocks | No budgeting, no cash management, no planning layer | Full financial picture (budgets + investments + planning) |
| **Walnut** (EOL) | Expense tracking, SMS parsing | Shut down; was server-dependent | Vael is self-contained and will never shut down |
| **Money Manager** | Basic income/expense tracking | No investments, no planning, no family | Comprehensive planning intelligence layer |
| **YNAB** | Gold standard budgeting, sinking funds | USD-centric, subscription ($99/yr), no India-native features | Free forever, India-native, no subscription |
| **Freefincal tools** | Excel-based FI calculators, retirement planning | Spreadsheets, not an app. No portfolio tracking. | Integrated app experience with same-quality math |
| **fi.money / Jupiter** | Savings accounts, spend tracking | Bank-specific, server-dependent, no cross-bank view | Bank-agnostic, privacy-first |

## Sources

- Existing extension plan: `docs/EXTENSION_PLAN_FINANCIAL_PLANNING.md` (HIGH confidence -- first-party design document)
- Intent document: `docs/INTENT.md` (HIGH confidence -- governing principles)
- BlackRock planning methodology: `docs/agents/Lifetime-Planner.md` (HIGH confidence -- first-party)
- Charles Schwab cash management methodology: `docs/agents/Risk-Planner.md` (HIGH confidence -- first-party)
- Existing codebase: financial_math.dart, investment_holdings, recurring_rules, budgets, goals (HIGH confidence -- verified in code)
- India personal finance patterns: MEDIUM confidence -- based on domain knowledge of Indian financial planning ecosystem (SEBI guidelines, RBI inflation targets, Indian IT industry compensation patterns). Not verified with real-time web sources due to search unavailability.
- Competitor analysis: MEDIUM confidence -- based on training data knowledge of ET Money, Groww, YNAB, and Indian fintech landscape as of mid-2025. Specific feature sets may have changed.

---

*Last updated: 2026-03-22*
