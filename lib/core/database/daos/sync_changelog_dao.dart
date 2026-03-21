import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/sync_changelog.dart';

part 'sync_changelog_dao.g.dart';

@DriftAccessor(tables: [SyncChangelog])
class SyncChangelogDao extends DatabaseAccessor<AppDatabase>
    with _$SyncChangelogDaoMixin {
  SyncChangelogDao(super.db);

  Future<void> insertEntry({
    required String entityType,
    required String entityId,
    required String operation,
    required String payload,
    required DateTime timestamp,
  }) {
    return into(syncChangelog).insert(SyncChangelogCompanion.insert(
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      payload: payload,
      timestamp: timestamp,
    ));
  }

  Future<List<SyncChangelogData>> getUnsyncedEntries() {
    return (select(syncChangelog)
          ..where((t) => t.synced.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
        .get();
  }

  Future<List<SyncChangelogData>> getAllEntries() {
    return (select(syncChangelog)
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
        .get();
  }

  Future<void> markSynced(List<int> ids, String changesetId) {
    return (update(syncChangelog)..where((t) => t.id.isIn(ids))).write(
      SyncChangelogCompanion(
        synced: const Value(true),
        changesetId: Value(changesetId),
      ),
    );
  }

  Future<void> deleteOlderThan(DateTime cutoff) {
    return (delete(syncChangelog)
          ..where(
              (t) => t.synced.equals(true) & t.timestamp.isSmallerThanValue(cutoff)))
        .go();
  }
}
