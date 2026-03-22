import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/database/daos/audit_log_dao.dart';

void main() {
  late AppDatabase db;
  late AuditLogDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = AuditLogDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> _seedFamily(String familyId) async {
    await db
        .into(db.families)
        .insert(
          FamiliesCompanion.insert(
            id: familyId,
            name: 'Family $familyId',
            createdAt: DateTime(2025),
          ),
        );
  }

  group('AuditLogDao', () {
    test('insertEntry creates a row', () async {
      await _seedFamily('fam-1');

      final id = await dao.insertEntry(
        AuditLogCompanion.insert(
          id: 'log-1',
          entityType: 'account',
          entityId: 'acc-1',
          action: 'create',
          actorUserId: 'user-1',
          createdAt: DateTime(2025, 3, 15, 10, 0),
          familyId: 'fam-1',
        ),
      );

      expect(id, isNonZero);

      final rows = await db.select(db.auditLog).get();
      expect(rows, hasLength(1));
      expect(rows.first.id, 'log-1');
      expect(rows.first.entityType, 'account');
      expect(rows.first.action, 'create');
    });

    test('getByFamily returns entries for the correct family', () async {
      await _seedFamily('fam-1');
      await _seedFamily('fam-2');

      await dao.insertEntry(
        AuditLogCompanion.insert(
          id: 'log-1',
          entityType: 'account',
          entityId: 'acc-1',
          action: 'create',
          actorUserId: 'user-1',
          createdAt: DateTime(2025, 3, 15, 10, 0),
          familyId: 'fam-1',
        ),
      );
      await dao.insertEntry(
        AuditLogCompanion.insert(
          id: 'log-2',
          entityType: 'transaction',
          entityId: 'txn-1',
          action: 'update',
          actorUserId: 'user-1',
          createdAt: DateTime(2025, 3, 15, 11, 0),
          familyId: 'fam-1',
        ),
      );
      await dao.insertEntry(
        AuditLogCompanion.insert(
          id: 'log-3',
          entityType: 'account',
          entityId: 'acc-2',
          action: 'create',
          actorUserId: 'user-2',
          createdAt: DateTime(2025, 3, 15, 12, 0),
          familyId: 'fam-2',
        ),
      );

      final fam1Entries = await dao.getByFamily('fam-1');
      expect(fam1Entries, hasLength(2));
      // Newest first
      expect(fam1Entries.first.id, 'log-2');
      expect(fam1Entries.last.id, 'log-1');

      final fam2Entries = await dao.getByFamily('fam-2');
      expect(fam2Entries, hasLength(1));
      expect(fam2Entries.first.id, 'log-3');
    });

    test('getByEntity filters by entityType and entityId', () async {
      await _seedFamily('fam-1');

      await dao.insertEntry(
        AuditLogCompanion.insert(
          id: 'log-1',
          entityType: 'account',
          entityId: 'acc-1',
          action: 'create',
          actorUserId: 'user-1',
          createdAt: DateTime(2025, 3, 15, 10, 0),
          familyId: 'fam-1',
        ),
      );
      await dao.insertEntry(
        AuditLogCompanion.insert(
          id: 'log-2',
          entityType: 'account',
          entityId: 'acc-1',
          action: 'update',
          actorUserId: 'user-1',
          createdAt: DateTime(2025, 3, 15, 11, 0),
          familyId: 'fam-1',
        ),
      );
      await dao.insertEntry(
        AuditLogCompanion.insert(
          id: 'log-3',
          entityType: 'transaction',
          entityId: 'txn-1',
          action: 'create',
          actorUserId: 'user-1',
          createdAt: DateTime(2025, 3, 15, 12, 0),
          familyId: 'fam-1',
        ),
      );

      final accountEntries = await dao.getByEntity('account', 'acc-1');
      expect(accountEntries, hasLength(2));
      expect(accountEntries.every((e) => e.entityType == 'account'), isTrue);
      expect(accountEntries.every((e) => e.entityId == 'acc-1'), isTrue);

      final txnEntries = await dao.getByEntity('transaction', 'txn-1');
      expect(txnEntries, hasLength(1));
      expect(txnEntries.first.id, 'log-3');
    });

    test('countByFamily returns correct count', () async {
      await _seedFamily('fam-1');
      await _seedFamily('fam-2');

      // Insert 3 entries for fam-1
      for (var i = 1; i <= 3; i++) {
        await dao.insertEntry(
          AuditLogCompanion.insert(
            id: 'log-$i',
            entityType: 'account',
            entityId: 'acc-$i',
            action: 'create',
            actorUserId: 'user-1',
            createdAt: DateTime(2025, 3, 15, i),
            familyId: 'fam-1',
          ),
        );
      }

      // Insert 1 entry for fam-2
      await dao.insertEntry(
        AuditLogCompanion.insert(
          id: 'log-4',
          entityType: 'account',
          entityId: 'acc-4',
          action: 'create',
          actorUserId: 'user-2',
          createdAt: DateTime(2025, 3, 15, 14),
          familyId: 'fam-2',
        ),
      );

      expect(await dao.countByFamily('fam-1'), 3);
      expect(await dao.countByFamily('fam-2'), 1);
      expect(await dao.countByFamily('fam-nonexistent'), 0);
    });
  });
}
