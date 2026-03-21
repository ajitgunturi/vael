import 'dart:typed_data';

import '../crypto/aes_gcm.dart';
import '../crypto/key_storage.dart';
import '../database/database.dart';
import '../database/daos/sync_changelog_dao.dart';
import '../database/daos/sync_state_dao.dart';
import 'changeset_serializer.dart';
import 'cloud_storage_interface.dart';
import 'snapshot_manager.dart';
import 'sync_pull.dart';
import 'sync_push.dart';

/// Status of the sync engine for display in Settings.
class SyncStatus {
  final String deviceId;
  final int pendingChanges;
  final DateTime? lastPushAt;
  final DateTime? lastPullAt;
  final DateTime? lastSnapshotAt;
  final int pushSequence;

  SyncStatus({
    required this.deviceId,
    required this.pendingChanges,
    this.lastPushAt,
    this.lastPullAt,
    this.lastSnapshotAt,
    this.pushSequence = 0,
  });
}

/// Top-level coordinator for sync operations.
///
/// Joins the crypto track (FEK-based encryption) with the sync track
/// (push/pull/snapshot) and manages device registration.
class SyncOrchestrator {
  final AppDatabase db;
  final SyncChangelogDao changelogDao;
  final SyncStateDao stateDao;
  final CloudStorageInterface cloudStorage;
  final KeyStorage keyStorage;
  final String familyId;
  final String deviceId;
  final Future<void> Function(List<SyncOperation> ops)? onOperationsApplied;

  SyncOrchestrator({
    required this.db,
    required this.changelogDao,
    required this.stateDao,
    required this.cloudStorage,
    required this.keyStorage,
    required this.familyId,
    required this.deviceId,
    this.onOperationsApplied,
  });

  /// Registers this device in the sync state table.
  Future<void> initialize() async {
    await stateDao.initDevice(deviceId);
  }

  /// Pushes unsynced local changes to Drive.
  Future<void> push() async {
    final fek = await _requireFek();
    final push = SyncPush(
      changelogDao: changelogDao,
      stateDao: stateDao,
      cloudStorage: cloudStorage,
      serializer: ChangesetSerializer(),
      aesGcm: AesGcm(),
      fek: fek,
      deviceId: deviceId,
    );
    await push.push();
  }

  /// Pulls new changes from Drive and applies them.
  Future<void> pull() async {
    final fek = await _requireFek();
    final pull = SyncPull(
      stateDao: stateDao,
      cloudStorage: cloudStorage,
      serializer: ChangesetSerializer(),
      aesGcm: AesGcm(),
      fek: fek,
      deviceId: deviceId,
      applyOperations: onOperationsApplied ?? (_) async {},
    );
    await pull.pull();
  }

  /// Creates and uploads an encrypted full database snapshot.
  Future<void> createSnapshot(Uint8List dbBytes) async {
    final fek = await _requireFek();
    final manager = SnapshotManager(
      cloudStorage: cloudStorage,
      aesGcm: AesGcm(),
      fek: fek,
    );
    await manager.uploadSnapshot(dbBytes);
    await stateDao.recordSnapshot(deviceId, DateTime.now().toUtc());
  }

  /// Returns current sync status for UI display.
  Future<SyncStatus> getStatus() async {
    final state = await stateDao.getDeviceState(deviceId);
    final unsynced = await changelogDao.getUnsyncedEntries();

    return SyncStatus(
      deviceId: deviceId,
      pendingChanges: unsynced.length,
      lastPushAt: state?.lastPushAt != null
          ? DateTime.fromMillisecondsSinceEpoch(state!.lastPushAt!)
          : null,
      lastPullAt: state?.lastPullAt != null
          ? DateTime.fromMillisecondsSinceEpoch(state!.lastPullAt!)
          : null,
      lastSnapshotAt: state?.lastSnapshotAt != null
          ? DateTime.fromMillisecondsSinceEpoch(state!.lastSnapshotAt!)
          : null,
      pushSequence: state?.pushSequence ?? 0,
    );
  }

  Future<Uint8List> _requireFek() async {
    final fek = await keyStorage.getFek(familyId);
    if (fek == null) throw StateError('No FEK stored for family $familyId');
    return fek;
  }
}
