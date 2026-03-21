import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/database/daos/sync_state_dao.dart';

void main() {
  late AppDatabase db;
  late SyncStateDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = SyncStateDao(db);
  });

  tearDown(() => db.close());

  group('SyncStateDao', () {
    test('initializes sync state for a device', () async {
      await dao.initDevice('device-A');

      final state = await dao.getDeviceState('device-A');
      expect(state, isNotNull);
      expect(state!.deviceId, 'device-A');
      expect(state.pushSequence, 0);
      expect(state.lastPushAt, isNull);
      expect(state.lastPullAt, isNull);
      expect(state.lastSnapshotAt, isNull);
    });

    test('updates last push timestamp and increments sequence', () async {
      await dao.initDevice('device-A');
      final pushTime = DateTime.utc(2026, 3, 20, 10, 30);

      await dao.recordPush('device-A', pushTime);

      final state = await dao.getDeviceState('device-A');
      expect(state!.lastPushAt, pushTime.millisecondsSinceEpoch);
      expect(state.pushSequence, 1);
    });

    test('updates last pull timestamp', () async {
      await dao.initDevice('device-A');
      final pullTime = DateTime.utc(2026, 3, 20, 11, 0);

      await dao.recordPull('device-A', pullTime);

      final state = await dao.getDeviceState('device-A');
      expect(state!.lastPullAt, pullTime.millisecondsSinceEpoch);
    });

    test('updates last snapshot timestamp', () async {
      await dao.initDevice('device-A');
      final snapTime = DateTime.utc(2026, 3, 20, 12, 0);

      await dao.recordSnapshot('device-A', snapTime);

      final state = await dao.getDeviceState('device-A');
      expect(state!.lastSnapshotAt, snapTime.millisecondsSinceEpoch);
    });

    test('push sequence increments on each push', () async {
      await dao.initDevice('device-A');

      await dao.recordPush('device-A', DateTime.utc(2026, 3, 20, 10, 0));
      await dao.recordPush('device-A', DateTime.utc(2026, 3, 20, 10, 1));
      await dao.recordPush('device-A', DateTime.utc(2026, 3, 20, 10, 2));

      final state = await dao.getDeviceState('device-A');
      expect(state!.pushSequence, 3);
    });

    test('returns null for unknown device', () async {
      final state = await dao.getDeviceState('nonexistent');
      expect(state, isNull);
    });
  });
}
