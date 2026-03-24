import 'package:drift/drift.dart';

import 'families.dart';

/// Cached monthly financial metrics per family (income, expenses, savings rate).
class MonthlyMetrics extends Table {
  TextColumn get id => text()();
  TextColumn get familyId => text().references(Families, #id)();
  TextColumn get month => text()(); // YYYY-MM format
  IntColumn get totalIncomePaise => integer()();
  IntColumn get totalExpensesPaise => integer()();
  IntColumn get savingsRateBp => integer()(); // basis points
  IntColumn get netWorthPaise => integer()();
  IntColumn get yearsToFi => integer().nullable()();
  DateTimeColumn get computedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
