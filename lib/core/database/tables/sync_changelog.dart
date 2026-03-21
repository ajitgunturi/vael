import 'package:drift/drift.dart';

/// Records every local write operation for sync to Google Drive.
///
/// Each row represents a single INSERT/UPDATE/DELETE that needs to be
/// pushed to Drive as part of an encrypted changeset.
class SyncChangelog extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()(); // e.g., 'transactions', 'accounts'
  TextColumn get entityId => text()();
  TextColumn get operation => text()(); // INSERT, UPDATE, DELETE
  TextColumn get payload => text()(); // JSON serialized data
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  TextColumn get changesetId => text().nullable()();
}
