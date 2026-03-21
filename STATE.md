# Vael — State

## Current Phase: 4 — Advanced Features (COMPLETE)
## Branch: feat/phase4

## Phase 4 Delivered

### Projection Engine
- 60-month forward-stepping financial simulation
- Three scenarios (optimistic/base/pessimistic) with ±2% return spread
- Compound investment returns, annual income/expense growth, EMI deductions
- Interactive projection screen with parameter sliders and fl_chart visualization

### Investment Tracking (Bucket-Based)
- 8 India-native bucket types: MFs, Stocks, PPF, EPF, NPS, FD, Bonds, Policy
- Default return rates per type, user-overridable
- Portfolio summary: total invested, current value, gain %, overall returns
- Multi-bucket projection (compound growth per bucket)
- Goal course correction: projected shortfall + suggested SIP adjustment
- Investment holdings table + DAO (schema v6)
- Portfolio screen with summary card + bucket cards + form

### Recurring Automation
- Frequency as float months: 0.5 (biweekly), 1, 3, 6, 12
- Annual escalation (e.g. 10% salary hike)
- Pause/resume with timestamps
- Pending transaction generation from last-executed watermark
- Recurring rules table + DAO (schema v6)
- Rules screen with status indicators + form

### Statement Import
- Auto-detecting parser: HDFC, SBI, ICICI, generic CSV
- Indian date formats (DD/MM/YYYY, DD-MM-YYYY)
- Amount parsing with Indian comma grouping
- Category inference from 15+ keyword patterns (Swiggy, Zomato, Amazon, etc.)
- Malformed row handling with skip count
- Preview → review → commit flow (paste CSV → checkbox select → import)

### Balance Reconciliation
- Validates account balances vs transaction sums
- Reports discrepancies with recorded/computed/difference
- Designed to run on app foreground

### Planning Insights
- Budget drift detection: 3-month rolling window, >5% overspend + upward trend
- At-risk goal flags: critical (overdue), high (<50% progress), moderate (50-80%)

### Schema Migration
- v5 → v6: added investment_holdings, recurring_rules tables
- DAOs with full CRUD, pause/resume, watch streams

## Test Count: 688 unit/widget (all green) + 29 simulator tests + 23 journey tests + 38 retroactive E2E tests

## Next: Phase 5 — Polish + Distribution
