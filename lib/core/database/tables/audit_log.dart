import 'package:drift/drift.dart';

import 'families.dart';

/// Append-only audit trail for all entity mutations.
class AuditLog extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get action => text()();
  TextColumn get diff => text().nullable()(); // JSON blob
  TextColumn get actorUserId => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get familyId => text().references(Families, #id)();

  @override
  Set<Column> get primaryKey => {id};
}
