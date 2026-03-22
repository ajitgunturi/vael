import 'dart:typed_data';

import '../crypto/aes_gcm.dart';
import '../database/database.dart';
import '../database/daos/sync_changelog_dao.dart';
import '../database/daos/sync_state_dao.dart';
import 'changeset_serializer.dart';
import 'cloud_storage_interface.dart';
import 'conflict_resolver.dart';
import 'snapshot_manager.dart';

/// Pulls new changesets from cloud storage, decrypts, resolves conflicts,
/// and applies operations to the local database.
class SyncPull {
  final SyncStateDao stateDao;
  final SyncChangelogDao changelogDao;
  final CloudStorageInterface cloudStorage;
  final ChangesetSerializer serializer;
  final AesGcm aesGcm;
  final Uint8List fek;
  final String deviceId;
  final Future<void> Function(List<SyncOperation> ops) applyOperations;
  final SnapshotManager? snapshotManager;
  final ConflictResolver _conflictResolver = ConflictResolver();

  /// Threshold above which we download a snapshot instead of replaying
  /// individual changesets (M13: backlog optimization).
  static const int backlogThreshold = 1000;

  SyncPull({
    required this.stateDao,
    required this.changelogDao,
    required this.cloudStorage,
    required this.serializer,
    required this.aesGcm,
    required this.fek,
    required this.deviceId,
    required this.applyOperations,
    this.snapshotManager,
  });

  /// Downloads new changesets from Drive, decrypts, resolves conflicts,
  /// and applies in order.
  Future<void> pull() async {
    final state = await stateDao.getDeviceState(deviceId);
    final lastPullAt = state?.lastPullAt != null
        ? DateTime.fromMillisecondsSinceEpoch(state!.lastPullAt!)
        : null;

    final files = await cloudStorage.listChangesets(after: lastPullAt);
    if (files.isEmpty) return;

    // M13: If backlog exceeds threshold, download snapshot instead
    if (files.length > backlogThreshold && snapshotManager != null) {
      final snapshotBytes = await snapshotManager!.downloadSnapshot();
      if (snapshotBytes != null) {
        // Snapshot restore would replace local DB — handled by caller
        await applyOperations([
          SyncOperation(
            op: OpType.insert,
            table: '_snapshot_restore',
            id: 'snapshot',
            data: {'bytes_length': snapshotBytes.length},
          ),
        ]);
        await stateDao.recordPull(deviceId, DateTime.now().toUtc());
        return;
      }
    }

    // Sort by modification time for correct ordering
    files.sort((a, b) => a.modifiedTime.compareTo(b.modifiedTime));

    // Get local unsynced entries to check for conflicts
    final localUnsynced = await changelogDao.getUnsyncedEntries();
    final localByEntityId = <String, SyncChangelogData>{};
    for (final entry in localUnsynced) {
      localByEntityId[entry.entityId] = entry;
    }

    for (final file in files) {
      final encrypted = await cloudStorage.downloadFile(file.id);
      final decrypted = aesGcm.decrypt(encrypted, fek);
      final changeset = serializer.fromBytes(decrypted);

      // Skip own device's changesets — already applied locally
      if (changeset.deviceId == deviceId) continue;

      // C4: Resolve conflicts before applying
      final resolvedOps = <SyncOperation>[];
      for (final remoteOp in changeset.operations) {
        final localEntry = localByEntityId[remoteOp.id];

        if (localEntry == null) {
          // No conflict — accept remote
          resolvedOps.add(remoteOp);
          continue;
        }

        // Conflict detected — resolve
        if (remoteOp.op == OpType.delete) {
          // Delete vs local update → delete wins
          final resolution = _conflictResolver.resolveDeleteVsUpdate(
            delete: remoteOp,
            update: SyncOperation(
              op: OpType.update,
              table: localEntry.entityType,
              id: localEntry.entityId,
            ),
          );
          if (resolution == ConflictResolution.acceptDelete) {
            resolvedOps.add(remoteOp);
          }
        } else if (localEntry.operation == 'INSERT' &&
            remoteOp.op == OpType.insert) {
          // Both insert — additive merge (keep both)
          resolvedOps.add(remoteOp);
        } else {
          // Both update same entity — LWW
          final resolution = _conflictResolver.resolve(
            local: SyncOperation(
              op: OpType.update,
              table: localEntry.entityType,
              id: localEntry.entityId,
            ),
            remote: remoteOp,
            localTimestamp: localEntry.timestamp,
            remoteTimestamp: changeset.timestamp,
            localDeviceId: deviceId,
            remoteDeviceId: changeset.deviceId,
          );
          if (resolution == ConflictResolution.acceptRemote) {
            resolvedOps.add(remoteOp);
          }
          // keepLocal → skip remote op
        }
      }

      if (resolvedOps.isNotEmpty) {
        await applyOperations(resolvedOps);
      }
    }

    await stateDao.recordPull(deviceId, DateTime.now().toUtc());
  }
}
