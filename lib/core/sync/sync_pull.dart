import 'dart:typed_data';

import '../crypto/aes_gcm.dart';
import '../database/daos/sync_state_dao.dart';
import 'changeset_serializer.dart';
import 'drive_client_interface.dart';

/// Pulls new changesets from Google Drive, decrypts, and applies operations.
class SyncPull {
  final SyncStateDao stateDao;
  final DriveClientInterface driveClient;
  final ChangesetSerializer serializer;
  final AesGcm aesGcm;
  final Uint8List fek;
  final String deviceId;
  final Future<void> Function(List<SyncOperation> ops) applyOperations;

  SyncPull({
    required this.stateDao,
    required this.driveClient,
    required this.serializer,
    required this.aesGcm,
    required this.fek,
    required this.deviceId,
    required this.applyOperations,
  });

  /// Downloads new changesets from Drive, decrypts, and applies in order.
  Future<void> pull() async {
    final state = await stateDao.getDeviceState(deviceId);
    final lastPullAt = state?.lastPullAt != null
        ? DateTime.fromMillisecondsSinceEpoch(state!.lastPullAt!)
        : null;

    final files = await driveClient.listChangesets(after: lastPullAt);
    if (files.isEmpty) return;

    // Sort by modification time for correct ordering
    files.sort((a, b) => a.modifiedTime.compareTo(b.modifiedTime));

    for (final file in files) {
      final encrypted = await driveClient.downloadFile(file.id);
      final decrypted = aesGcm.decrypt(encrypted, fek);
      final changeset = serializer.fromBytes(decrypted);

      // Skip own device's changesets — already applied locally
      if (changeset.deviceId == deviceId) continue;

      await applyOperations(changeset.operations);
    }

    await stateDao.recordPull(deviceId, DateTime.now().toUtc());
  }
}
