import 'package:drift/drift.dart';

import 'families.dart';

/// Savings allocation rules defining how surplus is distributed across targets.
class SavingsAllocationRules extends Table {
  TextColumn get id => text()();
  TextColumn get familyId => text().references(Families, #id)();
  IntColumn get priority => integer()(); // 1 = highest
  TextColumn get targetType =>
      text()(); // 'emergencyFund', 'sinkingFund', 'investmentGoal', 'opportunityFund'
  TextColumn get targetId =>
      text().nullable()(); // goalId for sinking/investment, null for EF/OPP
  TextColumn get allocationType => text()(); // 'fixed', 'percentage'
  IntColumn get amountPaise => integer().nullable()(); // for fixed allocation
  IntColumn get percentageBp =>
      integer().nullable()(); // for percentage allocation (basis points)
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
