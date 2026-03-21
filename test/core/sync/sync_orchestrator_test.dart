import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/crypto/aes_gcm.dart';
import 'package:vael/core/crypto/crypto_orchestrator.dart';
import 'package:vael/core/crypto/fek_manager.dart';
import 'package:vael/core/crypto/key_derivation.dart';
import 'package:vael/core/crypto/key_storage.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/database/daos/sync_changelog_dao.dart';
import 'package:vael/core/database/daos/sync_state_dao.dart';
import 'package:vael/core/sync/cloud_storage_interface.dart';
import 'package:vael/core/sync/sync_orchestrator.dart';

class InMemoryCloudStorage implements CloudStorageInterface {
  final uploads = <String, Uint8List>{};
  Uint8List? snapshot;
  Map<String, dynamic>? manifest;
  final _changesetFiles = <CloudFileEntry>[];

  @override
  Future<void> uploadChangeset(String fileName, Uint8List data) async {
    uploads[fileName] = data;
    _changesetFiles.add(
      CloudFileEntry(
        id: fileName,
        name: fileName,
        modifiedTime: DateTime.now().toUtc(),
      ),
    );
  }

  @override
  Future<Uint8List> downloadFile(String fileId) async {
    return uploads[fileId]!;
  }

  @override
  Future<List<CloudFileEntry>> listChangesets({DateTime? after}) async {
    if (after == null) return _changesetFiles;
    return _changesetFiles.where((f) => f.modifiedTime.isAfter(after)).toList();
  }

  @override
  Future<void> uploadSnapshot(Uint8List data) async {
    snapshot = data;
  }

  @override
  Future<Uint8List?> downloadSnapshot() async => snapshot;

  @override
  Future<Map<String, dynamic>?> readManifest() async => manifest;

  @override
  Future<void> writeManifest(Map<String, dynamic> m) async {
    manifest = m;
  }
}

void main() {
  group('SyncOrchestrator', () {
    late AppDatabase db;
    late SyncOrchestrator orchestrator;
    late InMemoryCloudStorage cloudStorage;
    late KeyStorage keyStorage;
    late CryptoOrchestrator cryptoOrchestrator;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      cloudStorage = InMemoryCloudStorage();
      keyStorage = KeyStorage(storage: InMemorySecureStorage());

      final kd = KeyDerivation();
      final aes = AesGcm();
      cryptoOrchestrator = CryptoOrchestrator(
        keyDerivation: kd,
        fekManager: FekManager(keyDerivation: kd, aesGcm: aes),
        keyStorage: keyStorage,
        aesGcm: aes,
      );

      // Setup crypto (first device)
      final setup = await cryptoOrchestrator.setupFirstDevice(
        familyId: 'family-001',
        passphrase: 'test-passphrase',
      );

      orchestrator = SyncOrchestrator(
        db: db,
        changelogDao: SyncChangelogDao(db),
        stateDao: SyncStateDao(db),
        cloudStorage: cloudStorage,
        keyStorage: keyStorage,
        familyId: 'family-001',
        deviceId: 'device-A',
      );

      // Store manifest on Drive
      await cloudStorage.writeManifest({
        'family_id': 'family-001',
        'wrapped_fek': setup.wrappedFek.toList(),
        'salt': setup.salt.toList(),
      });
    });

    tearDown(() => db.close());

    test('initializes device on first use', () async {
      await orchestrator.initialize();

      final stateDao = SyncStateDao(db);
      final state = await stateDao.getDeviceState('device-A');
      expect(state, isNotNull);
    });

    test('push sends encrypted changesets to cloud storage', () async {
      await orchestrator.initialize();

      final changelogDao = SyncChangelogDao(db);
      await changelogDao.insertEntry(
        entityType: 'transactions',
        entityId: 'txn-001',
        operation: 'INSERT',
        payload: '{"amount":15000}',
        timestamp: DateTime.utc(2026, 3, 20, 10, 30),
      );

      await orchestrator.push();

      expect(cloudStorage.uploads, isNotEmpty);
    });

    test('full push-pull cycle between two devices', () async {
      await orchestrator.initialize();

      // Device A creates a transaction
      final changelogDao = SyncChangelogDao(db);
      await changelogDao.insertEntry(
        entityType: 'transactions',
        entityId: 'txn-001',
        operation: 'INSERT',
        payload: '{"amount":15000}',
        timestamp: DateTime.utc(2026, 3, 20, 10, 30),
      );

      await orchestrator.push();

      // Device B pulls
      final db2 = AppDatabase(NativeDatabase.memory());
      final pulledOps = <String>[];

      final orchestratorB = SyncOrchestrator(
        db: db2,
        changelogDao: SyncChangelogDao(db2),
        stateDao: SyncStateDao(db2),
        cloudStorage: cloudStorage,
        keyStorage: keyStorage,
        familyId: 'family-001',
        deviceId: 'device-B',
        onOperationsApplied: (ops) async {
          pulledOps.addAll(ops.map((o) => o.id));
        },
      );
      await orchestratorB.initialize();
      await orchestratorB.pull();

      expect(pulledOps, contains('txn-001'));

      await db2.close();
    });

    test('createSnapshot uploads encrypted DB bytes', () async {
      await orchestrator.initialize();
      final dbBytes = Uint8List.fromList(List.generate(256, (i) => i));

      await orchestrator.createSnapshot(dbBytes);

      expect(cloudStorage.snapshot, isNotNull);
      // Snapshot is encrypted — different from raw
      expect(cloudStorage.snapshot, isNot(equals(dbBytes)));
    });

    test('sync status reports correct state', () async {
      await orchestrator.initialize();

      final status = await orchestrator.getStatus();
      expect(status.deviceId, 'device-A');
      expect(status.pendingChanges, 0);
      expect(status.lastPushAt, isNull);
    });

    test('sync status shows pending changes', () async {
      await orchestrator.initialize();

      final changelogDao = SyncChangelogDao(db);
      await changelogDao.insertEntry(
        entityType: 'accounts',
        entityId: 'acc-001',
        operation: 'INSERT',
        payload: '{}',
        timestamp: DateTime.utc(2026, 3, 20),
      );
      await changelogDao.insertEntry(
        entityType: 'accounts',
        entityId: 'acc-002',
        operation: 'INSERT',
        payload: '{}',
        timestamp: DateTime.utc(2026, 3, 20),
      );

      final status = await orchestrator.getStatus();
      expect(status.pendingChanges, 2);
    });
  });
}
