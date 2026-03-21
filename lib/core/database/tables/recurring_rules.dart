import 'package:drift/drift.dart';

import 'accounts.dart';
import 'categories.dart';
import 'families.dart';

/// A recurring transaction rule.
///
/// Frequency is a float in months: 0.5 = biweekly, 1 = monthly,
/// 3 = quarterly, 12 = annual.
class RecurringRules extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get kind => text()(); // TransactionKind as string
  IntColumn get amount => integer()(); // paise
  TextColumn get accountId => text().references(Accounts, #id)();
  TextColumn get toAccountId => text().nullable().references(Accounts, #id)();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  RealColumn get frequencyMonths => real()(); // 0.5, 1, 3, 6, 12
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get isPaused => boolean().withDefault(const Constant(false))();
  DateTimeColumn get pausedAt => dateTime().nullable()();
  DateTimeColumn get lastExecutedDate => dateTime().nullable()();
  RealColumn get annualEscalationRate =>
      real().withDefault(const Constant(0))(); // e.g. 0.10 for 10%
  TextColumn get familyId => text().references(Families, #id)();
  TextColumn get userId => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
