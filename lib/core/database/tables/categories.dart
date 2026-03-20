import 'package:drift/drift.dart';

import 'families.dart';

/// Expense or income category within a family.
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get groupName => text()(); // CategoryGroup as string
  TextColumn get type => text()(); // 'INCOME' or 'EXPENSE'
  TextColumn get icon => text().nullable()();
  TextColumn get familyId => text().references(Families, #id)();

  @override
  Set<Column> get primaryKey => {id};
}
