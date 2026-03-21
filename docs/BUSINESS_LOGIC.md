# Vael — Business Logic Port Guide

Complete inventory of Java business logic to rewrite in Dart. Source paths are relative to the `family-finances` repo root.

Total estimated Dart: ~1,900 LOC (excluding UI, tests, sync engine).

---

## Priority 1 — Core Financial Engine

### Financial Math (Pure Functions)
**Source**: `platform-commons/src/main/java/com/familyfinance/commons/financial/FinancialMath.java`
**Dart effort**: ~80 LOC

Functions to port:
- `pmt(rate, nper, pv, fv)` — Excel PMT equivalent (loan payment calculation)
- `fv(rate, nper, pmt, pv)` — future value
- `pv(rate, nper, pmt, fv)` — present value
- `inflationAdjust(amount, rate, years)` — `amount * (1 + rate)^years`
- `requiredSip(target, rate, months)` — monthly SIP to reach goal
- `power(base, exp)` — arbitrary precision exponentiation

All are stateless pure functions. Port with exact test parity against Excel formulas.

### Amortization Calculator
**Source**: `platform-commons/src/main/java/com/familyfinance/commons/financial/AmortizationCalculator.java`
**Dart effort**: ~200 LOC

Core algorithm:
```
For each month:
  interestComponent = outstanding * monthlyRate
  principalComponent = EMI - interestComponent
  (ensure principalComponent <= outstanding on last payment)

  apply prepayments (if any at this month)
  newOutstanding = outstanding - principalComponent - prepayment

  terminate when outstanding <= tolerance (0.01)
```

Enrichment (computed on generated schedule):
- Remaining tenure (months)
- Projected interest remaining (sum of future interest components)
- Next payment breakdown (principal vs interest split)
- Total prepaid principal (sum of all prepayments)
- Total interest saved from prepayments

### Account Balance Rules
**Source**: `core-service/src/main/java/com/familyfinance/account/service/AccountBalanceService.java`
**Dart effort**: ~100 LOC

Rules:
- INCOME/SALARY/DIVIDEND → add to fromAccountId
- EXPENSE/EMI_PAYMENT/INSURANCE_PREMIUM → subtract from fromAccountId
- TRANSFER → subtract from fromAccountId, add to toAccountId (two-step)
- Balance update is atomic — if toAccount update fails, fromAccount is rolled back

### Dashboard Aggregation
**Source**: `core-service/src/main/java/com/familyfinance/account/controller/DashboardController.java`
**Dart effort**: ~150 LOC

Computations:
- Net Worth = Assets (positive balances) - Liabilities (negative + loan outstanding) - Credit Card dues
- Account categorization: maps account types to 4 groups (banking, investments, loans, creditCards)
- Scope control: personal (user's accounts) vs family (shared accounts)
- Monthly summary: Income (from transactions) - Expenses (grouped by category) = Net Savings
- Goal progress: targetAmount, currentSavings, requiredMonthlySip, status, priority
- Net worth history: from balance_snapshots aggregated by snapshot_date

### Budget Summary
**Source**: `core-service/src/main/java/com/familyfinance/goal/service/BudgetSummaryService.java`
**Dart effort**: ~160 LOC

Algorithm:
1. Fetch all budgets for (family, year, month)
2. Compute actuals by CategoryGroup:
   - Query transactions in date range
   - Filter: EXPENSE types only (EXPENSE, EMI_PAYMENT, INSURANCE_PREMIUM)
   - Filter: non-self-transfers
   - Filter: shared accounts only
   - Group by category → resolve to CategoryGroup
3. For each budgeted group: remaining = limit - actual, variance = actual - limit, overspent flag
4. For non-budgeted groups with actuals: show as overspent with zero limit

---

## Priority 2 — Planning & Projections

### 60-Month Projection Engine
**Source**: `controlplane/src/main/java/com/familyfinance/controlplane/projection/ProjectionEngine.java`
**Dart effort**: ~350 LOC (most complex piece)

Monthly computation loop (60 iterations):
1. **Income calculation**:
   - Base salary + annual hike (applied in specified month)
   - Bonus + annual bonus growth (applied in specified month)
   - RSU vestings (exact month matches from vestingSchedule)
   - Policy payouts (scheduled)
   - Recurring income sources (with escalation: `amount * (1 + rate)^yearsFromNow`)

2. **Expense calculation**:
   - Recurring expenses (with escalation)
   - Loan EMIs (from amortization schedule)
   - Education costs (monthly breakdown of school/college fees)

3. **Investment & fund management**:
   - `netSavings = income - expenses`
   - If surplus: add to fund + contribute to investments + apply monthly investment return
   - If deficit: draw from fund first, then liquidate investments (track "investment drawdown")
   - Monthly investment return applied only in surplus months

4. **Scenario multipliers**: OPTIMISTIC (1.2x), REALISTIC (1.0x), CONSERVATIVE (0.8x)

5. **Output per month**: income, expenses, netSavings, fundBalance, investmentValue, cumulativeDeviation, monthsUntilDeficit

### Goal Tracking
**Source**: `core-service/src/main/java/com/familyfinance/goal/controller/GoalController.java`
**Dart effort**: ~180 LOC

- Inflation-adjusted target: `targetAmount * (1 + inflationRate)^yearsToTarget`
- Required monthly SIP: calculated from inflationAdjustedTarget and months remaining
- Status inference: ACTIVE → ON_TRACK (if savings >= expected) → AT_RISK (if behind) → COMPLETED
- Goal-investment linking: goals can be linked to investment holdings (bucket support)

### Investment Baselines
**Source**: `core-service/src/main/java/com/familyfinance/goal/service/InvestmentBucketSupport.java`
**Dart effort**: ~120 LOC

Return lookup priority:
1. Per-holding `fixedAnnualReturn` (in metadata)
2. Per-holding XIRR
3. Family-configured baselines (per bucket type)
4. Platform defaults (per bucket type)

Bucket types with defaults: MUTUAL_FUNDS, STOCKS, PPF, EPF, NPS, FIXED_DEPOSIT, BONDS, POLICY.
Type normalization handles variants (MUTUAL_FUND → MUTUAL_FUNDS, etc.)

### Planning Insights
**Source**: `core-service/src/main/java/com/familyfinance/goal/service/PlanningInsightsService.java`
**Dart effort**: ~100 LOC

Detections:
- Budget drift: expenses > income over 3-month rolling window
- Severity thresholds: mild (1.10x), moderate (1.25x), severe (1.50x)
- At-risk goal flags based on savings velocity vs required SIP

---

## Priority 3 — Import & Automation

### Statement Import
**Source**: `core-service/src/main/java/com/familyfinance/imports/service/StatementImportParser.java`
**Dart effort**: ~300 LOC

Format detection and parsing:
- **HDFC Bank**: detects by "narration" header or "chq./ref.no". Multi-line support. Handles fixed-width format.
- **SBI**: detects by "state bank", "sbi", "ref no"
- **ICICI Bank**: detects by "transaction remarks" + "icici"
- **Generic CSV**: fallback for unrecognized formats

Row normalization:
- Dedup hash: `SHA256(familyId + accountId + date + amount + merchant)`
- Direction: CREDIT vs DEBIT by amount sign
- Merchant normalization: trim, lowercase, extract keywords
- Transfer detection: keywords (upi, neft, imps, etc.)
- Investment detection: keywords (zerodha, groww, nps, etc.)

Flow: Parse → Preview → User reviews/categorizes → Commit (create transactions)

### Recurring Transactions
**Source**: `controlplane/src/main/java/com/familyfinance/controlplane/workflow/impl/RecurringTransactionWorkflowImpl.java`
**Dart effort**: ~150 LOC

Replaces Temporal workflow with local scheduled task:
1. Fetch all active recurring rules (income + expense)
2. Evaluate each against current date
3. Apply start/end date filters
4. MONTHLY: create transaction every month
5. ANNUAL: create only in matching paymentMonth
6. Idempotent key prevents duplicates

### Balance Reconciliation
**Source**: `controlplane/src/main/java/com/familyfinance/controlplane/workflow/impl/BalanceReconciliationWorkflowImpl.java`
**Dart effort**: ~100 LOC

Run on app foreground:
1. For each account: sum all transactions
2. Compare against stored balance
3. Log discrepancies
4. Create BalanceSnapshot record

---

## Critical Business Rules to Preserve

1. **Loan closure**: outstanding <= tolerance (0.01) terminates amortization schedule
2. **Projection deficit**: tracks first month where fund + investments hit zero
3. **Budget overspend**: boolean flag when actualSpent > limit
4. **Closed period enforcement**: no transactions in closed ledger periods (audit-only adjustments)
5. **Soft deletes**: accounts, recurring rules use `deleted_at` — queries must filter by default
6. **Family isolation**: all queries scoped by family_id — enforced at DAO layer in drift
