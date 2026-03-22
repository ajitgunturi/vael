# Vael — Financial Planning Extension Plan

> **Two expert perspectives, one unified architecture.**
> This document extends the existing Vael roadmap (Phases 1–5) with financial planning capabilities inspired by institutional-grade methodologies from BlackRock (lifetime wealth roadmapping) and Charles Schwab (cash management and risk protection). All proposals are validated against `docs/INTENT.md` — no principle violations, no server dependencies, no AI/ML.

> **Important**: This plan introduces NO changes to existing code. It defines new features as additive extensions (Phase 6+) that build on the foundation already implemented in Phases 1–5.

---

## Table of Contents

1. [Perspective A: BlackRock Lifetime Planner Review](#perspective-a-blackrock-lifetime-planner)
2. [Perspective B: Charles Schwab Risk Planner Review](#perspective-b-charles-schwab-risk-planner)
3. [Consolidated Extension Architecture](#consolidated-extension-architecture)
4. [Horizontal Integration Strategy](#horizontal-integration-strategy)
5. [Phase 6: Lifetime Financial Planning](#phase-6-lifetime-financial-planning)
6. [Phase 7: Cash Management & Safety Nets](#phase-7-cash-management--safety-nets)
7. [Phase 8: Unified Planning Dashboard](#phase-8-unified-planning-dashboard)
8. [Data Model Extensions](#data-model-extensions)
9. [Financial Math Extensions](#financial-math-extensions)
10. [INTENT.md Compliance Validation](#intentmd-compliance-validation)
11. [Dependency on Gap Remediation](#dependency-on-gap-remediation)
12. [Concepts for Further Study](#concepts-for-further-study)

---

## Perspective A: BlackRock Lifetime Planner

### Current App Assessment

As a chief financial planning officer building decade-by-decade roadmaps, here is my assessment of Vael's current architecture through the lens of lifetime wealth building:

**Strengths the app already has:**

1. **Solid financial math core** — PMT, FV, PV, amortization, SIP calculations are implemented with integer-precision arithmetic. This is the correct foundation for deterministic projections.

2. **60-month projection engine** — The existing `ProjectionEngine` (Phase 4) provides the computational skeleton for long-range forecasting. However, per GAP_ANALYSIS C7, it is currently oversimplified — it takes flat income/expenses rather than consuming recurring rules, investment returns, or life-stage data.

3. **Investment holdings with bucket types** — The `investment_holdings` table supports MUTUAL_FUNDS, STOCKS, PPF, EPF, NPS, FIXED_DEPOSIT, BONDS, POLICY. This is the right taxonomy for an India-native portfolio, and directly maps to how BlackRock would categorize asset allocation by life stage.

4. **Goal tracking with inflation adjustment** — Goals already compute inflation-adjusted targets and required SIP. This is the building block for decade-milestone planning.

**What's missing for a lifetime financial roadmap:**

1. **No life-stage awareness** — The app treats all financial data as a flat timeline. A 28-year-old's financial plan looks structurally identical to a 55-year-old's. There is no concept of decades, life milestones (home purchase, children's education, retirement), or age-based portfolio evolution.

2. **No net worth milestone tracking** — The app computes current net worth but has no mechanism to set target net worth at future ages (30, 40, 50, 60, 70) and track progress toward them.

3. **No income growth modeling** — The projection engine uses flat income. Real financial planning requires modeling career trajectory: salary hikes, job changes, side income emergence, and eventual income decline in retirement.

4. **No asset allocation evolution** — A 25-year-old should be 80% equity / 20% debt. A 55-year-old should be 40% equity / 60% debt. The app tracks investment buckets but has no concept of target allocation shifting over time.

5. **No financial independence (FI) number** — The app has goals but no mechanism to compute the portfolio value at which work becomes optional (typically 25-30x annual expenses, adjusted for inflation and withdrawal rate).

6. **No legacy planning** — No concept of estate planning targets, wealth transfer strategies, or intergenerational financial modeling.

7. **No monthly tracking dashboard** — While the dashboard shows net worth and monthly summary, there is no "5 numbers that tell you if you're on track" distilled view per the BlackRock methodology.

### Recommended Extensions

| Priority | Feature | Maps To |
|----------|---------|---------|
| **P0** | Life Profile (DOB, retirement age, risk profile) | Decade milestones, FI number |
| **P0** | Net Worth Milestones by decade | Target tracking |
| **P1** | Income Growth Model (salary trajectory + hikes) | Projection enrichment |
| **P1** | Asset Allocation Targets by age band | Portfolio evolution |
| **P1** | Financial Independence Calculator | FI number |
| **P2** | Major Purchase Planner (home, car, education) | Goal enhancement |
| **P2** | Legacy Target & Wealth Transfer Model | Estate planning |
| **P3** | Lifetime Tracking Dashboard (5 key numbers) | Monthly check-in |

---

## Perspective B: Charles Schwab Risk Planner

### Current App Assessment

As a senior financial planning director building bulletproof safety nets, here is my assessment of Vael through the lens of cash management and emergency preparedness:

**Strengths the app already has:**

1. **Account type taxonomy** — SAVINGS, CURRENT, CREDIT_CARD, LOAN, INVESTMENT, WALLET cover the essential account types for cash placement strategy.

2. **Budget tracking with overspend alerts** — The budget system with category groups (ESSENTIAL, NON_ESSENTIAL, INVESTMENTS, HOME_EXPENSES) and actual-vs-limit tracking is the foundation for expense-based emergency fund sizing.

3. **Recurring rules engine** — The recurring transaction system (Phase 4) models regular income and expenses, which is exactly what a cash flow calendar needs.

4. **Balance reconciliation** — Automatic balance verification ensures cash position accuracy.

**What's missing for a cash management strategy:**

1. **No emergency fund concept** — The app has savings accounts but no mechanism to designate a specific account or amount as an emergency fund, track its target (3-6-12 months of expenses), or measure progress toward that target.

2. **No cash tier system** — There is no distinction between immediate-access cash (savings account), 30-day access (liquid mutual funds), and 90-day access (FDs with penalty). Cash is either in an account or it isn't.

3. **No sinking funds** — The app has goals but no concept of purpose-specific savings buckets for predictable expenses (car repair, medical, travel, annual insurance). These are fundamentally different from investment goals — they are short-term, deterministic, and should not be invested aggressively.

4. **No automated savings rules** — While recurring transactions exist, there is no "pay yourself first" automation concept — rules that automatically allocate income to emergency fund, sinking funds, and investment goals in priority order.

5. **No cash flow calendar** — The app shows monthly summaries but not a day-by-day map of when income arrives and when expenses hit. This is critical for avoiding overdrafts and optimizing timing of transfers.

6. **No opportunity fund** — No concept of money set aside specifically for unexpected investment opportunities (market dips, business opportunities, real estate deals) — distinct from emergency fund.

7. **No cash vs. investment decision framework** — No tool to help decide when additional savings should go to cash reserves vs. investment, based on current emergency coverage, market conditions (interest rates), and near-term expense obligations.

8. **No savings rate tracking over time** — The dashboard computes current-month savings rate, but there is no trend line showing how savings rate has evolved, which is the single most important predictor of financial health.

### Recommended Extensions

| Priority | Feature | Maps To |
|----------|---------|---------|
| **P0** | Emergency Fund Tracker (target, progress, months covered) | Safety net |
| **P0** | Cash Tier Classification (immediate / 30-day / 90-day) | Account placement |
| **P1** | Sinking Funds (purpose buckets with target + deadline) | Predictable expenses |
| **P1** | Cash Flow Calendar (daily income/expense map) | Overdraft prevention |
| **P1** | Savings Rate Trend (historical monthly % chart) | Health tracking |
| **P2** | Savings Allocation Rules (priority-ordered auto-distribute) | Pay yourself first |
| **P2** | Opportunity Fund (separate designation + target) | Investment readiness |
| **P3** | Cash vs. Investment Decision Matrix | Allocation guidance |

---

## Consolidated Extension Architecture

Both planners converge on a core insight: **Vael has excellent plumbing (accounts, transactions, crypto, sync) but lacks the planning intelligence layer that turns raw data into actionable financial strategy.** The extensions below build this layer using deterministic math — no AI/ML, no external APIs, no server dependencies.

### Architecture Layer Map

```
┌──────────────────────────────────────────────────────────────┐
│                    NEW: Planning Intelligence Layer           │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────────┐ │
│  │ Life Profile  │  │ Cash Mgmt    │  │ Unified Planning   │ │
│  │ & Milestones  │  │ Engine       │  │ Dashboard          │ │
│  │ (BlackRock)   │  │ (Schwab)     │  │ (consolidated)     │ │
│  └──────┬───────┘  └──────┬───────┘  └────────┬───────────┘ │
│         │                  │                    │             │
│  ┌──────┴──────────────────┴────────────────────┴──────────┐ │
│  │              NEW: Financial Planning Math                │ │
│  │  FI calculator, allocation targets, cash tier rules,    │ │
│  │  savings rate trend, milestone projections               │ │
│  └──────────────────────┬──────────────────────────────────┘ │
├─────────────────────────┼────────────────────────────────────┤
│  EXISTING CORE          │                                    │
│  ┌──────────────────────┴──────────────────────────────────┐ │
│  │  Financial Math · Projection Engine · Goal Tracking     │ │
│  │  Budget Summary · Investment Baselines · Recurring      │ │
│  └──────────────────────┬──────────────────────────────────┘ │
│  ┌──────────────────────┴──────────────────────────────────┐ │
│  │  drift DB · DAOs · Riverpod · Crypto · Sync            │ │
│  └─────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

### Design Principles for Extensions

1. **Deterministic only** — All calculations use formulas (compound interest, FV, PMT, withdrawal rates). No predictions, no ML.
2. **User-provided inputs** — Life profile data (DOB, retirement age, risk tolerance) is entered by the user, not inferred.
3. **Integer arithmetic** — All monetary values in paise (minor units) per existing convention.
4. **Local-first** — All planning data stored in drift tables, encrypted via SQLCipher, synced via existing changeset mechanism.
5. **Family-scoped** — Each family member can have their own life profile and planning preferences, respecting visibility boundaries.
6. **Additive schema** — New tables added via drift schema migration. No existing table modifications.

---

## Horizontal Integration Strategy

> **Non-negotiable principle**: A screen that exists but cannot be reached by tapping through the running app **does not exist** from the user's perspective. Every feature in Phases 6-8 must be horizontally wired before it is marked complete.

This section defines the complete navigation integration plan — how every new screen connects into the existing app shell, how features cross-reference each other, and how integration tests verify the full graph.

### Current Navigation Topology (Baseline)

```
VaelApp
├─ OnboardingFlow (if no session)
├─ LockScreen (if locked)
└─ HomeShell
   ├─ Tab 0: Dashboard ──────→ [7 quick action entry points]
   │  ├─ Hero NW Card ──────→ Tab 1 (Accounts)
   │  ├─ Income Tile ───────→ Tab 2 (Transactions)
   │  ├─ Expenses Tile ─────→ Tab 3 (Budget)
   │  ├─ "Add Transaction" ─→ TransactionFormScreen
   │  ├─ "View Accounts" ──→ Tab 1
   │  ├─ "Investments" ────→ InvestmentPortfolioScreen
   │  ├─ "Recurring" ──────→ RecurringRulesScreen
   │  └─ "60-Mo Projection"→ ProjectionScreen
   │
   ├─ Tab 1: Accounts ──→ AccountDetail / LoanDetail → AccountForm
   ├─ Tab 2: Transactions ──→ TransactionForm / StatementImport
   ├─ Tab 3: Budget ──→ BudgetForm
   ├─ Tab 4: Goals ──→ GoalForm
   └─ Settings (gear icon) ──→ Backup / Sync / Passphrase
```

### Extended Navigation Topology (After Phases 6-8)

The strategy is: **do NOT add more bottom tabs** (5 is the UX limit). Instead, surface new features through three integration patterns:

1. **Dashboard Quick Actions** — the dashboard is already the hub; add new action tiles
2. **Contextual Navigation** — from existing screens to related planning screens (e.g., account detail → cash tier, goal → milestone link)
3. **Settings/Planning Section** — a dedicated "Financial Planning" section in Settings for setup screens (life profile, allocation targets, emergency fund config)

```
HomeShell (UNCHANGED — still 5 tabs)
│
├─ Tab 0: Dashboard (EXTENDED)
│  ├─ [existing 7 quick actions]
│  │
│  ├─ NEW: "Financial Health" card ──→ PlanningDashboardScreen (Phase 8.1)
│  │   ├─ NW card tap ──→ (existing) Tab 1
│  │   ├─ Savings Rate tap ──→ SavingsRateTrendScreen (7.6)
│  │   ├─ Emergency Coverage tap ──→ EmergencyFundScreen (7.1)
│  │   ├─ FI Progress tap ──→ FiCalculatorScreen (6.3)
│  │   └─ Milestone Status tap ──→ MilestoneDashboardScreen (6.2)
│  │
│  ├─ NEW: "Cash Flow" quick action ──→ CashFlowCalendarScreen (7.4)
│  │
│  └─ NEW: "Life Plan" quick action ──→ LifetimeTimelineScreen (8.2)
│      ├─ Milestone node tap ──→ MilestoneDashboardScreen (6.2)
│      ├─ Purchase goal node tap ──→ GoalForm (existing, edit mode)
│      └─ FI marker tap ──→ FiCalculatorScreen (6.3)
│
├─ Tab 1: Accounts (EXTENDED)
│  └─ AccountDetailScreen
│     ├─ [existing: Edit, LoanDetail]
│     ├─ NEW: "Cash Tier" badge on account card ──→ CashTierScreen (7.2)
│     └─ NEW: "Emergency Fund" badge (if linked) ──→ EmergencyFundScreen (7.1)
│
├─ Tab 2: Transactions (UNCHANGED)
│
├─ Tab 3: Budget (EXTENDED)
│  └─ BudgetScreen
│     └─ NEW: "Monthly essentials" summary row
│        └─ onTap ──→ EmergencyFundScreen (shows how essentials feed EF target)
│
├─ Tab 4: Goals (EXTENDED)
│  └─ GoalListScreen
│     ├─ NEW: Section header "Sinking Funds" (if any sinking fund goals exist)
│     │   └─ Sinking fund card tap ──→ SinkingFundDetailScreen (7.3)
│     ├─ NEW: Section header "Investment Goals" (existing goals)
│     ├─ NEW: Section header "Purchase Goals" (if any)
│     │   └─ Purchase goal card tap ──→ GoalForm with purchase planner fields (6.6)
│     └─ NEW: "Milestones" section at top (if life profile exists)
│         └─ Milestone card tap ──→ MilestoneDashboardScreen (6.2)
│
├─ Settings (gear icon) (EXTENDED)
│  └─ SettingsScreen
│     ├─ [existing: Backup, Sync, Passphrase, Theme, Sign Out]
│     │
│     ├─ NEW SECTION: "Financial Planning"
│     │  ├─ "Life Profile" tile ──→ LifeProfileScreen (6.1)
│     │  │   └─ On first save → prompts milestone setup
│     │  ├─ "Allocation Targets" tile ──→ AllocationScreen (6.4)
│     │  ├─ "Emergency Fund Setup" tile ──→ EmergencyFundConfigScreen (7.1 config)
│     │  │   └─ Account linking picker → accounts list
│     │  ├─ "Cash Tier Setup" tile ──→ CashTierConfigScreen (7.2 config)
│     │  │   └─ Per-account tier assignment
│     │  └─ "Savings Rules" tile ──→ SavingsAllocationScreen (7.5)
│     │      └─ Rule form → target picker (EF / sinking / goal)
│     │
│     └─ NEW: "Opportunity Fund" tile (if configured) ──→ OpportunityFundScreen (7.7)
│
└─ InvestmentPortfolioScreen (from Dashboard quick action)
   ├─ [existing: FAB → InvestmentForm]
   └─ NEW: "Allocation vs Target" banner at top
      └─ onTap ──→ AllocationScreen (6.4)
         ├─ Current vs target pie charts
         └─ Rebalancing delta list
```

### Screen-by-Screen Entry Point Matrix

Every new screen MUST have at least one `Navigator.push` path from an existing screen. This matrix is the checklist — if any "Entry Points" column is empty, the feature is incomplete.

#### Phase 6 Screens

| Screen | File Path | Entry Points | Empty-State Behavior |
|--------|-----------|-------------|---------------------|
| **LifeProfileScreen** | `features/planning/screens/life_profile_screen.dart` | Settings → "Life Profile" tile | Form with sensible defaults (age 25, retirement 60, moderate risk) |
| **MilestoneDashboardScreen** | `features/planning/screens/milestone_dashboard_screen.dart` | 1. Dashboard → Financial Health card → Milestone Status tap | "Set up Life Profile first" CTA → navigates to LifeProfileScreen |
| | | 2. Goals tab → Milestones section → milestone card tap | |
| | | 3. Lifetime Timeline → milestone node tap | |
| **FiCalculatorScreen** | `features/planning/screens/fi_calculator_screen.dart` | 1. Dashboard → Financial Health card → FI Progress tap | Shows calculator with placeholder inputs if no life profile |
| | | 2. Lifetime Timeline → FI marker tap | |
| **AllocationScreen** | `features/planning/screens/allocation_screen.dart` | 1. Settings → "Allocation Targets" tile | Default glide path shown; current portfolio from investment_holdings |
| | | 2. InvestmentPortfolioScreen → "Allocation vs Target" banner | |
| **LifetimeTimelineScreen** | `features/planning/screens/lifetime_timeline_screen.dart` | 1. Dashboard → "Life Plan" quick action | "Set up Life Profile first" CTA if no profile exists |
| | | 2. MilestoneDashboardScreen → "View Timeline" button | |

#### Phase 7 Screens

| Screen | File Path | Entry Points | Empty-State Behavior |
|--------|-----------|-------------|---------------------|
| **EmergencyFundScreen** | `features/cash_management/screens/emergency_fund_screen.dart` | 1. Dashboard → Financial Health card → Emergency Coverage tap | "Set up Emergency Fund" CTA → navigates to config in Settings |
| | | 2. Settings → "Emergency Fund Setup" tile | |
| | | 3. Budget screen → monthly essentials row tap | |
| | | 4. Account detail → "Emergency Fund" badge tap (if linked) | |
| **CashTierScreen** | `features/cash_management/screens/cash_tier_screen.dart` | 1. Settings → "Cash Tier Setup" tile | "Assign tiers to your accounts" CTA with account list |
| | | 2. Account detail → "Cash Tier" badge tap | |
| **SinkingFundDetailScreen** | `features/cash_management/screens/sinking_fund_detail_screen.dart` | 1. Goals tab → Sinking Funds section → card tap | N/A (only reachable when sinking fund exists) |
| | | 2. Savings allocation screen → target tap (if sinking fund) | |
| **CashFlowCalendarScreen** | `features/cash_management/screens/cash_flow_calendar_screen.dart` | 1. Dashboard → "Cash Flow" quick action | Shows current month; empty if no recurring rules ("Set up recurring income/expenses first") |
| | | 2. Planning Dashboard → Cash Flow Health → "View Calendar" | |
| **SavingsAllocationScreen** | `features/cash_management/screens/savings_allocation_screen.dart` | 1. Settings → "Savings Rules" tile | "Create your first savings rule" CTA with explanation of priority waterfall |
| **SavingsRateTrendScreen** | `features/cash_management/screens/savings_rate_trend_screen.dart` | 1. Dashboard → Financial Health card → Savings Rate tap | Shows current month rate; "Need 3+ months of data for trend" if insufficient history |
| **OpportunityFundScreen** | `features/cash_management/screens/opportunity_fund_screen.dart` | 1. Settings → "Opportunity Fund" tile | "Designate an account as your opportunity fund" CTA |

#### Phase 8 Screens

| Screen | File Path | Entry Points | Empty-State Behavior |
|--------|-----------|-------------|---------------------|
| **PlanningDashboardScreen** | `features/planning/screens/planning_dashboard_screen.dart` | 1. Dashboard → "Financial Health" card (primary entry) | Graceful degradation: shows only available metrics; "Complete setup" CTAs for missing ones |
| **LifetimeTimelineScreen** | (from 6.7, but wired in Phase 8) | (see Phase 6 entry points above) | |
| **CashFlowHealthScreen** | `features/planning/screens/cash_flow_health_screen.dart` | 1. Planning Dashboard → Cash Flow Health section tap | Shows current month summary; links to CashFlowCalendarScreen for details |

### Cross-Feature Navigation (Contextual Links)

These are the critical "horizontal stitches" that make the app feel like one product rather than isolated feature silos:

#### From Existing Screens INTO New Features

| Source Screen | Trigger | Target Screen | Rationale |
|--------------|---------|--------------|-----------|
| **DashboardScreen** | New "Financial Health" summary card | PlanningDashboardScreen | Primary entry to all planning features |
| **DashboardScreen** | New "Cash Flow" quick action button | CashFlowCalendarScreen | Day-by-day cash map is a daily-use feature |
| **DashboardScreen** | New "Life Plan" quick action button | LifetimeTimelineScreen | Decade-level view for periodic review |
| **AccountListScreen** | Cash tier badge on account card | CashTierScreen | See which tier an account belongs to |
| **AccountDetailScreen** | "Emergency Fund" linked badge | EmergencyFundScreen | See EF contribution of this account |
| **AccountDetailScreen** | "Cash Tier: IMMEDIATE" info chip | CashTierScreen | Context for account's liquidity classification |
| **BudgetScreen** | Monthly essentials total row | EmergencyFundScreen | Essentials drive EF target |
| **GoalListScreen** | Sinking fund section header | SinkingFundDetailScreen | Different UX for short-term deterministic goals |
| **GoalListScreen** | Milestones section at top | MilestoneDashboardScreen | Decade targets shown alongside regular goals |
| **InvestmentPortfolioScreen** | "Allocation vs Target" banner | AllocationScreen | See rebalancing recommendations |
| **SettingsScreen** | New "Financial Planning" section | Various config screens | Setup hub for all planning parameters |

#### From New Features BACK TO Existing Screens

| Source Screen | Trigger | Target Screen | Rationale |
|--------------|---------|--------------|-----------|
| **EmergencyFundScreen** | "Link accounts" button | Account picker (modal) | Choose which accounts form the EF |
| **EmergencyFundScreen** | "View budget essentials" link | Tab 3 (Budget) | See the expenses driving EF target |
| **FiCalculatorScreen** | "View investments" link | InvestmentPortfolioScreen | See current portfolio feeding FI progress |
| **AllocationScreen** | "View holdings" link | InvestmentPortfolioScreen | See actual investments to rebalance |
| **MilestoneDashboardScreen** | "Edit life profile" button | LifeProfileScreen | Adjust DOB/retirement age/risk profile |
| **SavingsAllocationScreen** | Target entity tap | GoalForm / EmergencyFundScreen | Navigate to the thing being funded |
| **CashFlowCalendarScreen** | Income/expense item tap | TransactionForm (if manual) or RecurringRulesScreen | Edit the source rule |
| **SinkingFundDetailScreen** | "Add contribution" button | TransactionFormScreen (pre-filled) | Record actual contribution as transaction |
| **PlanningDashboardScreen** | Each of the 5 metric cards | Respective detail screen | Drill-down from summary to detail |

#### Between New Features (Cross-Phase Links)

| Source | Trigger | Target | Rationale |
|--------|---------|--------|-----------|
| **MilestoneDashboardScreen** | "Adjust allocation" CTA (when behind) | AllocationScreen | If behind on NW milestone, check if allocation is off |
| **FiCalculatorScreen** | "Emergency fund status" info row | EmergencyFundScreen | FI planning should surface safety net status |
| **EmergencyFundScreen** | "View savings rate trend" link | SavingsRateTrendScreen | Savings rate determines how fast EF fills |
| **SavingsAllocationScreen** | "View cash flow" link | CashFlowCalendarScreen | See when surplus is available for allocation |
| **AllocationScreen** | "View FI impact" link | FiCalculatorScreen | See how allocation change affects FI date |
| **LifetimeTimelineScreen** | Emergency fund milestone marker | EmergencyFundScreen | EF fully funded is a milestone on the timeline |
| **CashFlowCalendarScreen** | Threshold alert tap | SavingsAllocationScreen | When cash dips, review allocation priorities |

### Dashboard Modifications (Detailed)

The Dashboard is the gravitational center. Here is exactly what changes:

**Current Quick Actions Row** (4 buttons):
```
[ Add Transaction ] [ View Accounts ] [ Investments ] [ Recurring ]
```

**Extended Quick Actions** (wrap to 2 rows on phone, single row on tablet):
```
Row 1: [ Add Transaction ] [ View Accounts ] [ Investments ] [ Recurring ]
Row 2: [ Cash Flow ] [ Life Plan ] [ 60-Mo Projection ]
```

**New "Financial Health" Card** (below quick actions, above goals section):
```
┌─────────────────────────────────────────────────────┐
│  Financial Health                          View All →│
│                                                      │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────────┐ │
│  │ NW   │ │Save% │ │Emerg.│ │ FI%  │ │Next Mile │ │
│  │₹24.5L│ │ 32%  │ │4.2mo │ │ 18%  │ │30: ₹50L  │ │
│  │ +2%  │ │  🟢  │ │  🟡  │ │      │ │ON TRACK  │ │
│  └──┬───┘ └──┬───┘ └──┬───┘ └──┬───┘ └────┬─────┘ │
│     │        │        │        │           │        │
│  (tap→    (tap→    (tap→    (tap→FI    (tap→Mile   │
│  Accts)   SavRate) EmFund)  Calc)      stones)     │
└─────────────────────────────────────────────────────┘
```

On phone: horizontally scrollable row of 5 mini-cards.
On tablet/desktop: all 5 cards visible in a single row.

Each card shows the metric only if the underlying data exists. If not:
- No life profile → FI% and Milestone cards show "Set up →" CTA
- No emergency fund config → Emergency card shows "Set up →" CTA
- No transaction history → Savings Rate shows "—"

**"View All →"** in the card header navigates to `PlanningDashboardScreen`.

### HomeShell Modifications

The `HomeShell` widget itself does NOT change its tab count (stays at 5). The modifications are:

1. **DashboardScreen** receives two new callbacks:
   - `onNavigateToPlanningScreen(PlanningDestination destination)` — routes to Phase 6/7/8 screens
   - This follows the existing pattern where `onNavigateToTab` handles tab switches

2. **GoalListScreen** adds section headers based on `goal_category`:
   - Milestones section (from `net_worth_milestones`)
   - Sinking Funds section (goals where `goal_category = SINKING_FUND`)
   - Investment Goals section (existing goals, `goal_category = INVESTMENT_GOAL`)
   - Purchase Goals section (goals where `goal_category = PURCHASE_GOAL`)

3. **SettingsScreen** adds a "Financial Planning" `ListTile` group between existing sections.

### Horizontal Integration Tests (Mandatory)

Per CLAUDE.md: every phase that introduces new screens MUST have navigation integration tests that verify the screen is reachable via tap interaction from the app shell.

#### Phase 6 Integration Tests

**6.E2E.NAV — Lifetime Planning Navigation** (~8 tests)
`integration_test/phase6_navigation_test.dart`

| # | Test | Start | Taps | Assert |
|---|------|-------|------|--------|
| 1 | Life Profile reachable from Settings | HomeShell | Gear icon → "Life Profile" tile | LifeProfileScreen renders |
| 2 | Milestones reachable from Dashboard | HomeShell | "Financial Health" card → Milestone Status | MilestoneDashboardScreen renders |
| 3 | Milestones reachable from Goals tab | HomeShell | Goals tab → Milestones section → card | MilestoneDashboardScreen renders |
| 4 | FI Calculator reachable from Dashboard | HomeShell | "Financial Health" card → FI Progress | FiCalculatorScreen renders |
| 5 | Allocation reachable from Settings | HomeShell | Gear icon → "Allocation Targets" | AllocationScreen renders |
| 6 | Allocation reachable from Investments | HomeShell | Dashboard → "Investments" → "Allocation vs Target" banner | AllocationScreen renders |
| 7 | Lifetime Timeline reachable from Dashboard | HomeShell | "Life Plan" quick action | LifetimeTimelineScreen renders |
| 8 | Timeline → Milestone drill-down | HomeShell | "Life Plan" → milestone node tap | MilestoneDashboardScreen renders |

All tests run on both iPhone (400dp) and iPad Pro (1200dp).

#### Phase 7 Integration Tests

**7.E2E.NAV — Cash Management Navigation** (~10 tests)
`integration_test/phase7_navigation_test.dart`

| # | Test | Start | Taps | Assert |
|---|------|-------|------|--------|
| 1 | Emergency Fund from Dashboard | HomeShell | "Financial Health" card → Emergency Coverage | EmergencyFundScreen renders |
| 2 | Emergency Fund from Settings | HomeShell | Gear → "Emergency Fund Setup" | EmergencyFundScreen (config mode) renders |
| 3 | Emergency Fund from Budget | HomeShell | Budget tab → "Monthly essentials" row | EmergencyFundScreen renders |
| 4 | Cash Tier from Settings | HomeShell | Gear → "Cash Tier Setup" | CashTierScreen renders |
| 5 | Cash Tier from Account Detail | HomeShell | Accounts tab → account tile → "Cash Tier" badge | CashTierScreen renders |
| 6 | Cash Flow Calendar from Dashboard | HomeShell | "Cash Flow" quick action | CashFlowCalendarScreen renders |
| 7 | Sinking Fund from Goals | HomeShell | Goals tab → "Sinking Funds" section → card | SinkingFundDetailScreen renders |
| 8 | Savings Allocation from Settings | HomeShell | Gear → "Savings Rules" | SavingsAllocationScreen renders |
| 9 | Savings Rate Trend from Dashboard | HomeShell | "Financial Health" card → Savings Rate | SavingsRateTrendScreen renders |
| 10 | Opportunity Fund from Settings | HomeShell | Gear → "Opportunity Fund" | OpportunityFundScreen renders |

#### Phase 8 Integration Tests

**8.E2E.NAV — Unified Dashboard Navigation** (~6 tests)
`integration_test/phase8_navigation_test.dart`

| # | Test | Start | Taps | Assert |
|---|------|-------|------|--------|
| 1 | Planning Dashboard from Dashboard | HomeShell | "Financial Health" → "View All" | PlanningDashboardScreen renders with 5 metric cards |
| 2 | Planning Dashboard → FI drill-down | HomeShell | Planning Dashboard → FI card | FiCalculatorScreen renders |
| 3 | Planning Dashboard → Emergency drill-down | HomeShell | Planning Dashboard → Emergency card | EmergencyFundScreen renders |
| 4 | Planning Dashboard → Milestones drill-down | HomeShell | Planning Dashboard → Milestone card | MilestoneDashboardScreen renders |
| 5 | Planning Dashboard → Cash Flow Health | HomeShell | Planning Dashboard → Cash Flow section | CashFlowHealthScreen renders |
| 6 | Cash Flow Health → Calendar | HomeShell | Cash Flow Health → "View Calendar" | CashFlowCalendarScreen renders |

#### Cross-Feature Navigation Tests

**X.E2E.NAV — Cross-Feature Stitching** (~8 tests)
`integration_test/cross_feature_navigation_test.dart`

| # | Test | Flow | Assert |
|---|------|------|--------|
| 1 | EF → Budget round-trip | Emergency Fund → "View budget essentials" → Budget tab → back | Both screens render, back returns to EF |
| 2 | FI → Investments round-trip | FI Calculator → "View investments" → Portfolio → back | Both screens render |
| 3 | Allocation → Investments round-trip | Allocation → "View holdings" → Portfolio → back | Both screens render |
| 4 | Milestones → Life Profile edit | Milestones → "Edit life profile" → LifeProfileScreen | LifeProfileScreen renders in edit mode |
| 5 | Sinking Fund → Transaction creation | Sinking Fund → "Add contribution" → TransactionForm | Form pre-filled with sinking fund target |
| 6 | Cash Flow → Recurring Rules | Cash Flow → expense item tap → RecurringRulesScreen | Recurring screen renders |
| 7 | Savings Allocation → Goal | Savings Allocation → target tap (investment goal) → GoalForm | GoalForm renders in edit mode |
| 8 | Dashboard → full planning loop | Dashboard → Financial Health → FI → back → Emergency → back → Milestones → Timeline | All screens reachable in sequence, back stack coherent |

### Empty-State Navigation (Critical UX Requirement)

New features have dependencies — FI Calculator needs a life profile, Emergency Fund needs config. Without careful empty-state design, users hit dead ends.

**Rule: Every screen must be navigable and renderable even with zero data. Never show a blank screen or crash.**

| Screen | Missing Data | Empty-State Behavior |
|--------|-------------|---------------------|
| MilestoneDashboardScreen | No life profile | "Set up your Life Profile to see decade milestones" + button → LifeProfileScreen |
| MilestoneDashboardScreen | Profile exists, no milestones computed yet | "Computing your milestones..." → auto-compute from profile data |
| FiCalculatorScreen | No life profile | Show calculator with editable placeholder inputs (age 30, expenses ₹50K/mo, 4% SWR) — fully functional as standalone |
| AllocationScreen | No investment holdings | "Add investments to see your allocation" + button → InvestmentPortfolioScreen |
| AllocationScreen | Holdings exist, no life profile | Show current allocation only, "Set up Life Profile for age-based targets" CTA |
| EmergencyFundScreen | No config | "Set up your Emergency Fund" → inline config form or navigate to Settings |
| EmergencyFundScreen | Config exists, no linked accounts | "Link savings accounts to track your emergency fund" + account picker |
| CashFlowCalendarScreen | No recurring rules | "Set up recurring income and expenses to see your cash flow" + button → RecurringRulesScreen |
| CashTierScreen | No tiers assigned | "Assign liquidity tiers to your accounts" + account list with tier pickers |
| SavingsAllocationScreen | No rules | "Create your first savings rule" + explanation of priority waterfall + "Create Rule" button |
| SavingsRateTrendScreen | < 3 months history | "Need 3+ months of transaction history for trend. Current month: X%" |
| PlanningDashboardScreen | Partial setup | Show available metrics; cards for unavailable metrics show "Set up →" CTAs linking to respective config screens |

### Horizontal Integration Verification Checklist

This checklist must be completed for EVERY new screen before marking a feature as done. It mirrors the CLAUDE.md mandate:

```
For each new screen:
  [ ] 1. Can a user reach this screen by tapping through the running debug app
       starting from HomeShell?
       → If NO: wiring is MISSING. Add Navigator.push from an existing screen.

  [ ] 2. Is there at least one integration test in integration_test/ that
       navigates to this screen from HomeShell via tap interactions?
       → If NO: navigation test is MISSING.

  [ ] 3. Are ALL buttons/tiles ON this screen wired to their targets?
       → If any onPressed: () {} or onTap: null exists: INCOMPLETE.

  [ ] 4. Does the screen render correctly with ZERO data (empty state)?
       → If it crashes or shows blank: BROKEN. Add EmptyState widget.

  [ ] 5. Does the screen provide a CTA that navigates to the setup screen
       when required configuration is missing?
       → If user hits a dead end: BAD UX. Add navigation CTA.

  [ ] 6. Does the back button return to the correct parent screen?
       → If back goes to unexpected place: BROKEN. Check Navigator stack.

  [ ] 7. Does the screen work at all 3 breakpoints (400dp, 750dp, 1200dp)?
       → If layout breaks: BROKEN. Use AdaptiveScaffold patterns.
```

### Phase Completion Gates (Navigation Edition)

No phase is complete until its navigation integration tests pass:

| Phase | Navigation Test File | Min Tests | Gate |
|-------|---------------------|-----------|------|
| Phase 6 | `integration_test/phase6_navigation_test.dart` | 8 | All 5 Phase 6 screens reachable from HomeShell on both device sizes |
| Phase 7 | `integration_test/phase7_navigation_test.dart` | 10 | All 7 Phase 7 screens reachable from HomeShell on both device sizes |
| Phase 8 | `integration_test/phase8_navigation_test.dart` | 6 | Planning Dashboard → all drill-downs work |
| Cross-Phase | `integration_test/cross_feature_navigation_test.dart` | 8 | Round-trip navigation between features works, back stack is coherent |

**Total navigation integration tests: 32** (on top of the existing ~110 E2E tests from Phases 1-5).

---

## Phase 6: Lifetime Financial Planning (BlackRock Track)

> **Estimated effort**: 3-4 weeks solo developer
> **Prerequisite**: Phase 4 complete (projection engine, investments, recurring rules)
> **Prerequisite**: GAP C7 resolved (projection engine consuming real data)

### 6.1 — Life Profile (Schema + DAO)

**New table: `life_profiles`**

```
life_profiles
├── id (TEXT, UUID)
├── user_id (TEXT, FK → users)
├── family_id (TEXT, FK → families)
├── date_of_birth (INTEGER, epoch ms)
├── planned_retirement_age (INTEGER, default 60)
├── risk_profile (TEXT: CONSERVATIVE / MODERATE / AGGRESSIVE)
├── annual_income_growth_rate (INTEGER, basis points, e.g. 800 = 8%)
├── expected_inflation_rate (INTEGER, basis points, default 600 = 6%)
├── safe_withdrawal_rate (INTEGER, basis points, default 400 = 4%)
├── created_at (INTEGER)
├── updated_at (INTEGER)
└── deleted_at (INTEGER, nullable)
```

**TDD sequence:**
- **Red**: `test/core/database/daos/life_profile_dao_test.dart` — CRUD, user isolation, family scoping, default values
- **Green**: `lib/core/database/{tables/life_profiles.dart, daos/life_profile_dao.dart}`

### 6.2 — Net Worth Milestones (Schema + Engine)

**New table: `net_worth_milestones`**

```
net_worth_milestones
├── id (TEXT, UUID)
├── life_profile_id (TEXT, FK → life_profiles)
├── target_age (INTEGER, e.g. 30, 40, 50, 60, 70)
├── target_amount (INTEGER, paise)
├── actual_amount (INTEGER, paise, computed periodically)
├── status (TEXT: ON_TRACK / BEHIND / AHEAD / REACHED)
├── created_at (INTEGER)
└── updated_at (INTEGER)
```

**Milestone computation engine** (`lib/core/financial/milestone_engine.dart`):
- Input: current net worth, current age, income growth rate, savings rate, investment returns by bucket
- Output: projected net worth at each milestone age using compound growth
- Status: compare actual vs projected trajectory
- Formula: `projected_nw(age) = current_nw * (1 + blended_return)^years + FV(annual_savings_at_growth_rate, blended_return, years)`

**TDD sequence:**
- **Red**: `test/core/financial/milestone_engine_test.dart` — age 30/40/50/60/70 projections, ON_TRACK/BEHIND/AHEAD status, edge cases (past milestone age, zero savings)
- **Red**: `test/core/database/daos/net_worth_milestone_dao_test.dart` — CRUD, ordering by age, status updates
- **Green**: Implementation

### 6.3 — Financial Independence Calculator

**Pure function** (`lib/core/financial/fi_calculator.dart`):

```
FI Number = (Annual Expenses / Safe Withdrawal Rate) * (1 + inflation)^years_to_retirement
```

Additional computations:
- `years_to_fi`: iterative calculation — given current portfolio, savings rate, and returns, when does portfolio reach FI number?
- `coast_fi_number`: portfolio value today that will compound to FI number by retirement with zero additional contributions
- `savings_rate_for_fi_by_age(target_age)`: required savings rate to reach FI by a specific age

**TDD sequence:**
- **Red**: `test/core/financial/fi_calculator_test.dart` — standard FI number, Coast FI, years-to-FI with varying rates, edge cases (already FI, zero savings, negative savings rate)
- **Green**: Implementation

### 6.4 — Asset Allocation Target Engine

**New table: `allocation_targets`**

```
allocation_targets
├── id (TEXT, UUID)
├── life_profile_id (TEXT, FK → life_profiles)
├── age_band_start (INTEGER)
├── age_band_end (INTEGER)
├── equity_pct (INTEGER, basis points, e.g. 7000 = 70%)
├── debt_pct (INTEGER, basis points)
├── gold_pct (INTEGER, basis points)
├── cash_pct (INTEGER, basis points)
└── created_at (INTEGER)
```

**Allocation engine** (`lib/core/financial/allocation_engine.dart`):
- Default India-centric glide path: `equity_pct = max(20, 100 - age)` (classic rule of thumb)
- Compare current portfolio allocation (from `investment_holdings` buckets mapped to equity/debt/gold/cash) against target
- Rebalancing suggestions as data output (not automated execution — user decides)

**Defaults by risk profile:**

| Age Band | Conservative | Moderate | Aggressive |
|----------|-------------|----------|------------|
| 20-30 | 60E/30D/5G/5C | 75E/15D/5G/5C | 85E/10D/0G/5C |
| 30-40 | 50E/35D/10G/5C | 65E/20D/10G/5C | 75E/15D/5G/5C |
| 40-50 | 40E/40D/10G/10C | 55E/25D/10G/10C | 65E/20D/10G/5C |
| 50-60 | 30E/45D/10G/15C | 45E/30D/10G/15C | 55E/25D/10G/10C |
| 60-70 | 20E/50D/10G/20C | 35E/35D/10G/20C | 45E/30D/10G/15C |
| 70+ | 15E/50D/10G/25C | 25E/40D/10G/25C | 35E/35D/10G/20C |

**TDD sequence:**
- **Red**: `test/core/financial/allocation_engine_test.dart` — default glide path, custom overrides, current vs target comparison, rebalancing delta, all risk profiles
- **Green**: Implementation

### 6.5 — Income Growth Model

**Enhancement to existing projection engine** — extend `ProjectionInput` with:
- Annual salary hike rate (from life profile)
- Hike application month (e.g., April for Indian fiscal year)
- Career stage multipliers: early career (1.2x hike rate), mid career (1.0x), late career (0.6x)
- Side income modeling (separate recurring rules tagged as `income_type: SIDE`)

This directly addresses GAP C7 by enriching the projection engine with real income trajectory data.

**TDD sequence:**
- **Red**: `test/core/financial/income_growth_model_test.dart` — compound hikes over 20 years, career stage transitions, side income addition, exact integer output
- **Green**: `lib/core/financial/income_growth_model.dart`

### 6.6 — Major Purchase Planner

**Enhancement to existing goals** — add `goal_type` field:
- `MAJOR_PURCHASE` (home, car) — with down payment %, loan EMI impact on projections
- `EDUCATION` (children) — with year-specific cost escalation
- `LIFESTYLE` (vacation, renovation) — flexible timeline
- `RETIREMENT` — special: tied to FI number

Each major purchase goal feeds back into the projection engine as a one-time expense at the target month, with optional loan creation (EMI added to recurring expenses post-purchase).

**TDD sequence:**
- **Red**: `test/core/financial/purchase_planner_test.dart` — home purchase with 20% down + EMI, education cost escalation at 10%/year, retirement goal linked to FI number, goal interaction (buying home delays retirement by X years)
- **Green**: `lib/core/financial/purchase_planner.dart`

### 6.7 — Lifetime Planning UI

**New screens:**
- `lib/features/planning/screens/life_profile_screen.dart` — DOB, retirement age, risk profile form
- `lib/features/planning/screens/milestone_dashboard_screen.dart` — decade milestones with progress bars, on-track/behind badges
- `lib/features/planning/screens/fi_calculator_screen.dart` — FI number display, years-to-FI, Coast FI, sensitivity sliders (adjust withdrawal rate, returns, inflation)
- `lib/features/planning/screens/allocation_screen.dart` — current vs target pie charts, rebalancing delta, glide path visualization
- `lib/features/planning/screens/lifetime_timeline_screen.dart` — horizontal scrollable decade timeline

**Horizontal integration wiring (mandatory, part of 6.7):**
1. **DashboardScreen**: Add "Life Plan" quick action button → `Navigator.push(LifetimeTimelineScreen)`
2. **DashboardScreen**: Add "Financial Health" summary card with FI Progress and Milestone Status sub-cards (tappable → respective screens)
3. **SettingsScreen**: Add "Financial Planning" section with "Life Profile" and "Allocation Targets" tiles
4. **GoalListScreen**: Add "Milestones" section header when life profile exists, with milestone cards → `Navigator.push(MilestoneDashboardScreen)`
5. **InvestmentPortfolioScreen**: Add "Allocation vs Target" banner → `Navigator.push(AllocationScreen)`
6. **All new screens**: Implement empty-state widgets with CTAs (see Horizontal Integration Strategy § Empty-State Navigation)
7. **All new screens**: Wire back-navigation links to existing screens (FI → Investments, Milestones → LifeProfile edit, etc.)

**TDD sequence:**
- Widget tests for each screen at 3 breakpoints (400dp, 750dp, 1200dp)
- `integration_test/phase6_navigation_test.dart`: 8 tests verifying every screen is reachable from HomeShell (see § Phase 6 Integration Tests)
- Empty-state rendering tests for each screen with no data seeded

### Phase 6 Exit Criteria
- Life profile CRUD functional
- Net worth milestones compute and display correctly
- FI number matches manual Excel calculation
- Allocation targets show current vs recommended with delta
- Income growth model feeds enriched projection engine
- 90%+ coverage on `core/financial/{milestone_engine,fi_calculator,allocation_engine,income_growth_model,purchase_planner}.dart`
- **All 5 new screens reachable by tapping through the running app from HomeShell** (verified by 8 navigation integration tests on both iPhone and iPad Pro)
- **No dead-end screens** — every screen with missing prerequisites shows an EmptyState with a navigable CTA
- **Back stack coherent** — pressing back from any new screen returns to the correct parent

---

## Phase 7: Cash Management & Safety Nets (Schwab Track)

> **Estimated effort**: 3-4 weeks solo developer
> **Prerequisite**: Phase 4 complete (recurring rules, budget system)
> **Can run in parallel with Phase 6** (independent data models)

### 7.1 — Emergency Fund Tracker (Schema + Engine)

**New table: `emergency_fund_config`**

```
emergency_fund_config
├── id (TEXT, UUID)
├── family_id (TEXT, FK → families)
├── target_months (INTEGER, default 6)
├── monthly_essential_expenses (INTEGER, paise, auto-computed from budgets)
├── manual_override_amount (INTEGER, paise, nullable — user can override)
├── linked_account_ids (TEXT, JSON array of account UUIDs)
├── income_stability (TEXT: STABLE / MODERATE / VOLATILE)
├── created_at (INTEGER)
└── updated_at (INTEGER)
```

**Emergency fund engine** (`lib/core/financial/emergency_fund_engine.dart`):
- Target = `monthly_essential_expenses * target_months`
  - STABLE income: 3-month default
  - MODERATE income: 6-month default
  - VOLATILE income: 9-12 month default
- Current coverage = sum of linked account balances / monthly essential expenses
- Months covered = floor(linked balances / monthly essential expenses)
- Auto-compute monthly essentials from budget ESSENTIAL group actuals (3-month rolling average)

**TDD sequence:**
- **Red**: `test/core/financial/emergency_fund_engine_test.dart` — target computation by stability, months-covered calculation, auto-compute from budgets, manual override, zero-expense edge case
- **Red**: `test/core/database/daos/emergency_fund_dao_test.dart` — CRUD, family isolation
- **Green**: Implementation

### 7.2 — Cash Tier Classification

**New table: `cash_tiers`**

```
cash_tiers
├── id (TEXT, UUID)
├── family_id (TEXT, FK → families)
├── account_id (TEXT, FK → accounts)
├── tier (TEXT: IMMEDIATE / SHORT_TERM / MEDIUM_TERM)
├── access_days (INTEGER — 0, 30, 90)
├── interest_rate (INTEGER, basis points, user-entered)
├── notes (TEXT, nullable)
└── created_at (INTEGER)
```

**Tier definitions:**
- **IMMEDIATE** (0 days): Savings accounts, wallets — instant access, lower returns
- **SHORT_TERM** (30 days): Liquid mutual funds, sweep FDs — 1-3 day redemption
- **MEDIUM_TERM** (90 days): Fixed deposits, short-term debt funds — penalty for early withdrawal

**Cash tier engine** (`lib/core/financial/cash_tier_engine.dart`):
- Aggregate balances by tier
- Compute weighted-average interest rate across tiers
- Suggest optimal tier distribution based on emergency fund target (keep 1 month IMMEDIATE, 2 months SHORT_TERM, rest MEDIUM_TERM)

**TDD sequence:**
- **Red**: `test/core/financial/cash_tier_engine_test.dart` — tier aggregation, weighted rate, optimal distribution, missing tier handling
- **Green**: Implementation

### 7.3 — Sinking Funds

**Enhancement to existing goals** — add `goal_category` field:
- `SINKING_FUND` — short-term, deterministic, no investment risk
  - Sub-types: CAR_REPAIR, MEDICAL, TRAVEL, INSURANCE_ANNUAL, TAX, HOME_MAINTENANCE, CUSTOM
- `INVESTMENT_GOAL` — existing behavior (SIP-based, inflation-adjusted)
- `PURCHASE_GOAL` — from Phase 6.6
- `RETIREMENT` — from Phase 6.6

Sinking funds differ from investment goals:
- No inflation adjustment (short-term, typically < 2 years)
- No SIP calculator — simple monthly savings target = (target - current) / months remaining
- Funded from income allocation rules (Phase 7.5)
- Visual: separate section on Goals screen, grouped by sub-type

**TDD sequence:**
- **Red**: `test/core/financial/sinking_fund_test.dart` — monthly savings target, progress tracking, completion detection, overdue handling
- **Green**: `lib/core/financial/sinking_fund.dart`

### 7.4 — Cash Flow Calendar

**New engine** (`lib/core/financial/cash_flow_calendar.dart`):

Builds a day-by-day map for a given month:
1. Fetch all recurring rules → map to specific dates in the month
2. Fetch all known upcoming expenses (EMI dates from loan_details, insurance premiums)
3. Overlay with income dates (salary credit date, typically 1st or last working day)
4. Compute running balance: starting balance + cumulative income - cumulative expenses per day
5. Flag dates where running balance dips below a configurable threshold (default: 0)

**Output**: `List<CashFlowDay>` where each day has:
- `date`, `incomeItems`, `expenseItems`, `runningBalance`, `isBelowThreshold`

**TDD sequence:**
- **Red**: `test/core/financial/cash_flow_calendar_test.dart` — monthly generation from recurring rules, EMI dates, running balance, threshold alerts, weekends (no income), month-end expenses before month-end income
- **Green**: Implementation

### 7.5 — Savings Allocation Rules

**New table: `savings_allocation_rules`**

```
savings_allocation_rules
├── id (TEXT, UUID)
├── family_id (TEXT, FK → families)
├── name (TEXT, e.g. "Emergency Fund First")
├── priority (INTEGER, lower = higher priority)
├── target_type (TEXT: EMERGENCY_FUND / SINKING_FUND / INVESTMENT_GOAL / OPPORTUNITY_FUND)
├── target_id (TEXT, FK to respective entity, nullable for EMERGENCY_FUND)
├── allocation_type (TEXT: FIXED_AMOUNT / PERCENTAGE)
├── amount (INTEGER, paise — for FIXED_AMOUNT)
├── percentage (INTEGER, basis points — for PERCENTAGE of surplus)
├── is_active (INTEGER, boolean)
├── created_at (INTEGER)
└── updated_at (INTEGER)
```

**Allocation engine** (`lib/core/financial/savings_allocation_engine.dart`):
1. Compute monthly surplus = income - expenses (from actuals or recurring rules)
2. Process rules in priority order:
   - If rule target is already met (emergency fund full, sinking fund target reached), skip
   - Allocate FIXED_AMOUNT or PERCENTAGE of remaining surplus
   - Track total allocated vs available surplus
3. Output: `AllocationPlan` — list of (target, amount, status) + unallocated remainder

This is a **planning tool** — it shows where money *should* go. It does NOT auto-create transactions (that would violate the deterministic principle — the user makes the judgment call).

**TDD sequence:**
- **Red**: `test/core/financial/savings_allocation_engine_test.dart` — priority ordering, skip-when-full, fixed vs percentage, surplus exhaustion, empty rules
- **Green**: Implementation

### 7.6 — Savings Rate Trend

**Enhancement to dashboard aggregation** (`lib/core/financial/dashboard_aggregation.dart`):
- Compute monthly savings rate: `(income - expenses) / income * 100`
- Store as time series (leverage existing `balance_snapshots` pattern or new `monthly_metrics` table)
- 12-month trend line on dashboard
- Health bands: green ≥ 20%, amber 10-20%, red < 10%

**New table: `monthly_metrics`**

```
monthly_metrics
├── id (TEXT, UUID)
├── family_id (TEXT, FK → families)
├── year (INTEGER)
├── month (INTEGER)
├── total_income (INTEGER, paise)
├── total_expenses (INTEGER, paise)
├── savings_rate (INTEGER, basis points)
├── emergency_fund_months (INTEGER, tenths — e.g. 45 = 4.5 months)
├── net_worth (INTEGER, paise)
├── created_at (INTEGER)
└── updated_at (INTEGER)
```

**TDD sequence:**
- **Red**: `test/core/financial/savings_rate_test.dart` — monthly rate, 12-month trend, health band classification, zero-income edge, negative savings
- **Green**: Implementation

### 7.7 — Opportunity Fund

**Reuse existing account model** — mark an account with a new purpose tag:
- Add `account_purpose` column to accounts: `GENERAL` (default), `EMERGENCY`, `OPPORTUNITY`, `SINKING`
- Opportunity fund target stored in a goal with `goal_category = OPPORTUNITY`
- Tracked separately on the cash management dashboard

### 7.8 — Cash Management UI

**New screens:**
- `lib/features/cash_management/screens/emergency_fund_screen.dart` — target vs current, months covered, progress ring, linked accounts
- `lib/features/cash_management/screens/cash_tier_screen.dart` — tier breakdown with balances, weighted rate
- `lib/features/cash_management/screens/cash_flow_calendar_screen.dart` — monthly calendar with income/expense overlays, running balance line chart, threshold warnings
- `lib/features/cash_management/screens/savings_allocation_screen.dart` — priority-ordered rule list, surplus waterfall visualization
- `lib/features/cash_management/screens/sinking_fund_detail_screen.dart` — individual sinking fund detail with progress bar and contribution history
- `lib/features/cash_management/screens/savings_rate_trend_screen.dart` — 12-month savings rate line chart with health bands
- `lib/features/cash_management/screens/opportunity_fund_screen.dart` — designated account tracker with target progress

**Horizontal integration wiring (mandatory, part of 7.8):**
1. **DashboardScreen**: Add "Cash Flow" quick action button → `Navigator.push(CashFlowCalendarScreen)`
2. **DashboardScreen**: Add Emergency Coverage sub-card to "Financial Health" card → `Navigator.push(EmergencyFundScreen)`
3. **DashboardScreen**: Add Savings Rate sub-card to "Financial Health" card → `Navigator.push(SavingsRateTrendScreen)`
4. **SettingsScreen**: Add "Emergency Fund Setup", "Cash Tier Setup", "Savings Rules", and "Opportunity Fund" tiles to "Financial Planning" section
5. **BudgetScreen**: Add "Monthly essentials" summary row at top with onTap → `Navigator.push(EmergencyFundScreen)`
6. **GoalListScreen**: Split goals into sections by `goal_category` — add "Sinking Funds" section with cards → `Navigator.push(SinkingFundDetailScreen)`
7. **AccountDetailScreen**: Add "Cash Tier" info chip (if tier assigned) → `Navigator.push(CashTierScreen)`
8. **AccountDetailScreen**: Add "Emergency Fund" badge (if account is linked to EF) → `Navigator.push(EmergencyFundScreen)`
9. **All new screens**: Implement empty-state widgets with CTAs (see Horizontal Integration Strategy § Empty-State Navigation)
10. **Cross-links between new screens**: EF → SavingsRateTrend, CashFlow → SavingsAllocation, SinkingFund → TransactionForm (see § Cross-Feature Navigation)

**TDD sequence:**
- Widget tests for each screen at 3 breakpoints (400dp, 750dp, 1200dp)
- `integration_test/phase7_navigation_test.dart`: 10 tests verifying every screen is reachable from HomeShell (see § Phase 7 Integration Tests)
- Empty-state rendering tests for each screen with no data seeded

### Phase 7 Exit Criteria
- Emergency fund target computes from budget essentials
- Cash tier aggregation correct across linked accounts
- Sinking funds track separately from investment goals
- Cash flow calendar renders day-by-day for any month
- Savings allocation rules process in priority order
- Savings rate trend computes 12-month history
- 90%+ coverage on `core/financial/{emergency_fund_engine,cash_tier_engine,sinking_fund,cash_flow_calendar,savings_allocation_engine}.dart`
- **All 7 new screens reachable by tapping through the running app from HomeShell** (verified by 10 navigation integration tests on both iPhone and iPad Pro)
- **Budget and Goals screens updated** — existing screens visually integrate new concepts (essentials row, sinking fund section)
- **Account screens updated** — cash tier and EF badges visible and tappable
- **No dead-end screens** — every screen with missing prerequisites shows an EmptyState with a navigable CTA

---

## Phase 8: Unified Planning Dashboard

> **Estimated effort**: 2 weeks
> **Prerequisite**: Phases 6 and 7 complete

### 8.1 — The "5 Numbers" Dashboard (BlackRock Methodology)

A single-screen view showing the five most important financial health indicators:

1. **Net Worth** — current, with month-over-month delta (already exists in dashboard, surface here)
2. **Savings Rate** — current month %, with 12-month trend sparkline (from Phase 7.6)
3. **Emergency Coverage** — months of expenses covered (from Phase 7.1)
4. **FI Progress** — percentage of FI number achieved (from Phase 6.3)
5. **Milestone Status** — next upcoming decade milestone, on-track/behind (from Phase 6.2)

Each number is a tappable card that drills into its respective detail screen.

### 8.2 — Lifetime Timeline Visualization

A horizontal scrollable timeline showing:
- Current age marker
- Decade milestones (30, 40, 50, 60, 70) with target net worth
- Major purchase goals plotted at their target dates
- FI date marker
- Retirement age marker
- Color-coded: green (on track), amber (at risk), red (behind)

Built with `fl_chart` custom painter — deterministic positioning based on dates.

### 8.3 — Cash Flow Health Summary

Monthly summary card showing:
- Total income vs total expenses (bar chart)
- Savings waterfall: income → expenses → emergency fund → sinking funds → investments → unallocated
- Cash flow calendar mini-view (next 7 days)
- Threshold alerts for upcoming low-balance dates

### 8.4 — Planning Insights Integration

Extend existing `PlanningInsights` (Phase 4.9) with:
- "Emergency fund below target" alert (severity: months short)
- "Asset allocation off-target" alert (severity: % deviation)
- "FI date slipping" alert (if projected FI date moves later than last month)
- "Sinking fund underfunded" alert (if monthly contribution insufficient to meet deadline)

All alerts are deterministic calculations, not predictions.

### 8.5 — Horizontal Integration Wiring (Phase 8)

1. **DashboardScreen**: "Financial Health" card header "View All →" → `Navigator.push(PlanningDashboardScreen)`
2. **PlanningDashboardScreen**: Each of the 5 metric cards → respective detail screen (see § Cross-Feature Navigation)
3. **PlanningDashboardScreen**: Cash Flow Health section → `Navigator.push(CashFlowHealthScreen)` → "View Calendar" → `CashFlowCalendarScreen`
4. **PlanningInsights (Phase 4.9 extension)**: Each alert card → relevant screen (EF alert → EmergencyFundScreen, allocation alert → AllocationScreen, FI alert → FiCalculatorScreen, sinking fund alert → SinkingFundDetailScreen)
5. **Cross-feature round-trip verification**: `integration_test/cross_feature_navigation_test.dart` — 8 tests for round-trip navigation between Phase 6, 7, and 8 screens

### Phase 8 Exit Criteria
- 5-number dashboard renders with real data
- Timeline visualization plots milestones, goals, and FI date
- Cash flow health summary shows savings waterfall
- Planning insights trigger for all new alert types
- Adaptive layout: phone stacks vertically, tablet/desktop uses grid
- **Planning Dashboard reachable from HomeShell in 2 taps** (Dashboard → "Financial Health" → "View All")
- **Every drill-down from Planning Dashboard reaches the correct detail screen** (verified by 6 navigation tests)
- **Cross-feature round-trips work** — navigating from Phase 6 screens to Phase 7 screens and back maintains coherent back stack (verified by 8 cross-feature navigation tests)
- **Total new navigation integration tests across Phases 6-8: 32** (on both iPhone and iPad Pro)
- **Complete app navigation test**: Starting from HomeShell, a tester can reach every single screen in the app (Phases 1-8) without using the back button to navigate forward — every screen has a forward-navigation entry point

---

## Data Model Extensions (Summary)

### New Tables

| Table | Phase | Purpose |
|-------|-------|---------|
| `life_profiles` | 6.1 | DOB, retirement age, risk profile, growth rates |
| `net_worth_milestones` | 6.2 | Decade targets with on-track status |
| `allocation_targets` | 6.4 | Age-band asset allocation percentages |
| `emergency_fund_config` | 7.1 | Emergency fund target and linked accounts |
| `cash_tiers` | 7.2 | Account liquidity classification |
| `savings_allocation_rules` | 7.5 | Priority-ordered savings distribution |
| `monthly_metrics` | 7.6 | Historical monthly financial health metrics |

### Modified Tables

| Table | Change | Phase |
|-------|--------|-------|
| `goals` | Add `goal_category` (SINKING_FUND / INVESTMENT_GOAL / PURCHASE_GOAL / RETIREMENT / OPPORTUNITY) | 7.3 |
| `accounts` | Add `account_purpose` (GENERAL / EMERGENCY / OPPORTUNITY / SINKING) | 7.7 |

### Schema Migration Strategy
- Each phase gets one drift schema version bump
- Phase 6: version N → N+1 (adds life_profiles, net_worth_milestones, allocation_targets)
- Phase 7: version N+1 → N+2 (adds emergency_fund_config, cash_tiers, savings_allocation_rules, monthly_metrics, modifies goals + accounts)
- All migrations additive — no existing column removals

---

## Financial Math Extensions (Summary)

All new functions are **pure, deterministic, integer-precision** — consistent with existing `core/financial/` convention.

| Function | File | Formula |
|----------|------|---------|
| `computeFiNumber(annualExpenses, withdrawalRate, inflation, years)` | `fi_calculator.dart` | `expenses / rate * (1 + inflation)^years` |
| `yearsToFi(currentPortfolio, annualSavings, returnRate, fiNumber)` | `fi_calculator.dart` | Iterative: compound until portfolio ≥ FI |
| `coastFiNumber(fiNumber, returnRate, yearsToRetirement)` | `fi_calculator.dart` | `fiNumber / (1 + rate)^years` |
| `projectNetWorthAtAge(currentNW, savings, returnRate, years)` | `milestone_engine.dart` | `FV(savings) + currentNW * (1+rate)^years` |
| `targetAllocation(age, riskProfile)` | `allocation_engine.dart` | Lookup from glide path table |
| `rebalancingDelta(currentHoldings, targetAllocation)` | `allocation_engine.dart` | Per-bucket: actual% - target% |
| `emergencyFundTarget(monthlyExpenses, months, stability)` | `emergency_fund_engine.dart` | `expenses * months_for_stability` |
| `monthsCovered(linkedBalances, monthlyExpenses)` | `emergency_fund_engine.dart` | `floor(balances / expenses)` |
| `cashFlowDay(date, incomes, expenses, runningBalance)` | `cash_flow_calendar.dart` | Cumulative running total |
| `allocateSurplus(surplus, rules)` | `savings_allocation_engine.dart` | Priority waterfall |
| `savingsRate(income, expenses)` | `savings_rate.dart` | `(income - expenses) / income * 10000` (basis points) |

---

## INTENT.md Compliance Validation

Every extension proposal validated against the Decision Framework:

| Question | Phase 6 (BlackRock) | Phase 7 (Schwab) | Phase 8 (Dashboard) |
|----------|-------------------|------------------|-------------------|
| Does data leave device unencrypted? | **No.** All new tables in drift/SQLCipher. | **No.** Same. | **No.** Display only. |
| Can cloud provider read/infer data? | **No.** Synced via existing encrypted changeset mechanism. | **No.** Same. | **No.** No new sync data. |
| Does it require a server? | **No.** All computations local. | **No.** All computations local. | **No.** Display layer. |
| Does it force visibility? | **No.** Life profiles are per-user. Milestones respect family visibility. | **No.** Emergency fund config is family-scoped but viewing respects role. | **No.** Dashboard respects existing scope toggle. |
| Does it add recurring cost? | **No.** Zero dependencies. | **No.** Zero dependencies. | **No.** Zero dependencies. |
| Does it introduce ML/AI? | **No.** All formulas are deterministic. Glide paths are rule-based tables. | **No.** All calculations use exact formulas. | **No.** Insights are threshold-based rules. |
| Does it connect to bank API? | **No.** All data from manual entry or existing statement import. | **No.** Cash tier classification is manual. | **No.** Display only. |

**Result: All rows pass. No blocks.**

---

## Dependency on Gap Remediation

These extensions assume certain CRITICAL gaps from `docs/GAP_ANALYSIS.md` are resolved first:

| Gap | Why Required | Which Phase Needs It |
|-----|-------------|---------------------|
| **C7** — Projection engine oversimplified | Phase 6.5 income growth model feeds into projection engine | Phase 6 |
| **C10** — Balance snapshots never created | Savings rate trend (7.6) needs historical data | Phase 7 |
| **M5** — Goal-investment linking unused | Phase 6.6 major purchase planner links goals to investment impact | Phase 6 |
| **C1** — SQLCipher not activated | All new tables must be encrypted at rest | Phase 6 + 7 |
| **C5** — Lock screen missing | Financial planning data is highly sensitive | Phase 6 + 7 |

**Recommendation**: Resolve C1 and C5 before starting Phase 6 or 7. Resolve C7 and C10 as part of Phase 6/7 development or as a pre-phase sprint.

---

## Concepts for Further Study

These topics will deepen your understanding of the financial and technical concepts underlying this extension plan:

### Financial Planning Concepts
- **Safe Withdrawal Rate (SWR)** and the Trinity Study — foundational research behind the 4% rule for retirement planning
- **Glide Path asset allocation** — how target-date funds (Vanguard, BlackRock LifePath) shift equity/debt ratios over time
- **Coast FIRE vs Lean FIRE vs Fat FIRE** — different financial independence strategies and their mathematical models
- **Sequence of Returns Risk** — why the order of investment returns matters as much as the average, especially near retirement
- **Bucket Strategy for retirement income** — Schwab's approach to tiering assets by time horizon (current/near-term/long-term)
- **Indian-specific: PPF/EPF/NPS tax efficiency** — how Section 80C, 80CCD, and EEE taxation affects optimal allocation

### Technical / Architecture Concepts
- **Event Sourcing vs CRUD** — your sync_changelog is conceptually event-sourced; understanding this pattern helps with the monthly_metrics time-series design
- **drift schema migrations** — advanced migration strategies (data transforms, index creation) for the 7 new tables
- **Riverpod family providers** — using `.family` modifier for user-scoped life profiles within a family-scoped app
- **fl_chart custom painters** — for the lifetime timeline visualization (Phase 8.2), understanding CustomPainter and canvas drawing
- **Integer arithmetic for financial calculations** — why Money pattern (minor units) avoids IEEE 754 floating-point issues; read about Martin Fowler's Money pattern
- **Compound interest with integer math** — techniques for avoiding precision loss when computing `(1 + rate/10000)^n` with basis-point integers

### Navigation & UX Architecture
- **Navigation patterns in Flutter** — imperative (Navigator.push/pop) vs declarative (GoRouter, go_router) — your app uses imperative; understand trade-offs as screen count grows from ~15 to ~30+
- **Deep linking and navigation stacks** — how to ensure coherent back-stack behavior when screens are reachable from multiple entry points (e.g., EmergencyFundScreen reachable from Dashboard, Budget, Account Detail, and Settings)
- **Empty-state design patterns** — Luke Wroblewski's "Empty States" principles; how to turn dead ends into onboarding moments with CTAs
- **Progressive disclosure in financial apps** — showing complexity only when the user is ready; relevant for the Planning Dashboard's graceful degradation (showing only available metrics)
- **Feature flags for incremental rollout** — using Riverpod providers or compile-time flags to enable Phase 6/7/8 screens incrementally without breaking the existing app

### Testing Patterns
- **Property-based testing in Dart** — using `glados` or `quickcheck` packages for fuzz-testing financial math (e.g., "for any valid inputs, FI number is always positive")
- **Golden file testing** — for chart widget snapshots across breakpoints
- **Deterministic time in tests** — using `clock` package to freeze time for milestone age calculations and cash flow calendar generation
- **Navigation integration testing in Flutter** — using `tester.tap(find.byKey(...))` chains to verify multi-hop navigation paths from HomeShell to deep screens; understanding `pumpAndSettle` for route transitions
- **Widget test breakpoint patterns** — using `MediaQuery` overrides to test adaptive layouts at 400dp/750dp/1200dp in the same test file
