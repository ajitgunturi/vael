import 'package:drift/drift.dart';

import 'accounts.dart';
import 'categories.dart';
import 'families.dart';

/// A monetary transaction — income, expense, or transfer.
class Transactions extends Table {
  TextColumn get id => text()();
  IntColumn get amount => integer()(); // paise (minor units)
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text().nullable()();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  TextColumn get accountId => text().references(Accounts, #id)();
  TextColumn get toAccountId => text().nullable().references(Accounts, #id)();
  TextColumn get kind => text()(); // TransactionKind as string
  TextColumn get reconciliationKind => text().nullable()();
  TextColumn get metadata => text().nullable()(); // JSON blob
  TextColumn get familyId => text().references(Families, #id)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
