import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/database/daos/account_dao.dart';
import 'package:vael/core/database/daos/balance_snapshot_dao.dart';
import 'package:vael/core/financial/balance_snapshot_scheduler.dart';

void main() {
  late AppDatabase db;
  late AccountDao accountDao;
  late BalanceSnapshotDao snapshotDao;
  late BalanceSnapshotScheduler scheduler;

  const familyId = 'fam-1';
  const userId = 'user-1';

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    accountDao = AccountDao(db);
    snapshotDao = BalanceSnapshotDao(db);
    scheduler = BalanceSnapshotScheduler(
      accountDao: accountDao,
      snapshotDao: snapshotDao,
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> _seedFamilyAndUser() async {
    await db
        .into(db.families)
        .insert(
          FamiliesCompanion.insert(
            id: familyId,
            name: 'Test Family',
            createdAt: DateTime(2025),
          ),
        );
    await db
        .into(db.users)
        .insert(
          UsersCompanion.insert(
            id: userId,
            email: 'test@test.com',
            displayName: 'Test',
            role: 'admin',
            familyId: familyId,
          ),
        );
  }

  Future<void> _insertAccount({
    required String id,
    required int balance,
    DateTime? deletedAt,
  }) async {
    await db
        .into(db.accounts)
        .insert(
          AccountsCompanion(
            id: Value(id),
            name: Value('Account $id'),
            type: const Value('savings'),
            balance: Value(balance),
            visibility: const Value('shared'),
            familyId: const Value(familyId),
            userId: const Value(userId),
            deletedAt: Value(deletedAt),
          ),
        );
  }

  group('BalanceSnapshotScheduler', () {
    test('createDailySnapshots creates one snapshot per account', () async {
      await _seedFamilyAndUser();
      await _insertAccount(id: 'acc-1', balance: 1000000);
      await _insertAccount(id: 'acc-2', balance: 2000000);

      final count = await scheduler.createDailySnapshots(familyId);

      expect(count, 2);

      final snapshots = await db.select(db.balanceSnapshots).get();
      expect(snapshots, hasLength(2));

      final accountIds = snapshots.map((s) => s.accountId).toSet();
      expect(accountIds, containsAll(['acc-1', 'acc-2']));

      // Verify balances match
      final acc1Snap = snapshots.firstWhere((s) => s.accountId == 'acc-1');
      expect(acc1Snap.balance, 1000000);
      final acc2Snap = snapshots.firstWhere((s) => s.accountId == 'acc-2');
      expect(acc2Snap.balance, 2000000);
    });

    test(
      'does not create duplicates if called twice on the same day',
      () async {
        await _seedFamilyAndUser();
        await _insertAccount(id: 'acc-1', balance: 1000000);

        final firstCount = await scheduler.createDailySnapshots(familyId);
        expect(firstCount, 1);

        final secondCount = await scheduler.createDailySnapshots(familyId);
        expect(secondCount, 0);

        final snapshots = await db.select(db.balanceSnapshots).get();
        expect(snapshots, hasLength(1));
      },
    );

    test('returns the count of snapshots created', () async {
      await _seedFamilyAndUser();
      await _insertAccount(id: 'acc-1', balance: 500000);
      await _insertAccount(id: 'acc-2', balance: 750000);
      await _insertAccount(id: 'acc-3', balance: 100000);

      final count = await scheduler.createDailySnapshots(familyId);
      expect(count, 3);
    });

    test('skips soft-deleted accounts', () async {
      await _seedFamilyAndUser();
      await _insertAccount(id: 'acc-1', balance: 1000000);
      await _insertAccount(
        id: 'acc-2',
        balance: 2000000,
        deletedAt: DateTime(2025, 1, 1),
      );

      final count = await scheduler.createDailySnapshots(familyId);

      // Only acc-1 should be snapshotted; acc-2 is soft-deleted
      // Note: getAll already filters out deleted, so scheduler sees only acc-1
      expect(count, 1);

      final snapshots = await db.select(db.balanceSnapshots).get();
      expect(snapshots, hasLength(1));
      expect(snapshots.first.accountId, 'acc-1');
    });
  });
}
