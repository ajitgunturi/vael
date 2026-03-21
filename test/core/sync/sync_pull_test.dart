import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/crypto/aes_gcm.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/database/daos/sync_state_dao.dart';
import 'package:vael/core/sync/changeset_serializer.dart';
import 'package:vael/core/sync/drive_client_interface.dart';
import 'package:vael/core/sync/sync_pull.dart';

class MockDriveClient implements DriveClientInterface {
  final List<DriveFileEntry> files = [];
  final Map<String, Uint8List> fileData = {};

  @override
  Future<List<DriveFileEntry>> listChangesets({DateTime? after}) async {
    if (after == null) return files;
    return files.where((f) => f.modifiedTime.isAfter(after)).toList();
  }

  @override
  Future<Uint8List> downloadFile(String fileId) async {
    return fileData[fileId]!;
  }

  @override
  Future<void> uploadChangeset(String fileName, Uint8List data) async {}
  @override
  Future<void> uploadSnapshot(Uint8List data) async {}
  @override
  Future<Uint8List?> downloadSnapshot() async => null;
  @override
  Future<Map<String, dynamic>?> readManifest() async => null;
  @override
  Future<void> writeManifest(Map<String, dynamic> manifest) async {}

  void addEncryptedChangeset(
    String fileId,
    Changeset changeset,
    Uint8List fek,
    DateTime modifiedTime,
  ) {
    final serializer = ChangesetSerializer();
    final bytes = serializer.toBytes(changeset);
    final encrypted = AesGcm().encrypt(bytes, fek);

    files.add(
      DriveFileEntry(
        id: fileId,
        name: '$fileId.enc',
        modifiedTime: modifiedTime,
      ),
    );
    fileData[fileId] = encrypted;
  }
}

void main() {
  group('SyncPull', () {
    late AppDatabase db;
    late SyncStateDao stateDao;
    late MockDriveClient driveClient;
    late SyncPull syncPull;
    late Uint8List fek;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      stateDao = SyncStateDao(db);
      driveClient = MockDriveClient();
      fek = Uint8List.fromList(List.generate(32, (i) => i));

      syncPull = SyncPull(
        stateDao: stateDao,
        driveClient: driveClient,
        serializer: ChangesetSerializer(),
        aesGcm: AesGcm(),
        fek: fek,
        deviceId: 'device-B',
        applyOperations: (ops) async {}, // No-op for unit tests
      );
    });

    tearDown(() => db.close());

    test('downloads and decrypts new changesets', () async {
      await stateDao.initDevice('device-B');

      final appliedOps = <SyncOperation>[];
      syncPull = SyncPull(
        stateDao: stateDao,
        driveClient: driveClient,
        serializer: ChangesetSerializer(),
        aesGcm: AesGcm(),
        fek: fek,
        deviceId: 'device-B',
        applyOperations: (ops) async => appliedOps.addAll(ops),
      );

      driveClient.addEncryptedChangeset(
        'cs-1',
        Changeset(
          deviceId: 'device-A',
          sequence: 1,
          timestamp: DateTime.utc(2026, 3, 20, 10, 0),
          operations: [
            SyncOperation(
              op: OpType.insert,
              table: 'transactions',
              id: 'txn-001',
              data: {'amount': 15000},
            ),
          ],
        ),
        fek,
        DateTime.utc(2026, 3, 20, 10, 0),
      );

      await syncPull.pull();

      expect(appliedOps, hasLength(1));
      expect(appliedOps.first.table, 'transactions');
      expect(appliedOps.first.data!['amount'], 15000);
    });

    test('skips own device changesets', () async {
      await stateDao.initDevice('device-B');

      final appliedOps = <SyncOperation>[];
      syncPull = SyncPull(
        stateDao: stateDao,
        driveClient: driveClient,
        serializer: ChangesetSerializer(),
        aesGcm: AesGcm(),
        fek: fek,
        deviceId: 'device-B',
        applyOperations: (ops) async => appliedOps.addAll(ops),
      );

      driveClient.addEncryptedChangeset(
        'cs-own',
        Changeset(
          deviceId: 'device-B', // Same device
          sequence: 1,
          timestamp: DateTime.utc(2026, 3, 20, 10, 0),
          operations: [
            SyncOperation(
              op: OpType.insert,
              table: 'transactions',
              id: 'txn-own',
              data: {'amount': 999},
            ),
          ],
        ),
        fek,
        DateTime.utc(2026, 3, 20, 10, 0),
      );

      await syncPull.pull();

      expect(appliedOps, isEmpty);
    });

    test('updates lastPullAt after successful pull', () async {
      await stateDao.initDevice('device-B');

      driveClient.addEncryptedChangeset(
        'cs-1',
        Changeset(
          deviceId: 'device-A',
          sequence: 1,
          timestamp: DateTime.utc(2026, 3, 20, 10, 0),
          operations: [],
        ),
        fek,
        DateTime.utc(2026, 3, 20, 10, 0),
      );

      await syncPull.pull();

      final state = await stateDao.getDeviceState('device-B');
      expect(state!.lastPullAt, isNotNull);
    });

    test('only fetches changesets after last pull time', () async {
      await stateDao.initDevice('device-B');
      // Simulate a previous pull
      await stateDao.recordPull('device-B', DateTime.utc(2026, 3, 20, 9, 0));

      // Old changeset (before last pull) — should be skipped by listChangesets
      driveClient.addEncryptedChangeset(
        'cs-old',
        Changeset(
          deviceId: 'device-A',
          sequence: 1,
          timestamp: DateTime.utc(2026, 3, 20, 8, 0),
          operations: [
            SyncOperation(
              op: OpType.insert,
              table: 'accounts',
              id: 'acc-old',
              data: {},
            ),
          ],
        ),
        fek,
        DateTime.utc(2026, 3, 20, 8, 0),
      );

      // New changeset (after last pull)
      driveClient.addEncryptedChangeset(
        'cs-new',
        Changeset(
          deviceId: 'device-A',
          sequence: 2,
          timestamp: DateTime.utc(2026, 3, 20, 10, 0),
          operations: [
            SyncOperation(
              op: OpType.insert,
              table: 'accounts',
              id: 'acc-new',
              data: {},
            ),
          ],
        ),
        fek,
        DateTime.utc(2026, 3, 20, 10, 0),
      );

      final appliedOps = <SyncOperation>[];
      syncPull = SyncPull(
        stateDao: stateDao,
        driveClient: driveClient,
        serializer: ChangesetSerializer(),
        aesGcm: AesGcm(),
        fek: fek,
        deviceId: 'device-B',
        applyOperations: (ops) async => appliedOps.addAll(ops),
      );

      await syncPull.pull();

      expect(appliedOps, hasLength(1));
      expect(appliedOps.first.id, 'acc-new');
    });

    test('no-op when no new changesets', () async {
      await stateDao.initDevice('device-B');

      final appliedOps = <SyncOperation>[];
      syncPull = SyncPull(
        stateDao: stateDao,
        driveClient: driveClient,
        serializer: ChangesetSerializer(),
        aesGcm: AesGcm(),
        fek: fek,
        deviceId: 'device-B',
        applyOperations: (ops) async => appliedOps.addAll(ops),
      );

      await syncPull.pull();

      expect(appliedOps, isEmpty);
    });

    test('applies operations in timestamp order', () async {
      await stateDao.initDevice('device-B');

      final appliedIds = <String>[];
      syncPull = SyncPull(
        stateDao: stateDao,
        driveClient: driveClient,
        serializer: ChangesetSerializer(),
        aesGcm: AesGcm(),
        fek: fek,
        deviceId: 'device-B',
        applyOperations: (ops) async {
          appliedIds.addAll(ops.map((o) => o.id));
        },
      );

      // Add in reverse order
      driveClient.addEncryptedChangeset(
        'cs-2',
        Changeset(
          deviceId: 'device-A',
          sequence: 2,
          timestamp: DateTime.utc(2026, 3, 20, 11, 0),
          operations: [
            SyncOperation(
              op: OpType.insert,
              table: 't',
              id: 'second',
              data: {},
            ),
          ],
        ),
        fek,
        DateTime.utc(2026, 3, 20, 11, 0),
      );
      driveClient.addEncryptedChangeset(
        'cs-1',
        Changeset(
          deviceId: 'device-A',
          sequence: 1,
          timestamp: DateTime.utc(2026, 3, 20, 10, 0),
          operations: [
            SyncOperation(op: OpType.insert, table: 't', id: 'first', data: {}),
          ],
        ),
        fek,
        DateTime.utc(2026, 3, 20, 10, 0),
      );

      await syncPull.pull();

      expect(appliedIds, ['first', 'second']);
    });
  });
}
