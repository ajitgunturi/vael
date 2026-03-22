import 'dart:convert';

import '../database/daos/sync_changelog_dao.dart';

/// Automatically records entity changes to [SyncChangelog] for sync push.
///
/// Every local write (insert/update/delete) must call the corresponding
/// method here so the sync engine knows what to push to cloud storage.
class SyncChangeTracker {
  final SyncChangelogDao _changelogDao;

  SyncChangeTracker({required SyncChangelogDao changelogDao})
    : _changelogDao = changelogDao;

  /// Records an INSERT operation.
  Future<void> trackInsert({
    required String entityType,
    required String entityId,
    required Map<String, dynamic> data,
  }) {
    return _changelogDao.insertEntry(
      entityType: entityType,
      entityId: entityId,
      operation: 'INSERT',
      payload: jsonEncode(data),
      timestamp: DateTime.now().toUtc(),
    );
  }

  /// Records an UPDATE operation.
  Future<void> trackUpdate({
    required String entityType,
    required String entityId,
    required Map<String, dynamic> data,
  }) {
    return _changelogDao.insertEntry(
      entityType: entityType,
      entityId: entityId,
      operation: 'UPDATE',
      payload: jsonEncode(data),
      timestamp: DateTime.now().toUtc(),
    );
  }

  /// Records a DELETE operation.
  Future<void> trackDelete({
    required String entityType,
    required String entityId,
  }) {
    return _changelogDao.insertEntry(
      entityType: entityType,
      entityId: entityId,
      operation: 'DELETE',
      payload: '{}',
      timestamp: DateTime.now().toUtc(),
    );
  }
}
