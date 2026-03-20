import 'package:drift/drift.dart';

import 'accounts.dart';
import 'families.dart';

/// Point-in-time snapshot of an account balance (for historical charts).
class BalanceSnapshots extends Table {
  TextColumn get id => text()();
  TextColumn get accountId => text().references(Accounts, #id)();
  DateTimeColumn get snapshotDate => dateTime()();
  IntColumn get balance => integer()(); // paise (minor units)
  TextColumn get familyId => text().references(Families, #id)();

  @override
  Set<Column> get primaryKey => {id};
}
