# Vael — Data Model

Port of the existing 17-migration PostgreSQL schema to drift (SQLite) DAOs.

## Core Tables

| Table | Key Fields | Complexity | Notes |
|-------|-----------|------------|-------|
| `families` | name, base_currency, created_at | Low | Root entity, one per family |
| `users` | email, display_name, avatar_url, role, family_id | Low | FK to families. Roles: ADMIN, MEMBER |
| `accounts` | name, type, institution, balance, currency, visibility, shared_with_family, deleted_at | Medium | Soft delete. Types: SAVINGS, CURRENT, CREDIT_CARD, LOAN, INVESTMENT, WALLET |
| `categories` | name, group_name, type, icon | Low | Types: INCOME, EXPENSE. Groups: ESSENTIAL, NON_ESSENTIAL, INVESTMENTS, HOME_EXPENSES |
| `transactions` | amount, date, description, category_id, account_id, to_account_id, kind, reconciliation_kind, metadata | Medium | Kinds: INCOME, SALARY, EXPENSE, TRANSFER, EMI_PAYMENT, INSURANCE_PREMIUM, DIVIDEND |
| `recurring_rules` | type, name, amount, frequency, escalation_rate, payment_month, start_date, end_date, account_id, category_id | Medium | Type: income/expense. Frequency: MONTHLY, ANNUAL. Escalation applied yearly. |
| `goals` | name, target_amount, target_date, current_savings, inflation_rate, priority, status | Medium | Status: ACTIVE, ON_TRACK, AT_RISK, COMPLETED. Linked to accounts/investments. |
| `loan_details` | account_id, principal, annual_rate, tenure_months, outstanding_principal, emi_amount, start_date, disbursement_date | High | FK to accounts. Prepayments tracked separately. |
| `investment_holdings` | account_id, instrument_name, units, avg_cost_per_unit, current_value, bucket_type, metadata | High | Buckets: MUTUAL_FUNDS, STOCKS, PPF, EPF, NPS, FIXED_DEPOSIT, BONDS, POLICY |
| `budgets` | family_id, year, month, category_group, limit_amount | Medium | One row per category group per month |
| `balance_snapshots` | account_id, snapshot_date, balance | Low | Daily snapshots for net worth history charts |
| `audit_log` | entity_type, entity_id, action, diff, actor_user_id, created_at | Low | Immutable. Actions: CREATE, UPDATE, DELETE |

## New Tables (Not in Current App)

| Table | Key Fields | Purpose |
|-------|-----------|---------|
| `sync_changelog` | entity_type, entity_id, operation, payload, timestamp, synced, changeset_id | Tracks local mutations to push to Google Drive |
| `sync_state` | last_push_at, last_pull_at, last_snapshot_at, device_id | Per-device sync cursor |

## Schema Notes

### From PostgreSQL to SQLite (drift)
- UUIDs: stored as `TEXT` in SQLite (drift supports UUID via custom types)
- JSONB: stored as `TEXT` (JSON-encoded). drift's `json` column type handles serialization.
- TIMESTAMPTZ: stored as `INTEGER` (Unix epoch milliseconds). drift's `dateTime()` maps to this.
- NUMERIC(18,2): stored as `INTEGER` (cents/paise). All monetary values in minor units to avoid floating-point issues.
- Soft deletes: `deleted_at` nullable `INTEGER`. Default queries filter `WHERE deleted_at IS NULL`.

### Indexes (Critical for Performance)
- `transactions(family_id, date)` — dashboard queries
- `transactions(account_id, date)` — account detail queries
- `balance_snapshots(account_id, snapshot_date)` — net worth history
- `sync_changelog(synced, timestamp)` — pending sync batch queries
- `audit_log(family_id, created_at)` — audit trail pagination

### Balance Update Rules (from AccountBalanceService.java)
```
INCOME/SALARY/DIVIDEND       → add amount to fromAccount
EXPENSE/EMI/INSURANCE        → subtract amount from fromAccount
TRANSFER                     → subtract from fromAccount, add to toAccount
```

### Category Group Resolution (from BudgetSummaryService.java)
```
Direct enum match first (category.groupName → CategoryGroup)
Legacy fallback: Food → ESSENTIAL, Entertainment → NON_ESSENTIAL, etc.
Default: MISSING (flagged in budget summary as unbudgeted)
```
