import 'package:drift/drift.dart';

import 'tables/accounts.dart';
import 'tables/audit_log.dart';
import 'tables/balance_snapshots.dart';
import 'tables/budgets.dart';
import 'tables/categories.dart';
import 'tables/families.dart';
import 'tables/goals.dart';
import 'tables/loan_details.dart';
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
    Transactions,
    BalanceSnapshots,
    AuditLog,
    Goals,
    Budgets,
    LoanDetails,
    SyncChangelog,
    SyncStateTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 5;
}
