# Vael — Data Migration from family-finances

How to move existing financial data from the current PostgreSQL-based app into Vael's local SQLite.

## Strategy

Use the existing **Storely Google Drive backup** (compressed SQL dump) as the migration source. The Flutter app reads the dump during first setup and populates local SQLite.

### Why Storely Backup (Not a Custom Export Endpoint)

- Storely already backs up the full database to Google Drive (`snapshots/LATEST.sql.gz`)
- The backup is a `pg_dump` output — complete, consistent, and battle-tested
- No changes needed to the current app
- The Flutter app already has Google Drive access (for sync) — it can read the backup directly

## Migration Flow

1. User runs Storely backup on the current app: `make storely-backup` (or it runs on schedule)
2. User opens Vael for the first time, signs in with Google
3. Vael detects existing Storely backup folder on Drive
4. User confirms: "Import from existing Family Finances app?"
5. Vael downloads `LATEST.sql.gz`, decompresses
6. Dart parser reads the SQL dump and extracts INSERT statements
7. Maps PostgreSQL types to SQLite types:
   - `UUID` → `TEXT`
   - `NUMERIC(18,2)` → `INTEGER` (convert to minor units: multiply by 100)
   - `TIMESTAMPTZ` → `INTEGER` (epoch milliseconds)
   - `JSONB` → `TEXT` (raw JSON string)
   - `BOOLEAN` → `INTEGER` (0/1)
8. Inserts data into drift tables in dependency order:
   - families → users → categories → accounts → transactions → goals → loan_details → investment_holdings → budgets → recurring rules → balance_snapshots
9. Runs balance reconciliation to verify imported data integrity
10. User sets family passphrase → FEK generated → DB encrypted via SQLCipher
11. Migration complete. User can delete the old app's Storely folder if desired.

## Tables to Migrate

| PostgreSQL Table | Vael Table | Transform Notes |
|-----------------|-----------|-----------------|
| families | families | Direct map |
| users | users | Drop `google_sub`, `mfa_*` columns (not needed in native app) |
| categories | categories | Direct map |
| accounts | accounts | Convert balance to minor units |
| transactions | transactions | Convert amount to minor units |
| transaction_effects | (skip) | Derived data, recomputed locally |
| goals | goals | Convert amounts to minor units |
| goal_investment_links | goal_investment_links | Direct map |
| loan_details | loan_details | Convert amounts to minor units |
| loan_prepayments | loan_prepayments | Convert amounts to minor units |
| investment_holdings | investment_holdings | Convert amounts to minor units |
| budgets | budgets | Convert amounts to minor units |
| recurring_income_sources | recurring_rules (type=income) | Merge into unified table |
| recurring_expenses | recurring_rules (type=expense) | Merge into unified table |
| balance_snapshots | balance_snapshots | Convert balance to minor units |
| audit_log | audit_log | Direct map (JSON diff as text) |

## Tables NOT Migrated

| Table | Reason |
|-------|--------|
| refresh_tokens | Auth tokens are app-specific |
| family_invites | Invite flow is different in Vael (passphrase-based) |
| projection_runs / projection_month_snapshots | Recomputed on demand |
| loan_amortization_schedule | Recomputed from loan_details |
| storely_* tables | Backup metadata, not financial data |
| ledger_periods | Can be recreated if needed |

## SQL Dump Parser (Dart)

The parser needs to handle pg_dump's `COPY` format:

```sql
COPY public.accounts (id, family_id, name, type, ...) FROM stdin;
uuid1	uuid2	Savings Account	SAVINGS	...
uuid3	uuid4	Credit Card	CREDIT_CARD	...
\.
```

Dart parser logic:
1. Read decompressed SQL line by line
2. Detect `COPY public.<table> (...columns...) FROM stdin;` headers
3. Parse tab-separated rows until `\.` terminator
4. Map columns to drift table fields using the column list from the COPY header
5. Batch insert into SQLite (use drift's `batch` for performance)

## Verification

After migration:
1. Count rows per table — must match PostgreSQL counts
2. Sum of all account balances must match dashboard net worth from the old app
3. Spot-check 5 recent transactions — amounts, dates, categories must match
4. Run amortization calculator on imported loans — schedule must match old app
5. Run projection engine — output should be consistent (within rounding tolerance)
