import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/crypto/aes_gcm.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/database/daos/sync_changelog_dao.dart';
import 'package:vael/core/database/daos/sync_state_dao.dart';
import 'package:vael/core/sync/changeset_serializer.dart';
import 'package:vael/core/sync/cloud_storage_interface.dart';
import 'package:vael/core/sync/sync_push.dart';

class MockCloudStorage implements CloudStorageInterface {
  final uploads = <String, Uint8List>{};
  bool shouldFail = false;

  @override
  Future<void> uploadChangeset(String fileName, Uint8List data) async {
    if (shouldFail) throw Exception('Upload failed');
    uploads[fileName] = data;
  }

  @override
  Future<Uint8List> downloadFile(String fileId) async => Uint8List(0);

  @override
  Future<List<CloudFileEntry>> listChangesets({DateTime? after}) async => [];

  @override
  Future<void> uploadSnapshot(Uint8List data) async {}

  @override
  Future<Uint8List?> downloadSnapshot() async => null;

  @override
  Future<Map<String, dynamic>?> readManifest() async => null;

  @override
  Future<void> writeManifest(Map<String, dynamic> manifest) async {}
}

void main() {
  group('SyncPush', () {
    late AppDatabase db;
    late SyncChangelogDao changelogDao;
    late SyncStateDao stateDao;
    late MockCloudStorage cloudStorage;
    late SyncPush syncPush;
    late Uint8List fek;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      changelogDao = SyncChangelogDao(db);
      stateDao = SyncStateDao(db);
      cloudStorage = MockCloudStorage();
      fek = Uint8List.fromList(List.generate(32, (i) => i));

      syncPush = SyncPush(
        changelogDao: changelogDao,
        stateDao: stateDao,
        cloudStorage: cloudStorage,
        serializer: ChangesetSerializer(),
        aesGcm: AesGcm(),
        fek: fek,
        deviceId: 'device-A',
      );
    });

    tearDown(() => db.close());

    test('pushes unsynced entries as encrypted changeset', () async {
      await stateDao.initDevice('device-A');
      await changelogDao.insertEntry(
        entityType: 'transactions',
        entityId: 'txn-001',
        operation: 'INSERT',
        payload: '{"amount":15000}',
        timestamp: DateTime.utc(2026, 3, 20, 10, 30),
      );

      await syncPush.push();

      // One file uploaded
      expect(cloudStorage.uploads, hasLength(1));

      // Entries marked as synced
      final unsynced = await changelogDao.getUnsyncedEntries();
      expect(unsynced, isEmpty);
    });

    test('uploaded data is encrypted (not readable as JSON)', () async {
      await stateDao.initDevice('device-A');
      await changelogDao.insertEntry(
        entityType: 'transactions',
        entityId: 'txn-001',
        operation: 'INSERT',
        payload: '{"amount":15000}',
        timestamp: DateTime.utc(2026, 3, 20, 10, 30),
      );

      await syncPush.push();

      final uploaded = cloudStorage.uploads.values.first;
      // Should NOT be valid JSON — it's encrypted
      expect(() => jsonDecode(utf8.decode(uploaded)), throwsFormatException);
    });

    test('uploaded data can be decrypted back to changeset', () async {
      await stateDao.initDevice('device-A');
      await changelogDao.insertEntry(
        entityType: 'transactions',
        entityId: 'txn-001',
        operation: 'INSERT',
        payload: '{"amount":15000}',
        timestamp: DateTime.utc(2026, 3, 20, 10, 30),
      );

      await syncPush.push();

      final uploaded = cloudStorage.uploads.values.first;
      final decrypted = AesGcm().decrypt(uploaded, fek);
      final changeset = ChangesetSerializer().deserialize(
        utf8.decode(decrypted),
      );

      expect(changeset.deviceId, 'device-A');
      expect(changeset.operations, hasLength(1));
      expect(changeset.operations.first.data!['amount'], 15000);
    });

    test('batches multiple entries into one changeset', () async {
      await stateDao.initDevice('device-A');
      for (var i = 0; i < 5; i++) {
        await changelogDao.insertEntry(
          entityType: 'transactions',
          entityId: 'txn-$i',
          operation: 'INSERT',
          payload: '{"amount":${i * 1000}}',
          timestamp: DateTime.utc(2026, 3, 20, 10, i),
        );
      }

      await syncPush.push();

      // Single upload with 5 operations
      expect(cloudStorage.uploads, hasLength(1));
      final uploaded = cloudStorage.uploads.values.first;
      final decrypted = AesGcm().decrypt(uploaded, fek);
      final changeset = ChangesetSerializer().deserialize(
        utf8.decode(decrypted),
      );
      expect(changeset.operations, hasLength(5));
    });

    test('no-op when no unsynced entries', () async {
      await stateDao.initDevice('device-A');
      await syncPush.push();

      expect(cloudStorage.uploads, isEmpty);
    });

    test('increments push sequence in sync state', () async {
      await stateDao.initDevice('device-A');
      await changelogDao.insertEntry(
        entityType: 'accounts',
        entityId: 'acc-001',
        operation: 'INSERT',
        payload: '{}',
        timestamp: DateTime.utc(2026, 3, 20),
      );

      await syncPush.push();

      final state = await stateDao.getDeviceState('device-A');
      expect(state!.pushSequence, 1);
    });

    test('entries remain unsynced when upload fails', () async {
      await stateDao.initDevice('device-A');
      await changelogDao.insertEntry(
        entityType: 'accounts',
        entityId: 'acc-001',
        operation: 'INSERT',
        payload: '{}',
        timestamp: DateTime.utc(2026, 3, 20),
      );

      cloudStorage.shouldFail = true;

      expect(() => syncPush.push(), throwsException);

      final unsynced = await changelogDao.getUnsyncedEntries();
      expect(unsynced, hasLength(1)); // Still unsynced
    });

    test('file name contains device ID and sequence', () async {
      await stateDao.initDevice('device-A');
      await changelogDao.insertEntry(
        entityType: 'accounts',
        entityId: 'acc-001',
        operation: 'INSERT',
        payload: '{}',
        timestamp: DateTime.utc(2026, 3, 20, 10, 30),
      );

      await syncPush.push();

      final fileName = cloudStorage.uploads.keys.first;
      expect(fileName, contains('device-A'));
      expect(fileName, endsWith('.enc'));
    });
  });
}
