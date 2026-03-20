import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/database/daos/transaction_dao.dart';

void main() {
  late AppDatabase db;
  late TransactionDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = TransactionDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> _seedFamily(String familyId) async {
    await db.into(db.families).insert(FamiliesCompanion.insert(
          id: familyId,
          name: 'Family $familyId',
          createdAt: DateTime(2025),
        ));
    await db.into(db.users).insert(UsersCompanion.insert(
          id: 'user_$familyId',
          email: '$familyId@test.com',
          displayName: 'User $familyId',
          role: 'admin',
          familyId: familyId,
        ));
    await db.into(db.accounts).insert(AccountsCompanion(
          id: Value('acc_$familyId'),
          name: Value('Account $familyId'),
          type: const Value('savings'),
          balance: const Value(0),
          visibility: const Value('shared'),
          familyId: Value(familyId),
          userId: Value('user_$familyId'),
        ));
  }

  Future<void> _insertTx({
    required String id,
    required String familyId,
    required DateTime date,
    String kind = 'expense',
    int amount = 10000,
    String? accountId,
  }) async {
    await db.into(db.transactions).insert(TransactionsCompanion(
          id: Value(id),
          amount: Value(amount),
          date: Value(date),
          kind: Value(kind),
          familyId: Value(familyId),
          accountId: Value(accountId ?? 'acc_$familyId'),
        ));
  }

  group('TransactionDao', () {
    test('getAll returns only transactions for the given family', () async {
      await _seedFamily('fam_a');
      await _seedFamily('fam_b');

      await _insertTx(
          id: 'tx_1', familyId: 'fam_a', date: DateTime(2025, 3, 1));
      await _insertTx(
          id: 'tx_2', familyId: 'fam_a', date: DateTime(2025, 3, 2));
      await _insertTx(
          id: 'tx_3', familyId: 'fam_b', date: DateTime(2025, 3, 1));

      final results = await dao.getAll('fam_a');

      expect(results, hasLength(2));
      expect(results.map((t) => t.id), containsAll(['tx_1', 'tx_2']));
    });

    test('getByDateRange returns transactions within the date window',
        () async {
      await _seedFamily('fam_a');

      await _insertTx(
          id: 'tx_1', familyId: 'fam_a', date: DateTime(2025, 1, 15));
      await _insertTx(
          id: 'tx_2', familyId: 'fam_a', date: DateTime(2025, 3, 10));
      await _insertTx(
          id: 'tx_3', familyId: 'fam_a', date: DateTime(2025, 5, 20));

      final results = await dao.getByDateRange(
        'fam_a',
        DateTime(2025, 3, 1),
        DateTime(2025, 3, 31),
      );

      expect(results, hasLength(1));
      expect(results.first.id, 'tx_2');
    });

    test('getByDateRange is inclusive on both bounds', () async {
      await _seedFamily('fam_a');

      await _insertTx(
          id: 'tx_1', familyId: 'fam_a', date: DateTime(2025, 3, 1));
      await _insertTx(
          id: 'tx_2', familyId: 'fam_a', date: DateTime(2025, 3, 31));

      final results = await dao.getByDateRange(
        'fam_a',
        DateTime(2025, 3, 1),
        DateTime(2025, 3, 31),
      );

      expect(results, hasLength(2));
    });

    test('getByKind filters by transaction kind', () async {
      await _seedFamily('fam_a');

      await _insertTx(
          id: 'tx_1',
          familyId: 'fam_a',
          date: DateTime(2025, 3, 1),
          kind: 'expense');
      await _insertTx(
          id: 'tx_2',
          familyId: 'fam_a',
          date: DateTime(2025, 3, 2),
          kind: 'income');
      await _insertTx(
          id: 'tx_3',
          familyId: 'fam_a',
          date: DateTime(2025, 3, 3),
          kind: 'expense');

      final results = await dao.getByKind('fam_a', 'expense');

      expect(results, hasLength(2));
      expect(results.every((t) => t.kind == 'expense'), isTrue);
    });

    test('getByAccount filters by account within the family', () async {
      await _seedFamily('fam_a');

      // Create a second account in the same family
      await db.into(db.accounts).insert(AccountsCompanion(
            id: const Value('acc_extra'),
            name: const Value('Extra Account'),
            type: const Value('current'),
            balance: const Value(0),
            visibility: const Value('shared'),
            familyId: const Value('fam_a'),
            userId: const Value('user_fam_a'),
          ));

      await _insertTx(
          id: 'tx_1',
          familyId: 'fam_a',
          date: DateTime(2025, 3, 1),
          accountId: 'acc_fam_a');
      await _insertTx(
          id: 'tx_2',
          familyId: 'fam_a',
          date: DateTime(2025, 3, 2),
          accountId: 'acc_extra');

      final results = await dao.getByAccount('fam_a', 'acc_extra');

      expect(results, hasLength(1));
      expect(results.first.id, 'tx_2');
    });

    test('getAll returns transactions ordered by date descending', () async {
      await _seedFamily('fam_a');

      await _insertTx(
          id: 'tx_old', familyId: 'fam_a', date: DateTime(2025, 1, 1));
      await _insertTx(
          id: 'tx_mid', familyId: 'fam_a', date: DateTime(2025, 6, 1));
      await _insertTx(
          id: 'tx_new', familyId: 'fam_a', date: DateTime(2025, 12, 1));

      final results = await dao.getAll('fam_a');

      expect(results.map((t) => t.id).toList(),
          equals(['tx_new', 'tx_mid', 'tx_old']));
    });
  });
}
