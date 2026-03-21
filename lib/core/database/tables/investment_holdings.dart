import 'package:drift/drift.dart';

import 'accounts.dart';
import 'families.dart';
import 'goals.dart';

/// Investment bucket — purpose-driven, not individual holdings.
///
/// Each bucket tracks a category of investments (e.g. "Retirement MFs",
/// "Education PPF") with invested amount, current value, and expected returns.
class InvestmentHoldings extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()(); // user-defined label
  TextColumn get bucketType => text()(); // BucketType as string
  IntColumn get investedAmount => integer()(); // paise
  IntColumn get currentValue => integer()(); // paise
  RealColumn get expectedReturnRate =>
      real().withDefault(const Constant(0.10))(); // annual
  IntColumn get monthlyContribution =>
      integer().withDefault(const Constant(0))(); // paise (SIP)
  TextColumn get linkedAccountId =>
      text().nullable().references(Accounts, #id)();
  TextColumn get linkedGoalId => text().nullable().references(Goals, #id)();
  TextColumn get familyId => text().references(Families, #id)();
  TextColumn get userId => text()();
  TextColumn get visibility => text().withDefault(const Constant('shared'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
