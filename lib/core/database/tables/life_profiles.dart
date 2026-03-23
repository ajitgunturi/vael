import 'package:drift/drift.dart';

import 'families.dart';

/// Life profile for a family member — root dependency for all planning calculations.
class LifeProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get familyId => text().references(Families, #id)();
  DateTimeColumn get dateOfBirth => dateTime()();
  IntColumn get plannedRetirementAge =>
      integer().withDefault(const Constant(60))();
  TextColumn get riskProfile =>
      text().withDefault(const Constant('MODERATE'))();
  IntColumn get annualIncomeGrowthBp =>
      integer().withDefault(const Constant(800))();
  IntColumn get expectedInflationBp =>
      integer().withDefault(const Constant(600))();
  IntColumn get safeWithdrawalRateBp =>
      integer().withDefault(const Constant(300))();
  IntColumn get hikeMonth => integer().withDefault(const Constant(4))();
  TextColumn get incomeStability => text().nullable()(); // IncomeStability.name
  IntColumn get efTargetMonthsOverride =>
      integer().nullable()(); // null = use auto-computed
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
