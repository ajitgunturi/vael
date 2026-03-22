# Pitfalls Research

**Domain:** Financial planning & cash management features added to existing Flutter finance app
**Researched:** 2026-03-22
**Confidence:** HIGH (based on codebase analysis + domain knowledge of integer finance math)

## Critical Pitfalls

### Pitfall 1: Compound Interest Overflow in Integer Arithmetic Over Long Horizons

**What goes wrong:**
The existing `FinancialMath` class uses `double` intermediates with `.round()` for 60-month horizons. FI calculators project 20-40 years (240-480 months). At Indian income levels (e.g., 1,50,000 INR/month = 15,000,000 paise), compounding at 10% annual for 30 years produces ~26x multiplier. `15_000_000 * 26 = 390_000_000` paise (~39 lakh) is fine for a single month's income, but accumulated net worth at 40 years can reach 10-50 crore (10^9-5*10^9 paise). Dart `int` is 64-bit so no overflow, but `double` intermediate precision degrades above 2^53 (~9*10^15 paise = ~900 crore). For high-net-worth families or aggressive growth scenarios, FV calculations can silently lose precision.

**Why it happens:**
The 60-month projection engine works fine because the horizon is short. Extending to 30+ years without reconsidering precision is a natural copy-paste error.

**How to avoid:**
- Keep all FI/milestone calculations in paise (int) as the project already does, but validate that intermediate `double` values from `math.pow()` stay below 2^53 before `.round()`.
- For horizons >20 years, consider stepping year-by-year (compound annually, not monthly) to reduce accumulated floating-point error.
- Add golden-file tests comparing against Excel/Google Sheets TVM calculations at 25-year and 40-year horizons.
- Add an assertion: `assert(intermediateValue.abs() < (1 << 53))` in debug mode.

**Warning signs:**
- FI number or milestone projections differ from Excel by more than 1 paise at identical inputs.
- Tests pass with 5-year horizon but produce different results at 30 years.
- `ProjectionEngine.project()` is called with `horizonMonths: 480` without new test coverage.

**Phase to address:**
Phase 6 (FI calculator and milestone engine). Must be addressed in the very first engine implementation, not retrofitted.

---

### Pitfall 2: Circular Dependency Between Planning Engines

**What goes wrong:**
FI calculator needs net worth trajectory. Net worth trajectory needs savings rate. Savings rate needs emergency fund allocation. Emergency fund target needs income stability assessment. Income stability needs projection engine. Projection engine needs FI assumptions. This creates a circular computation graph where engines call each other, leading to infinite loops, stale cache reads, or inconsistent state where engine A uses old data from engine B that has already been updated.

**Why it happens:**
Each planning feature is designed independently and seems self-contained. The circularity only emerges when all features are wired together through shared state (Riverpod providers watching each other).

**How to avoid:**
- Define a strict computation DAG (directed acyclic graph) with clear layering:
  1. **Layer 0 (raw data):** Account balances, transaction history, user profile (DOB, retirement age, risk profile)
  2. **Layer 1 (derived metrics):** Net worth, monthly income/expense averages, savings rate
  3. **Layer 2 (single-engine calculations):** Emergency fund target, FI number, allocation targets
  4. **Layer 3 (composite projections):** Milestone timeline, cash flow calendar, planning dashboard
- Each layer may only depend on layers below it. Never upward.
- Riverpod providers must follow this layering. No `ref.watch` from Layer 1 to Layer 2.
- Document the DAG in the architecture and enforce it in code review.

**Warning signs:**
- A provider rebuild triggers a cascade of >5 other provider rebuilds.
- Adding a new planning feature requires modifying existing engines.
- `StackOverflowError` or provider "circular dependency" exceptions during testing.

**Phase to address:**
Phase 6 (must define the computation DAG before implementing any engine). This is an architecture decision, not a code decision.

---

### Pitfall 3: Schema Migration Fragility at Version 9+ with 7 New Tables

**What goes wrong:**
The app is at schema version 8 with only 2 migration steps (v6->v7, v7->v8). Adding 7 new tables across Phases 6-8 means versions 9-15+. Each migration must handle every possible upgrade path (v6->v15, v7->v15, v8->v15). A single missed `if (from < N)` guard creates a crash-on-upgrade for users who skip app updates. The `beforeOpen` hook with `CREATE INDEX IF NOT EXISTS` helps, but table creation order matters due to foreign key references.

**Why it happens:**
Developers test migration from the current version (v8->v9) but not from all previous versions. The combinatorial explosion of upgrade paths is easy to miss.

**How to avoid:**
- Group new tables into at most 2-3 schema versions (e.g., v9 for Phase 6 tables, v10 for Phase 7, v11 for Phase 8) rather than one-per-table.
- Write migration integration tests that exercise every `from` version: v6->final, v7->final, v8->final.
- Create tables in dependency order (no FK to a table not yet created in that migration step).
- Use `m.createTable()` inside `if (from < N)` guards, never bare.
- Add a `test/core/database/migration_test.dart` case for each new version with `verifyDatabase()`.

**Warning signs:**
- Schema version increments more than 3 times across the planning extension.
- Migration test file has no test for upgrading from v8.
- Foreign key constraint errors on fresh install (table creation order).

**Phase to address:**
Phase 6 (first new tables). Establish the migration pattern once, then Phases 7-8 follow it.

---

### Pitfall 4: Navigation Spaghetti with 15+ New Screens Behind 5 Fixed Tabs

**What goes wrong:**
The constraint says "no new bottom tabs (stay at 5)" and new screens are accessed via "dashboard cards, settings section, contextual navigation." With 15+ planning screens accessed through `Navigator.push()` from various entry points, the navigation graph becomes unpredictable. Users get lost. Back button behavior breaks. The same screen is reachable from 3 different paths with different back stacks. Deep links become impossible. Adaptive layout (phone vs tablet) must handle every path.

**Why it happens:**
Each planning feature is added with its own `Navigator.push()` from wherever seems convenient. No central navigation strategy exists. The current app uses simple tab switching + `Navigator.push()` for forms, which works with 14 features but won't scale to 30+.

**How to avoid:**
- Define a navigation hierarchy before building screens:
  - **Primary entry:** Planning dashboard card on the main dashboard (tab 0) -> Planning hub screen
  - **Planning hub:** Single screen that links to all planning sub-features (FI, emergency fund, allocation, cash management)
  - **Sub-feature screens:** Each planning feature is 1-2 screens max from the hub
  - Maximum depth: Tab -> Dashboard Card -> Planning Hub -> Feature Screen -> Detail/Edit
- Keep the navigation tree max 3 levels deep from any tab.
- Every new screen must have exactly ONE canonical entry point. Secondary entry points (e.g., from insights) use the same route.
- Write navigation integration tests BEFORE building screens.
- Consider adopting GoRouter now (the app currently uses bare `Navigator.push()`). GoRouter provides declarative routing, deep linking, and named routes that prevent spaghetti.

**Warning signs:**
- A screen is pushed from 3+ different widgets.
- `Navigator.pop()` returns to an unexpected screen.
- Navigation tests require more than 4 taps to reach any planning screen.
- Tablet layout shows a screen that phone layout can't reach (or vice versa).

**Phase to address:**
Phase 6 (establish navigation pattern with Planning Hub). If deferred to Phase 7, the Phase 6 screens will already have ad-hoc navigation.

---

### Pitfall 5: FI Number Calculation Ignoring Indian Tax and Inflation Realities

**What goes wrong:**
A naive FI calculator uses the "25x annual expenses" rule (4% withdrawal rate). This is calibrated for US markets with 7% real returns and 2-3% inflation. India has 6-7% inflation, 10-12% nominal equity returns but only 4-5% real returns, and no equivalent of US Social Security. Using Western FI formulas produces dangerously optimistic FI numbers. A family that thinks they need 3 crore actually needs 5-6 crore.

**Why it happens:**
FI/FIRE community content is overwhelmingly US-centric. The "4% rule" and "25x rule" are treated as universal truths. The existing code already uses Indian defaults (6% expense growth, 8% income growth, 10% investment return) which is good, but the FI calculator needs to go further.

**How to avoid:**
- Default to a 3% safe withdrawal rate (SWR) for India, not 4%. This means 33x annual expenses, not 25x.
- Make SWR user-configurable with a clear explanation of why 3% is the default.
- Inflation-adjust the FI target: if retirement is 20 years away, the FI number must be in future rupees, not today's.
- Include "Coast FI" calculation (how much you need invested TODAY such that growth alone reaches FI by retirement) as a complementary metric.
- Use the existing `inflationAdjust()` function to show FI number in both today's rupees and retirement-year rupees.
- Never show a single FI number. Always show a range (conservative/moderate/aggressive matching the three-scenario pattern already in the projection engine).

**Warning signs:**
- FI number is computed without inflation adjustment.
- Only one FI number is shown (no range/scenarios).
- SWR is hardcoded to 4% without configurability.
- Test fixtures use US-typical rates (2% inflation, 7% real return).

**Phase to address:**
Phase 6 (FI calculator). This is a domain correctness issue, not a UX issue.

---

### Pitfall 6: Emergency Fund Target That Ignores Family Context

**What goes wrong:**
Standard emergency fund advice is "3-6 months of expenses." For an Indian family with a single earner, irregular income (freelance/business), or dependents with medical needs, this is inadequate. Conversely, for a dual-income family with stable government jobs, 3 months may be excessive and the surplus should be invested. A one-size-fits-all target makes the feature useless for the exact audience (Indian families) the app serves.

**Why it happens:**
Emergency fund calculators copy the "3-6 months" rule without parameterizing it. The feature looks done but provides no actionable guidance.

**How to avoid:**
- Parameterize the target by income stability profile (from the life profile):
  - Stable dual-income: 3 months
  - Stable single-income: 6 months
  - Variable/freelance income: 9-12 months
  - Single earner with dependents: 6-9 months
- Let users override the recommendation.
- Factor in health insurance coverage (or lack thereof - common in India).
- Link to actual account balances: "You have 4.2 months covered" is actionable; "Target: 6 months" without context is not.
- Include the monthly burn rate calculation using actual expense data from the transactions table, not a user-entered estimate.

**Warning signs:**
- Emergency fund target is a single hardcoded multiplier.
- Target doesn't update when expense patterns change.
- No link between emergency fund status and actual account balances.

**Phase to address:**
Phase 7 (emergency fund tracker). Depends on life profile from Phase 6.

---

### Pitfall 7: Glide Path Allocation Engine That Can't Be Validated

**What goes wrong:**
The allocation engine recommends asset allocation percentages by age (e.g., "age 30: 70% equity, 20% debt, 10% gold"). But the app has no way to verify these against the user's actual portfolio. The recommendation floats disconnected from reality. Users see "you should have 70% in equity" but can't answer "do I?" without manual calculation.

**Why it happens:**
The allocation engine is built as a standalone calculator without integrating with the existing investment holdings table. The Phase 4 investment portfolio tracking has the data; the allocation engine just doesn't read it.

**How to avoid:**
- The allocation engine MUST read from the `investment_holdings` table to compute current allocation percentages.
- Show current vs. target allocation side-by-side, with the delta.
- Classify existing holdings by asset class (the investment types already include: mutual_fund, stock, ppf, epf, nps, fd, bond, policy -- these map to equity/debt/hybrid/gold).
- Show rebalancing suggestions in rupees: "Move 50,000 from FD to equity mutual funds to reach target."
- Do NOT auto-create transactions or investment entries. Advisory only (per INTENT.md deterministic principle).

**Warning signs:**
- Allocation screen shows only target percentages, no current percentages.
- Investment holdings table is not queried by the allocation engine.
- No mapping from investment type enum to asset class.

**Phase to address:**
Phase 6 (allocation engine). Must integrate with Phase 4 investment portfolio data from day one.

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Hardcode growth rates instead of making them user-configurable | Faster implementation | Users can't customize assumptions; complaints about "wrong" projections | Never -- life profile should store user rates from Phase 6 |
| Store computed values (FI number, months-to-FI) in the database | Faster reads | Stale data when inputs change; cache invalidation bugs | Only if recomputation takes >500ms (unlikely for pure math) |
| Skip balance snapshot creation (the C10 gap) | Avoid complex background job | Savings rate trend has no historical data; trend chart is empty for months | Never -- must resolve in Phase 7 before savings rate trend |
| Use `DateTime.now()` in financial engines | Simpler API | Untestable; FI calculations change output every day; flaky tests | Never -- inject clock via parameter (the project already does this in some places) |
| Build planning screens without Riverpod providers (direct DB queries) | Faster prototyping | Breaks reactive updates; inconsistent with rest of app; no caching | Never -- existing architecture mandates Riverpod providers |

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Recomputing FI/milestone projections on every provider rebuild | UI jank when editing profile fields; battery drain | Debounce inputs; cache projection results with `family` provider keyed on inputs; only recompute when inputs actually change | Immediately (user types DOB, each keystroke triggers 480-month projection) |
| Cash flow calendar querying all transactions for 365-day window | Slow screen load; ANR on budget tab | Pre-aggregate monthly totals in a DAO query; use the existing `idx_transactions_family_date` index; paginate by month | At ~2000 transactions (1-2 years of active use) |
| Savings waterfall chart rendering 12 months of stacked bar data with real-time recalculation | Frame drops on older phones | Compute waterfall data in the provider, not in `build()`; pass pre-computed list to chart widget | On any mid-range phone with >6 months of data |
| 30-year projection with monthly granularity producing 360-element list for a timeline chart | Memory spike; chart rendering lag | For display, downsample to yearly or quarterly snapshots; keep monthly only for tooltip drill-down | Visible with any 20+ year projection |

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| New planning tables not encrypted via SQLCipher | Financial planning data (income, net worth targets, retirement age) stored in plaintext on device | All new tables must be in the same SQLCipher-encrypted database. This is automatic if tables are added to `AppDatabase` -- but verify with a test that reads raw `.db` file bytes and confirms no plaintext. Resolve C1 gap. |
| Life profile data (DOB, salary, retirement plans) in sync changesets without FEK encryption | Sensitive personal data exposed in Google Drive backup | Ensure changeset serialization uses the same AES-GCM FEK encryption as existing tables. Add a test that inspects a sync changeset for planning data and confirms it's encrypted. |
| FI number and net worth projections visible without lock screen | Someone borrowing the phone sees lifetime financial plan | Resolve C5 (lock screen) before or alongside Phase 6. Planning screens should respect the same lock as the rest of the app. |

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Showing FI number without context ("Your FI number is 4,50,00,000") | Number feels arbitrary and overwhelming; user doesn't know if they're on track | Show FI number WITH years-to-FI, percentage complete, and comparison to current net worth. "You're 34% of the way there. At current savings rate, you'll reach FI in 18 years (age 53)." |
| Emergency fund shown as a percentage bar without action steps | User sees "67% funded" but doesn't know what to do | Show the gap in rupees AND suggest which accounts to top up: "You need 1,20,000 more. Your savings account has room." |
| Allocation engine showing target percentages without current portfolio | User must mentally calculate if they're aligned | Side-by-side: current allocation vs. target, with delta and rebalancing suggestions in rupees |
| Cash flow calendar showing every transaction individually | Screen is overwhelming with 50+ entries per month | Group by recurring vs. one-time; show daily net flow, not individual transactions; expand on tap |
| Planning dashboard with too many numbers | Cognitive overload; user closes the app | The "5 numbers" approach from PROJECT.md is correct: net worth, FI percentage, savings rate, emergency fund months, cash reserve days. No more on the summary card. |
| Showing negative/discouraging results ("You'll never reach FI") | User feels hopeless and stops using the app | Always show a path: "At current rate: never. If you increase savings by 5,000/month: 22 years." Frame as actionable, not judgmental. |

## "Looks Done But Isn't" Checklist

- [ ] **FI Calculator:** Often missing inflation adjustment on the target -- verify FI number changes when you change the inflation rate assumption
- [ ] **FI Calculator:** Often missing Coast FI -- verify you show both "save monthly" FI and "stop saving, let growth do it" FI
- [ ] **Emergency Fund:** Often missing link to actual accounts -- verify the "months covered" number is computed from real account balances, not user input
- [ ] **Allocation Engine:** Often missing current portfolio integration -- verify the screen queries `investment_holdings` table and shows current vs. target
- [ ] **Cash Flow Calendar:** Often missing recurring transaction projection -- verify future months show projected recurring income/expenses, not just blank
- [ ] **Savings Rate:** Often missing the denominator definition -- verify whether savings rate is (income - expenses) / income or (income - expenses) / (income - taxes). Document the formula.
- [ ] **Milestone Timeline:** Often missing life events -- verify that major purchase plans (home, car, education from purchase planner) appear on the timeline
- [ ] **Sinking Funds:** Often missing progress tracking -- verify each fund shows amount saved vs. target with a date-aware "on track" indicator
- [ ] **Planning Dashboard:** Often missing cross-feature consistency -- verify that the FI number on the dashboard matches the FI calculator screen exactly (same inputs, same computation)
- [ ] **Schema Migration:** Often missing upgrade-from-old-version test -- verify migration test covers v6->latest, v7->latest, v8->latest, not just v(N-1)->vN

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Integer overflow in long-horizon projections | LOW | Add precision guard assertions; fix the few affected calculations; no schema change needed |
| Circular provider dependencies | HIGH | Requires refactoring the provider graph; may need to split providers into layers; potentially affects all planning screens |
| Schema migration breaks existing users | HIGH | Emergency app update with corrected migration; may need to handle partially-migrated databases; user data is preserved (SQLite is transactional) |
| Navigation spaghetti | MEDIUM | Introduce Planning Hub as a single entry point; redirect all existing pushes; 1-2 day refactor |
| Wrong FI number (bad assumptions) | LOW | Fix formula; update defaults; no data loss since FI is computed not stored |
| Emergency fund disconnected from real data | MEDIUM | Wire up account balance queries; add the DAO method; update provider; ~1 day |
| Allocation engine without portfolio integration | MEDIUM | Add asset class mapping for investment types; query holdings table; ~1-2 days |

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Integer precision in long projections | Phase 6 (FI calculator) | Golden-file tests at 25yr and 40yr horizons matching Excel output within 1 paise |
| Circular engine dependencies | Phase 6 (architecture) | Document computation DAG; no Riverpod circular dependency errors in test suite |
| Schema migration fragility | Phase 6 (first new tables) | Migration test covers all `from` versions; fresh install test passes |
| Navigation spaghetti | Phase 6 (Planning Hub) | Every planning screen reachable in <=3 taps from dashboard; navigation integration tests at 3 breakpoints |
| Wrong FI assumptions for India | Phase 6 (FI calculator) | Default SWR is 3%; FI number shown with inflation adjustment; three-scenario range displayed |
| Emergency fund without context | Phase 7 (emergency fund tracker) | Target computed from actual expense data; months covered from actual account balances |
| Allocation without portfolio data | Phase 6 (allocation engine) | Screen queries `investment_holdings`; shows current vs. target allocation delta |
| Balance snapshots never created (C10) | Phase 7 (savings rate trend) | Background job creates daily/weekly snapshots; trend chart shows >0 data points after 1 week |
| Lock screen gap (C5) | Phase 6 (prerequisite) | Planning screens are behind lock; test verifies locked state |
| Stale computed values | All phases | No planning results stored in DB; all computed on read from source data |

## Sources

- Codebase analysis: `lib/core/financial/financial_math.dart` (integer arithmetic patterns, `.round()` precision)
- Codebase analysis: `lib/core/financial/projection_engine.dart` (60-month horizon, double intermediate values)
- Codebase analysis: `lib/core/database/database.dart` (schema version 8, migration strategy pattern)
- Codebase analysis: `lib/shared/shell/home_shell.dart` (5-tab navigation, `Navigator.push()` pattern)
- Codebase analysis: `lib/core/database/tables/balance_snapshots.dart` (C10 gap -- table exists but never populated)
- PROJECT.md: Extension architecture plan, known dependency gaps (C1, C5, C7, C10, M5)
- PROJECT.md: Constraints (integer arithmetic, additive migrations, TDD, 5-tab limit)
- Domain knowledge: Indian FI planning (inflation 6-7%, real equity returns 4-5%, no Social Security equivalent)
- Domain knowledge: Safe withdrawal rate research (Trinity study 4% SWR is US-specific; Indian consensus ~3%)

---
*Pitfalls research for: Financial planning & cash management extension (Vael Phases 6-8)*
*Researched: 2026-03-22*
