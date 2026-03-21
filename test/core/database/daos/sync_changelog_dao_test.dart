import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/database/daos/sync_changelog_dao.dart';

void main() {
  late AppDatabase db;
  late SyncChangelogDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = SyncChangelogDao(db);
  });

  tearDown(() => db.close());

  group('SyncChangelogDao', () {
    test('inserts changelog entry and retrieves it', () async {
      await dao.insertEntry(
        entityType: 'transactions',
        entityId: 'txn-001',
        operation: 'INSERT',
        payload: '{"amount":15000}',
        timestamp: DateTime.utc(2026, 3, 20, 10, 30),
      );

      final entries = await dao.getUnsyncedEntries();
      expect(entries, hasLength(1));
      expect(entries.first.entityType, 'transactions');
      expect(entries.first.entityId, 'txn-001');
      expect(entries.first.operation, 'INSERT');
      expect(entries.first.payload, '{"amount":15000}');
      expect(entries.first.synced, false);
    });

    test('getUnsyncedEntries returns only unsynced entries', () async {
      await dao.insertEntry(
        entityType: 'accounts',
        entityId: 'acc-001',
        operation: 'INSERT',
        payload: '{}',
        timestamp: DateTime.utc(2026, 3, 20, 10, 0),
      );
      await dao.insertEntry(
        entityType: 'accounts',
        entityId: 'acc-002',
        operation: 'INSERT',
        payload: '{}',
        timestamp: DateTime.utc(2026, 3, 20, 10, 1),
      );

      // Mark first as synced
      final all = await dao.getUnsyncedEntries();
      await dao.markSynced([all.first.id], 'changeset-001');

      final unsynced = await dao.getUnsyncedEntries();
      expect(unsynced, hasLength(1));
      expect(unsynced.first.entityId, 'acc-002');
    });

    test('markSynced sets synced flag and changeset_id', () async {
      await dao.insertEntry(
        entityType: 'transactions',
        entityId: 'txn-001',
        operation: 'UPDATE',
        payload: '{"amount":20000}',
        timestamp: DateTime.utc(2026, 3, 20, 11, 0),
      );

      final entries = await dao.getUnsyncedEntries();
      await dao.markSynced([entries.first.id], 'cs-42');

      final allEntries = await dao.getAllEntries();
      expect(allEntries.first.synced, true);
      expect(allEntries.first.changesetId, 'cs-42');
    });

    test('entries are ordered by timestamp', () async {
      await dao.insertEntry(
        entityType: 'transactions',
        entityId: 'txn-002',
        operation: 'INSERT',
        payload: '{}',
        timestamp: DateTime.utc(2026, 3, 20, 12, 0),
      );
      await dao.insertEntry(
        entityType: 'transactions',
        entityId: 'txn-001',
        operation: 'INSERT',
        payload: '{}',
        timestamp: DateTime.utc(2026, 3, 20, 10, 0),
      );

      final entries = await dao.getUnsyncedEntries();
      expect(entries[0].entityId, 'txn-001'); // Earlier timestamp first
      expect(entries[1].entityId, 'txn-002');
    });

    test('supports INSERT, UPDATE, DELETE operations', () async {
      for (final op in ['INSERT', 'UPDATE', 'DELETE']) {
        await dao.insertEntry(
          entityType: 'accounts',
          entityId: 'acc-$op',
          operation: op,
          payload: '{}',
          timestamp: DateTime.utc(2026, 3, 20),
        );
      }

      final entries = await dao.getAllEntries();
      expect(entries.map((e) => e.operation).toSet(), {
        'INSERT',
        'UPDATE',
        'DELETE',
      });
    });

    test('deleteOlderThan removes synced entries before cutoff', () async {
      await dao.insertEntry(
        entityType: 'accounts',
        entityId: 'acc-old',
        operation: 'INSERT',
        payload: '{}',
        timestamp: DateTime.utc(2026, 1, 1),
      );
      await dao.insertEntry(
        entityType: 'accounts',
        entityId: 'acc-new',
        operation: 'INSERT',
        payload: '{}',
        timestamp: DateTime.utc(2026, 3, 20),
      );

      // Mark old one as synced
      final entries = await dao.getUnsyncedEntries();
      final oldEntry = entries.firstWhere((e) => e.entityId == 'acc-old');
      await dao.markSynced([oldEntry.id], 'cs-1');

      // Delete synced entries older than Feb 1
      await dao.deleteOlderThan(DateTime.utc(2026, 2, 1));

      final remaining = await dao.getAllEntries();
      expect(remaining, hasLength(1));
      expect(remaining.first.entityId, 'acc-new');
    });
  });
}
