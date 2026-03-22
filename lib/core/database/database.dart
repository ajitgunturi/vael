import 'package:drift/drift.dart';

import 'tables/accounts.dart';
import 'tables/audit_log.dart';
import 'tables/balance_snapshots.dart';
import 'tables/budgets.dart';
import 'tables/categories.dart';
import 'tables/category_groups.dart';
import 'tables/families.dart';
import 'tables/goals.dart';
import 'tables/investment_holdings.dart';
import 'tables/loan_details.dart';
import 'tables/recurring_rules.dart';
import 'tables/sync_changelog.dart';
import 'tables/sync_state.dart';
import 'tables/transactions.dart';
import 'tables/users.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Families,
    Users,
    Accounts,
    Categories,
    CategoryGroups,
    Transactions,
    BalanceSnapshots,
    AuditLog,
    Goals,
    Budgets,
    LoanDetails,
    InvestmentHoldings,
    RecurringRules,
    SyncChangelog,
    SyncStateTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // v6 -> v7: add deletedAt to transactions and recurring_rules
      if (from < 7) {
        await m.addColumn(transactions, transactions.deletedAt);
        await m.addColumn(recurringRules, recurringRules.deletedAt);
      }
      // v7 -> v8: add category_groups table
      if (from < 8) {
        await m.createTable(categoryGroups);
      }
    },
    beforeOpen: (details) async {
      // Create indexes if they don't exist
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_transactions_family_date '
        'ON transactions (family_id, date)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_balance_snapshots_account_date '
        'ON balance_snapshots (account_id, snapshot_date)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_sync_changelog_synced_timestamp '
        'ON sync_changelog (synced, timestamp)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_audit_log_family_created '
        'ON audit_log (family_id, created_at)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_accounts_family '
        'ON accounts (family_id)',
      );
    },
  );
}
