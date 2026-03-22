import 'dart:async';
import 'dart:typed_data';

import 'package:drift/drift.dart';

import '../crypto/aes_gcm.dart';
import '../crypto/key_storage.dart';
import '../database/database.dart';
import '../database/daos/sync_changelog_dao.dart';
import '../database/daos/sync_state_dao.dart';
import 'changeset_serializer.dart';
import 'cloud_storage_interface.dart';
import 'manifest.dart';
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

/// Summary of manifest state for UI display.
class ManifestStatus {
  final int memberCount;
  final bool isAdmin;
  final int fekGeneration;
  final String ownerEmail;
  final List<MemberEntry> members;

  ManifestStatus({
    required this.memberCount,
    required this.isAdmin,
    required this.fekGeneration,
    required this.ownerEmail,
    required this.members,
  });
}

/// Top-level coordinator for sync operations.
///
/// Joins the crypto track (FEK-based encryption) with the sync track
/// (push/pull/snapshot), manages device registration, and maintains
/// the ManifestV2 lifecycle (read, migrate, update lastSyncAt, detect
/// FEK rotation).
class SyncOrchestrator {
  final AppDatabase db;
  final SyncChangelogDao changelogDao;
  final SyncStateDao stateDao;
  final CloudStorageInterface cloudStorage;
  final KeyStorage keyStorage;
  final String familyId;
  final String deviceId;
  final String? userId;
  final String? userEmail;
  final bool isAdmin;

  /// Called when a FEK generation change is detected in the manifest.
  Future<void> Function(int newGeneration)? onFekRotationDetected;

  ManifestV2? _cachedManifest;
  int? _lastKnownFekGeneration;
  Timer? _pushTimer;
  Timer? _pullTimer;

  SyncOrchestrator({
    required this.db,
    required this.changelogDao,
    required this.stateDao,
    required this.cloudStorage,
    required this.keyStorage,
    required this.familyId,
    required this.deviceId,
    this.userId,
    this.userEmail,
    this.isAdmin = false,
    this.onFekRotationDetected,
  });

  /// The currently cached manifest, if any.
  ManifestV2? get cachedManifest => _cachedManifest;

  /// Registers this device in the sync state table and loads the manifest.
  Future<void> initialize() async {
    await stateDao.initDevice(deviceId);
    await _loadManifest();
  }

  /// M12: Starts periodic sync — push every 30s, pull every 60s.
  void startPeriodicSync() {
    stopPeriodicSync();
    _pushTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => push().catchError((_) {}),
    );
    _pullTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => pull().catchError((_) {}),
    );
  }

  /// Stops periodic sync timers.
  void stopPeriodicSync() {
    _pushTimer?.cancel();
    _pullTimer?.cancel();
    _pushTimer = null;
    _pullTimer = null;
  }

  /// Pushes unsynced local changes to Drive, then updates lastSyncAt.
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
    await _updateLastSyncAt();
  }

  /// Pulls new changes from Drive, resolves conflicts, applies them,
  /// then updates lastSyncAt.
  Future<void> pull() async {
    final fek = await _requireFek();
    final pull = SyncPull(
      stateDao: stateDao,
      changelogDao: changelogDao,
      cloudStorage: cloudStorage,
      serializer: ChangesetSerializer(),
      aesGcm: AesGcm(),
      fek: fek,
      deviceId: deviceId,
      applyOperations: _applyOperations,
      snapshotManager: SnapshotManager(
        cloudStorage: cloudStorage,
        aesGcm: AesGcm(),
        fek: fek,
      ),
    );
    await pull.pull();
    await _updateLastSyncAt();
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

  /// Re-reads the manifest from cloud storage and checks for FEK rotation.
  Future<void> refreshManifest() async {
    final json = await cloudStorage.readManifest();
    if (json == null || !ManifestV2.isV2(json)) return;

    final manifest = ManifestV2.fromJson(json);
    final previousGeneration = _lastKnownFekGeneration;
    _cachedManifest = manifest;
    _lastKnownFekGeneration = manifest.fekGeneration;

    if (previousGeneration != null &&
        manifest.fekGeneration != previousGeneration &&
        onFekRotationDetected != null) {
      await onFekRotationDetected!(manifest.fekGeneration);
    }
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

  /// Returns manifest-level status for the admin dashboard.
  ManifestStatus? getManifestStatus() {
    if (_cachedManifest == null || userId == null) return null;
    return ManifestStatus(
      memberCount: _cachedManifest!.members.length,
      isAdmin: _cachedManifest!.owner.userId == userId,
      fekGeneration: _cachedManifest!.fekGeneration,
      ownerEmail: _cachedManifest!.owner.email,
      members: _cachedManifest!.members.values.toList(),
    );
  }

  // --- C3: Apply remote operations to local database ---

  Future<void> _applyOperations(List<SyncOperation> ops) async {
    for (final op in ops) {
      // Skip snapshot restore markers — handled by caller
      if (op.table == '_snapshot_restore') continue;

      switch (op.op) {
        case OpType.insert:
        case OpType.update:
          await _upsertEntity(op.table, op.id, op.data ?? {});
        case OpType.delete:
          await _deleteEntity(op.table, op.id);
      }
    }
  }

  Future<void> _upsertEntity(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    switch (table) {
      case 'accounts':
        await db
            .into(db.accounts)
            .insertOnConflictUpdate(
              AccountsCompanion(
                id: Value(id),
                name: Value(data['name'] as String? ?? ''),
                type: Value(data['type'] as String? ?? 'savings'),
                balance: Value(data['balance'] as int? ?? 0),
                currency: Value(data['currency'] as String? ?? 'INR'),
                visibility: Value(data['visibility'] as String? ?? 'shared'),
                familyId: Value(data['family_id'] as String? ?? familyId),
                userId: Value(data['user_id'] as String? ?? ''),
              ),
            );
      case 'transactions':
        await db
            .into(db.transactions)
            .insertOnConflictUpdate(
              TransactionsCompanion(
                id: Value(id),
                amount: Value(data['amount'] as int? ?? 0),
                date: Value(
                  DateTime.tryParse(data['date'] as String? ?? '') ??
                      DateTime.now(),
                ),
                description: Value(data['description'] as String?),
                accountId: Value(data['account_id'] as String? ?? ''),
                kind: Value(data['kind'] as String? ?? 'expense'),
                familyId: Value(data['family_id'] as String? ?? familyId),
              ),
            );
      case 'budgets':
        await db
            .into(db.budgets)
            .insertOnConflictUpdate(
              BudgetsCompanion(
                id: Value(id),
                familyId: Value(data['family_id'] as String? ?? familyId),
                year: Value(data['year'] as int? ?? DateTime.now().year),
                month: Value(data['month'] as int? ?? DateTime.now().month),
                categoryGroup: Value(data['category_group'] as String? ?? ''),
                limitAmount: Value(data['limit_amount'] as int? ?? 0),
              ),
            );
      case 'goals':
        await db
            .into(db.goals)
            .insertOnConflictUpdate(
              GoalsCompanion(
                id: Value(id),
                name: Value(data['name'] as String? ?? ''),
                targetAmount: Value(data['target_amount'] as int? ?? 0),
                targetDate: Value(
                  DateTime.tryParse(data['target_date'] as String? ?? '') ??
                      DateTime.now(),
                ),
                currentSavings: Value(data['current_savings'] as int? ?? 0),
                inflationRate: Value(data['inflation_rate'] as double? ?? 0.06),
                priority: Value(data['priority'] as int? ?? 1),
                status: Value(data['status'] as String? ?? 'active'),
                familyId: Value(data['family_id'] as String? ?? familyId),
                createdAt: Value(
                  DateTime.tryParse(data['created_at'] as String? ?? '') ??
                      DateTime.now(),
                ),
              ),
            );
      // Additional tables can be added as needed
    }
  }

  Future<void> _deleteEntity(String table, String id) async {
    switch (table) {
      case 'accounts':
        // Soft delete
        await (db.update(db.accounts)..where((a) => a.id.equals(id))).write(
          AccountsCompanion(deletedAt: Value(DateTime.now())),
        );
      case 'transactions':
        await (db.update(db.transactions)..where((t) => t.id.equals(id))).write(
          TransactionsCompanion(deletedAt: Value(DateTime.now())),
        );
      case 'budgets':
        await (db.delete(db.budgets)..where((b) => b.id.equals(id))).go();
      case 'goals':
        await (db.delete(db.goals)..where((g) => g.id.equals(id))).go();
    }
  }

  // --- Private helpers ---

  Future<void> _loadManifest() async {
    final json = await cloudStorage.readManifest();
    if (json == null) return;

    if (ManifestV2.isV2(json)) {
      _cachedManifest = ManifestV2.fromJson(json);
      _lastKnownFekGeneration = _cachedManifest!.fekGeneration;
    } else if (isAdmin && userId != null && userEmail != null) {
      // V1 → V2 migration (admin only)
      final migrated = ManifestV2.migrateFromV1(
        v1: json,
        adminUserId: userId!,
        adminEmail: userEmail!,
      );
      await cloudStorage.writeManifest(migrated.toJson());
      _cachedManifest = migrated;
      _lastKnownFekGeneration = migrated.fekGeneration;
    }
  }

  Future<void> _updateLastSyncAt() async {
    if (_cachedManifest == null || userId == null) return;
    final member = _cachedManifest!.members[userId];
    if (member == null) return;

    final now = DateTime.now().toUtc();
    final updated = ManifestV2(
      familyId: _cachedManifest!.familyId,
      owner: _cachedManifest!.owner,
      members: {
        ..._cachedManifest!.members,
        userId!: member.copyWith(lastSyncAt: now),
      },
      fekGeneration: _cachedManifest!.fekGeneration,
      lastUpdated: now,
    );
    await cloudStorage.writeManifest(updated.toJson());
    _cachedManifest = updated;
  }

  Future<Uint8List> _requireFek() async {
    final fek = await keyStorage.getFek(familyId);
    if (fek == null) throw StateError('No FEK stored for family $familyId');
    return fek;
  }
}
