import 'dart:convert';
import 'dart:typed_data';

import '../crypto/aes_gcm.dart';
import '../database/daos/sync_changelog_dao.dart';
import '../database/daos/sync_state_dao.dart';
import 'changeset_serializer.dart';
import 'cloud_storage_interface.dart';

/// Pushes unsynced local changes to cloud storage as encrypted changesets.
class SyncPush {
  final SyncChangelogDao changelogDao;
  final SyncStateDao stateDao;
  final CloudStorageInterface cloudStorage;
  final ChangesetSerializer serializer;
  final AesGcm aesGcm;
  final Uint8List fek;
  final String deviceId;

  SyncPush({
    required this.changelogDao,
    required this.stateDao,
    required this.cloudStorage,
    required this.serializer,
    required this.aesGcm,
    required this.fek,
    required this.deviceId,
  });

  /// Batches all unsynced changelog entries, encrypts, and uploads to Drive.
  Future<void> push() async {
    final entries = await changelogDao.getUnsyncedEntries();
    if (entries.isEmpty) return;

    final state = await stateDao.getDeviceState(deviceId);
    final sequence = (state?.pushSequence ?? 0) + 1;

    final operations = entries.map((e) {
      Map<String, dynamic>? data;
      if (e.payload.isNotEmpty) {
        try {
          data = jsonDecode(e.payload) as Map<String, dynamic>;
        } catch (_) {
          data = {'_raw': e.payload};
        }
      }

      return SyncOperation(
        op: OpType.values.firstWhere(
          (t) => t.name.toUpperCase() == e.operation,
        ),
        table: e.entityType,
        id: e.entityId,
        data: data,
        deletedAt: e.operation == 'DELETE' ? e.timestamp : null,
      );
    }).toList();

    final changeset = Changeset(
      deviceId: deviceId,
      sequence: sequence,
      timestamp: DateTime.now().toUtc(),
      operations: operations,
    );

    final bytes = serializer.toBytes(changeset);
    final encrypted = aesGcm.encrypt(bytes, fek);

    final timestamp = DateTime.now().toUtc().toIso8601String().replaceAll(
      ':',
      '-',
    );
    final fileName =
        '${timestamp}_${deviceId}_${'$sequence'.padLeft(3, '0')}.enc';

    await cloudStorage.uploadChangeset(fileName, encrypted);

    await changelogDao.markSynced(entries.map((e) => e.id).toList(), fileName);
    await stateDao.recordPush(deviceId, DateTime.now().toUtc());
  }
}
