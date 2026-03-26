import 'package:drift/drift.dart';

import 'accounts.dart';
import 'families.dart';

/// A financial goal with target, timeline, and tracking data.
class Goals extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get targetAmount => integer()(); // paise (minor units)
  DateTimeColumn get targetDate => dateTime()();
  IntColumn get currentSavings => integer().withDefault(const Constant(0))();
  RealColumn get inflationRate =>
      real().withDefault(const Constant(0.06))(); // default 6%
  IntColumn get priority => integer().withDefault(const Constant(1))();
  TextColumn get status =>
      text().withDefault(const Constant('active'))(); // GoalStatus as string
  TextColumn get linkedAccountId =>
      text().nullable().references(Accounts, #id)();
  TextColumn get familyId => text().references(Families, #id)();
  TextColumn get goalCategory =>
      text().withDefault(const Constant('investmentGoal'))();
  IntColumn get downPaymentPctBp =>
      integer().nullable()(); // basis points, null = not a purchase
  IntColumn get educationEscalationRateBp =>
      integer().nullable()(); // basis points, null = not education
  TextColumn get sinkingFundSubType =>
      text().nullable()(); // SinkingFundSubType.name or null
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
