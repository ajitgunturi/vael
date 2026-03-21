import 'changeset_serializer.dart';

enum ConflictResolution {
  keepLocal,
  acceptRemote,
  mergeBoth,
  acceptDelete,
}

enum SchemaCheck {
  compatible,
  blocked,
}

/// Resolves conflicts between local and remote sync operations.
///
/// Strategy per SYNC.md:
/// - Same entity updated: last-writer-wins by timestamp
/// - Both insert different entities: additive merge (both kept)
/// - Delete vs update: delete wins
/// - Schema mismatch: block sync
class ConflictResolver {
  /// Resolves two updates to the same entity using last-writer-wins.
  ///
  /// When timestamps are equal, [remoteDeviceId] > [localDeviceId]
  /// lexicographically means remote wins (deterministic tiebreaker).
  ConflictResolution resolve({
    required SyncOperation local,
    required SyncOperation remote,
    required DateTime localTimestamp,
    required DateTime remoteTimestamp,
    String localDeviceId = '',
    String remoteDeviceId = '',
  }) {
    if (remoteTimestamp.isAfter(localTimestamp)) {
      return ConflictResolution.acceptRemote;
    }
    if (localTimestamp.isAfter(remoteTimestamp)) {
      return ConflictResolution.keepLocal;
    }
    // Equal timestamps — deterministic tiebreaker
    return remoteDeviceId.compareTo(localDeviceId) > 0
        ? ConflictResolution.acceptRemote
        : ConflictResolution.keepLocal;
  }

  /// Two inserts on different entities → keep both.
  ConflictResolution resolveInserts({
    required SyncOperation local,
    required SyncOperation remote,
  }) {
    return ConflictResolution.mergeBoth;
  }

  /// Delete always wins over update (explicit user intent).
  ConflictResolution resolveDeleteVsUpdate({
    required SyncOperation delete,
    required SyncOperation update,
  }) {
    return ConflictResolution.acceptDelete;
  }

  /// Checks schema version compatibility before sync.
  ///
  /// Local can handle older remote data, but remote with a newer
  /// schema means the local app needs to upgrade.
  SchemaCheck checkSchemaCompatibility({
    required int localVersion,
    required int remoteVersion,
  }) {
    if (remoteVersion > localVersion) return SchemaCheck.blocked;
    return SchemaCheck.compatible;
  }
}
