import 'package:drift/drift.dart';

import 'families.dart';

/// A member of a family vault.
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get displayName => text()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get role => text()(); // UserRole as string
  TextColumn get familyId => text().references(Families, #id)();

  @override
  Set<Column> get primaryKey => {id};
}
