import 'package:drift/drift.dart';

import 'families.dart';

/// Monthly budget per category group within a family.
class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get familyId => text().references(Families, #id)();
  IntColumn get year => integer()();
  IntColumn get month => integer()(); // 1–12
  TextColumn get categoryGroup => text()(); // e.g. 'ESSENTIAL', 'NON_ESSENTIAL'
  IntColumn get limitAmount => integer()(); // paise (minor units)

  @override
  Set<Column> get primaryKey => {id};
}
