import 'package:drift/drift.dart';

/// Tracks sync progress per device.
///
/// Each device has its own push sequence counter and timestamps
/// for last push, pull, and snapshot operations.
class SyncStateTable extends Table {
  @override
  String get tableName => 'sync_state';

  TextColumn get deviceId => text()();
  IntColumn get lastPushAt => integer().nullable()(); // epoch ms
  IntColumn get lastPullAt => integer().nullable()(); // epoch ms
  IntColumn get lastSnapshotAt => integer().nullable()(); // epoch ms
  IntColumn get pushSequence => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {deviceId};
}
