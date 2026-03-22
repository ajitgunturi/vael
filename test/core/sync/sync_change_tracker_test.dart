import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/database/daos/sync_changelog_dao.dart';
import 'package:vael/core/sync/sync_change_tracker.dart';

void main() {
  late AppDatabase db;
  late SyncChangelogDao changelogDao;
  late SyncChangeTracker tracker;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    changelogDao = SyncChangelogDao(db);
    tracker = SyncChangeTracker(changelogDao: changelogDao);
  });

  tearDown(() async {
    await db.close();
  });

  group('SyncChangeTracker', () {
    test('trackInsert creates an entry with operation INSERT', () async {
      await tracker.trackInsert(
        entityType: 'accounts',
        entityId: 'acc-1',
        data: {'name': 'HDFC Savings', 'balance': 1000000},
      );

      final entries = await changelogDao.getUnsyncedEntries();
      expect(entries, hasLength(1));
      expect(entries.first.entityType, 'accounts');
      expect(entries.first.entityId, 'acc-1');
      expect(entries.first.operation, 'INSERT');
      expect(entries.first.synced, false);
      expect(entries.first.payload, contains('HDFC Savings'));
    });

    test('trackUpdate creates an entry with operation UPDATE', () async {
      await tracker.trackUpdate(
        entityType: 'accounts',
        entityId: 'acc-1',
        data: {'balance': 2000000},
      );

      final entries = await changelogDao.getUnsyncedEntries();
      expect(entries, hasLength(1));
      expect(entries.first.operation, 'UPDATE');
      expect(entries.first.entityId, 'acc-1');
      expect(entries.first.payload, contains('2000000'));
    });

    test('trackDelete creates an entry with operation DELETE', () async {
      await tracker.trackDelete(entityType: 'transactions', entityId: 'txn-42');

      final entries = await changelogDao.getUnsyncedEntries();
      expect(entries, hasLength(1));
      expect(entries.first.operation, 'DELETE');
      expect(entries.first.entityType, 'transactions');
      expect(entries.first.entityId, 'txn-42');
      expect(entries.first.payload, '{}');
    });

    test('entries are retrievable via getUnsyncedEntries', () async {
      await tracker.trackInsert(
        entityType: 'accounts',
        entityId: 'acc-1',
        data: {'name': 'Account 1'},
      );
      await tracker.trackUpdate(
        entityType: 'accounts',
        entityId: 'acc-1',
        data: {'balance': 500},
      );
      await tracker.trackDelete(entityType: 'transactions', entityId: 'txn-1');

      final entries = await changelogDao.getUnsyncedEntries();
      expect(entries, hasLength(3));

      final operations = entries.map((e) => e.operation).toList();
      expect(operations, containsAll(['INSERT', 'UPDATE', 'DELETE']));

      // All should be unsynced
      expect(entries.every((e) => e.synced == false), isTrue);
    });
  });
}
