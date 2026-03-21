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
import 'package:vael/core/sync/manifest.dart';
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
        userId: 'user-admin',
      );

      // Store V2 manifest on Drive
      final v2 = ManifestV2(
        familyId: 'family-001',
        owner: ManifestOwner(userId: 'user-admin', email: 'admin@test.com'),
        members: {
          'user-admin': MemberEntry(
            userId: 'user-admin',
            email: 'admin@test.com',
            role: 'admin',
            wrappedFek: setup.wrappedFek,
            fekSalt: setup.salt,
            addedAt: DateTime.utc(2026, 3, 20),
            addedBy: 'user-admin',
          ),
        },
      );
      await cloudStorage.writeManifest(v2.toJson());
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
        userId: 'user-admin',
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

  group('SyncOrchestrator — ManifestV2 integration', () {
    late AppDatabase db;
    late InMemoryCloudStorage cloudStorage;
    late KeyStorage keyStorage;
    late CryptoOrchestrator cryptoOrchestrator;
    late CryptoSetupResult adminSetup;

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

      adminSetup = await cryptoOrchestrator.setupFirstDevice(
        familyId: 'family-001',
        passphrase: 'admin-pass',
      );
    });

    tearDown(() => db.close());

    ManifestV2 makeV2Manifest() => ManifestV2(
      familyId: 'family-001',
      owner: ManifestOwner(userId: 'u-admin', email: 'admin@test.com'),
      members: {
        'u-admin': MemberEntry(
          userId: 'u-admin',
          email: 'admin@test.com',
          role: 'admin',
          wrappedFek: adminSetup.wrappedFek,
          fekSalt: adminSetup.salt,
          addedAt: DateTime.utc(2026, 3, 20),
          addedBy: 'u-admin',
        ),
      },
    );

    test('initialize reads and caches V2 manifest', () async {
      await cloudStorage.writeManifest(makeV2Manifest().toJson());

      final orchestrator = SyncOrchestrator(
        db: db,
        changelogDao: SyncChangelogDao(db),
        stateDao: SyncStateDao(db),
        cloudStorage: cloudStorage,
        keyStorage: keyStorage,
        familyId: 'family-001',
        deviceId: 'device-A',
        userId: 'u-admin',
      );

      await orchestrator.initialize();

      expect(orchestrator.cachedManifest, isNotNull);
      expect(orchestrator.cachedManifest!.familyId, 'family-001');
      expect(orchestrator.cachedManifest!.members, contains('u-admin'));
    });

    test('initialize migrates V1 manifest to V2 when admin', () async {
      // Write a V1-format manifest
      await cloudStorage.writeManifest({
        'family_id': 'family-001',
        'wrapped_fek': adminSetup.wrappedFek.toList(),
        'salt': adminSetup.salt.toList(),
      });

      final orchestrator = SyncOrchestrator(
        db: db,
        changelogDao: SyncChangelogDao(db),
        stateDao: SyncStateDao(db),
        cloudStorage: cloudStorage,
        keyStorage: keyStorage,
        familyId: 'family-001',
        deviceId: 'device-A',
        userId: 'u-admin',
        userEmail: 'admin@test.com',
        isAdmin: true,
      );

      await orchestrator.initialize();

      // Should have migrated to V2
      expect(orchestrator.cachedManifest, isNotNull);
      expect(ManifestV2.isV2(cloudStorage.manifest!), isTrue);
      expect(orchestrator.cachedManifest!.owner.userId, 'u-admin');
      expect(orchestrator.cachedManifest!.members['u-admin']!.role, 'admin');
    });

    test('push updates lastSyncAt for current user in manifest', () async {
      await cloudStorage.writeManifest(makeV2Manifest().toJson());

      final orchestrator = SyncOrchestrator(
        db: db,
        changelogDao: SyncChangelogDao(db),
        stateDao: SyncStateDao(db),
        cloudStorage: cloudStorage,
        keyStorage: keyStorage,
        familyId: 'family-001',
        deviceId: 'device-A',
        userId: 'u-admin',
      );
      await orchestrator.initialize();

      // Create a change to push
      await SyncChangelogDao(db).insertEntry(
        entityType: 'transactions',
        entityId: 'txn-001',
        operation: 'INSERT',
        payload: '{"amount":5000}',
        timestamp: DateTime.utc(2026, 3, 21),
      );

      await orchestrator.push();

      // Manifest should now have lastSyncAt for u-admin
      final updatedManifest = ManifestV2.fromJson(cloudStorage.manifest!);
      expect(updatedManifest.members['u-admin']!.lastSyncAt, isNotNull);
    });

    test('pull updates lastSyncAt for current user in manifest', () async {
      final manifest = makeV2Manifest();
      await cloudStorage.writeManifest(manifest.toJson());

      // Simulate another device having pushed data
      final aes = AesGcm();
      final fek = await keyStorage.getFek('family-001');
      const changesetData =
          '{"device_id":"device-X","sequence":1,"timestamp":"2026-03-21T10:00:00.000Z","operations":[{"op":"INSERT","table":"accounts","id":"acc-001","data":{"name":"Savings"}}]}';
      final encrypted = aes.encrypt(
        Uint8List.fromList(changesetData.codeUnits),
        fek!,
      );
      await cloudStorage.uploadChangeset(
        '2026-03-21T10-00-00_device-X_001.enc',
        encrypted,
      );

      final orchestrator = SyncOrchestrator(
        db: db,
        changelogDao: SyncChangelogDao(db),
        stateDao: SyncStateDao(db),
        cloudStorage: cloudStorage,
        keyStorage: keyStorage,
        familyId: 'family-001',
        deviceId: 'device-A',
        userId: 'u-admin',
        onOperationsApplied: (_) async {},
      );
      await orchestrator.initialize();
      await orchestrator.pull();

      final updatedManifest = ManifestV2.fromJson(cloudStorage.manifest!);
      expect(updatedManifest.members['u-admin']!.lastSyncAt, isNotNull);
    });

    test('detects FEK generation change and invokes callback', () async {
      final manifest = makeV2Manifest();
      await cloudStorage.writeManifest(manifest.toJson());

      final orchestrator = SyncOrchestrator(
        db: db,
        changelogDao: SyncChangelogDao(db),
        stateDao: SyncStateDao(db),
        cloudStorage: cloudStorage,
        keyStorage: keyStorage,
        familyId: 'family-001',
        deviceId: 'device-A',
        userId: 'u-admin',
      );
      await orchestrator.initialize();

      // Simulate FEK rotation by another device: bump generation
      final rotatedManifest = manifest.withRotatedFek({
        'u-admin': adminSetup.wrappedFek, // Same wrapping for simplicity
      });
      await cloudStorage.writeManifest(rotatedManifest.toJson());

      var rotationDetected = false;
      orchestrator.onFekRotationDetected = (int newGeneration) async {
        rotationDetected = true;
      };

      await orchestrator.refreshManifest();

      expect(rotationDetected, isTrue);
    });

    test('getManifestStatus returns member info', () async {
      final manifest = makeV2Manifest();
      await cloudStorage.writeManifest(manifest.toJson());

      final orchestrator = SyncOrchestrator(
        db: db,
        changelogDao: SyncChangelogDao(db),
        stateDao: SyncStateDao(db),
        cloudStorage: cloudStorage,
        keyStorage: keyStorage,
        familyId: 'family-001',
        deviceId: 'device-A',
        userId: 'u-admin',
      );
      await orchestrator.initialize();

      final manifestStatus = orchestrator.getManifestStatus();
      expect(manifestStatus, isNotNull);
      expect(manifestStatus!.memberCount, 1);
      expect(manifestStatus.isAdmin, isTrue);
      expect(manifestStatus.fekGeneration, 1);
    });

    test('initialize works gracefully with no manifest', () async {
      // No manifest written to cloud storage

      final orchestrator = SyncOrchestrator(
        db: db,
        changelogDao: SyncChangelogDao(db),
        stateDao: SyncStateDao(db),
        cloudStorage: cloudStorage,
        keyStorage: keyStorage,
        familyId: 'family-001',
        deviceId: 'device-A',
        userId: 'u-admin',
      );
      await orchestrator.initialize();

      expect(orchestrator.cachedManifest, isNull);
    });
  });
}
