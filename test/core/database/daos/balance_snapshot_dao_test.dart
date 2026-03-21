import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/database/daos/balance_snapshot_dao.dart';

void main() {
  late AppDatabase db;
  late BalanceSnapshotDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = BalanceSnapshotDao(db);
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
    await db
        .into(db.users)
        .insert(
          UsersCompanion.insert(
            id: 'user_$familyId',
            email: '$familyId@test.com',
            displayName: 'User $familyId',
            role: 'admin',
            familyId: familyId,
          ),
        );
  }

  Future<void> _insertAccount(
    String id,
    String familyId, {
    String type = 'savings',
  }) async {
    await db
        .into(db.accounts)
        .insert(
          AccountsCompanion(
            id: Value(id),
            name: Value('Account $id'),
            type: Value(type),
            balance: const Value(0),
            visibility: const Value('shared'),
            familyId: Value(familyId),
            userId: Value('user_$familyId'),
          ),
        );
  }

  group('BalanceSnapshotDao', () {
    test(
      'insertSnapshot and getByAccount returns snapshots ordered by date',
      () async {
        await _seedFamily('fam_a');
        await _insertAccount('acc_1', 'fam_a');

        await dao.insertSnapshot(
          BalanceSnapshotsCompanion.insert(
            id: 'snap_1',
            accountId: 'acc_1',
            snapshotDate: DateTime(2025, 3, 1),
            balance: 500000,
            familyId: 'fam_a',
          ),
        );
        await dao.insertSnapshot(
          BalanceSnapshotsCompanion.insert(
            id: 'snap_2',
            accountId: 'acc_1',
            snapshotDate: DateTime(2025, 1, 1),
            balance: 300000,
            familyId: 'fam_a',
          ),
        );

        final result = await dao.getByAccount('acc_1');
        expect(result.length, 2);
        expect(result[0].snapshotDate.isBefore(result[1].snapshotDate), isTrue);
        expect(result[0].balance, 300000);
        expect(result[1].balance, 500000);
      },
    );

    test('getByFamilyDateRange filters by date range', () async {
      await _seedFamily('fam_a');
      await _insertAccount('acc_1', 'fam_a');

      await dao.insertSnapshot(
        BalanceSnapshotsCompanion.insert(
          id: 'snap_1',
          accountId: 'acc_1',
          snapshotDate: DateTime(2025, 1, 15),
          balance: 100000,
          familyId: 'fam_a',
        ),
      );
      await dao.insertSnapshot(
        BalanceSnapshotsCompanion.insert(
          id: 'snap_2',
          accountId: 'acc_1',
          snapshotDate: DateTime(2025, 2, 15),
          balance: 200000,
          familyId: 'fam_a',
        ),
      );
      await dao.insertSnapshot(
        BalanceSnapshotsCompanion.insert(
          id: 'snap_3',
          accountId: 'acc_1',
          snapshotDate: DateTime(2025, 3, 15),
          balance: 300000,
          familyId: 'fam_a',
        ),
      );

      final result = await dao.getByFamilyDateRange(
        'fam_a',
        DateTime(2025, 2, 1),
        DateTime(2025, 2, 28),
      );
      expect(result.length, 1);
      expect(result[0].balance, 200000);
    });

    test('family isolation — snapshots from other families excluded', () async {
      await _seedFamily('fam_a');
      await _seedFamily('fam_b');
      await _insertAccount('acc_a', 'fam_a');
      await _insertAccount('acc_b', 'fam_b');

      await dao.insertSnapshot(
        BalanceSnapshotsCompanion.insert(
          id: 'snap_a',
          accountId: 'acc_a',
          snapshotDate: DateTime(2025, 1, 1),
          balance: 100000,
          familyId: 'fam_a',
        ),
      );
      await dao.insertSnapshot(
        BalanceSnapshotsCompanion.insert(
          id: 'snap_b',
          accountId: 'acc_b',
          snapshotDate: DateTime(2025, 1, 1),
          balance: 999999,
          familyId: 'fam_b',
        ),
      );

      final resultA = await dao.getByFamilyDateRange(
        'fam_a',
        DateTime(2025, 1, 1),
        DateTime(2025, 12, 31),
      );
      expect(resultA.length, 1);
      expect(resultA[0].balance, 100000);
    });
  });
}
