import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/sync_state.dart';

part 'sync_state_dao.g.dart';

@DriftAccessor(tables: [SyncStateTable])
class SyncStateDao extends DatabaseAccessor<AppDatabase>
    with _$SyncStateDaoMixin {
  SyncStateDao(super.db);

  Future<void> initDevice(String deviceId) {
    return into(syncStateTable).insert(
      SyncStateTableCompanion.insert(deviceId: deviceId),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<SyncStateTableData?> getDeviceState(String deviceId) {
    return (select(
      syncStateTable,
    )..where((t) => t.deviceId.equals(deviceId))).getSingleOrNull();
  }

  Future<void> recordPush(String deviceId, DateTime pushTime) async {
    final current = await getDeviceState(deviceId);
    if (current == null) return;
    await (update(
      syncStateTable,
    )..where((t) => t.deviceId.equals(deviceId))).write(
      SyncStateTableCompanion(
        lastPushAt: Value(pushTime.millisecondsSinceEpoch),
        pushSequence: Value(current.pushSequence + 1),
      ),
    );
  }

  Future<void> recordPull(String deviceId, DateTime pullTime) {
    return (update(
      syncStateTable,
    )..where((t) => t.deviceId.equals(deviceId))).write(
      SyncStateTableCompanion(
        lastPullAt: Value(pullTime.millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> recordSnapshot(String deviceId, DateTime snapTime) {
    return (update(
      syncStateTable,
    )..where((t) => t.deviceId.equals(deviceId))).write(
      SyncStateTableCompanion(
        lastSnapshotAt: Value(snapTime.millisecondsSinceEpoch),
      ),
    );
  }
}
