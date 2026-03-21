import 'package:drift/drift.dart';

import 'tables/accounts.dart';
import 'tables/audit_log.dart';
import 'tables/balance_snapshots.dart';
import 'tables/categories.dart';
import 'tables/families.dart';
import 'tables/goals.dart';
import 'tables/transactions.dart';
import 'tables/users.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Families,
  Users,
  Accounts,
  Categories,
  Transactions,
  BalanceSnapshots,
  AuditLog,
  Goals,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;
}
