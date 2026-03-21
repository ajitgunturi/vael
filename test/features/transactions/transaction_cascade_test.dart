import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/database/daos/account_dao.dart';
import 'package:vael/core/database/daos/transaction_dao.dart';
import 'package:vael/core/financial/balance_rules.dart';

/// Tests the full cascade: create/edit/delete transaction → balance updates.
void main() {
  late AppDatabase db;
  late AccountDao accountDao;
  late TransactionDao txnDao;
  late BalanceService balanceService;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    accountDao = AccountDao(db);
    txnDao = TransactionDao(db);
    balanceService = BalanceService(db);
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
            name: 'Family',
            createdAt: DateTime(2025),
          ),
        );
    await db
        .into(db.users)
        .insert(
          UsersCompanion.insert(
            id: 'user_$familyId',
            email: '$familyId@test.com',
            displayName: 'User',
            role: 'admin',
            familyId: familyId,
          ),
        );
  }

  Future<void> _insertAccount({
    required String id,
    required String familyId,
    int balance = 0,
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
            familyId: Value(familyId),
            userId: Value('user_$familyId'),
          ),
        );
  }

  group('Transaction → Balance Cascade', () {
    test('expense creation reduces account balance', () async {
      await _seedFamily('fam_a');
      await _insertAccount(id: 'acc_1', familyId: 'fam_a', balance: 1000000);

      await txnDao.insertTransaction(
        TransactionsCompanion(
          id: const Value('tx1'),
          amount: const Value(200000),
          date: Value(DateTime(2025, 3, 1)),
          kind: const Value('expense'),
          accountId: const Value('acc_1'),
          familyId: const Value('fam_a'),
        ),
      );
      await balanceService.applyTransaction(
        kind: 'expense',
        amount: 200000,
        fromAccountId: 'acc_1',
      );

      final acc = await accountDao.getById('acc_1', 'fam_a');
      expect(acc!.balance, 800000);
    });

    test('salary creation increases account balance', () async {
      await _seedFamily('fam_a');
      await _insertAccount(id: 'acc_1', familyId: 'fam_a', balance: 500000);

      await txnDao.insertTransaction(
        TransactionsCompanion(
          id: const Value('tx1'),
          amount: const Value(5000000),
          date: Value(DateTime(2025, 3, 1)),
          kind: const Value('salary'),
          accountId: const Value('acc_1'),
          familyId: const Value('fam_a'),
        ),
      );
      await balanceService.applyTransaction(
        kind: 'salary',
        amount: 5000000,
        fromAccountId: 'acc_1',
      );

      final acc = await accountDao.getById('acc_1', 'fam_a');
      expect(acc!.balance, 5500000);
    });

    test('transfer debits source and credits destination', () async {
      await _seedFamily('fam_a');
      await _insertAccount(id: 'acc_1', familyId: 'fam_a', balance: 1000000);
      await _insertAccount(id: 'acc_2', familyId: 'fam_a', balance: 200000);

      await txnDao.insertTransaction(
        TransactionsCompanion(
          id: const Value('tx1'),
          amount: const Value(300000),
          date: Value(DateTime(2025, 3, 1)),
          kind: const Value('transfer'),
          accountId: const Value('acc_1'),
          toAccountId: const Value('acc_2'),
          familyId: const Value('fam_a'),
        ),
      );
      await balanceService.applyTransaction(
        kind: 'transfer',
        amount: 300000,
        fromAccountId: 'acc_1',
        toAccountId: 'acc_2',
      );

      final source = await accountDao.getById('acc_1', 'fam_a');
      final dest = await accountDao.getById('acc_2', 'fam_a');
      expect(source!.balance, 700000); // 1000000 - 300000
      expect(dest!.balance, 500000); // 200000 + 300000
    });

    test('multiple transactions accumulate correctly', () async {
      await _seedFamily('fam_a');
      await _insertAccount(id: 'acc_1', familyId: 'fam_a', balance: 0);

      // Salary: +50,000
      await balanceService.applyTransaction(
        kind: 'salary',
        amount: 5000000,
        fromAccountId: 'acc_1',
      );
      // Expense: -15,000
      await balanceService.applyTransaction(
        kind: 'expense',
        amount: 1500000,
        fromAccountId: 'acc_1',
      );
      // EMI: -10,000
      await balanceService.applyTransaction(
        kind: 'emiPayment',
        amount: 1000000,
        fromAccountId: 'acc_1',
      );

      final acc = await accountDao.getById('acc_1', 'fam_a');
      // 0 + 5000000 - 1500000 - 1000000 = 2500000
      expect(acc!.balance, 2500000);
    });

    test('self-transfer is a no-op', () async {
      await _seedFamily('fam_a');
      await _insertAccount(id: 'acc_1', familyId: 'fam_a', balance: 500000);

      await balanceService.applyTransaction(
        kind: 'transfer',
        amount: 100000,
        fromAccountId: 'acc_1',
        toAccountId: 'acc_1',
      );

      final acc = await accountDao.getById('acc_1', 'fam_a');
      expect(acc!.balance, 500000); // unchanged
    });

    test('dividend adds to account balance', () async {
      await _seedFamily('fam_a');
      await _insertAccount(id: 'acc_1', familyId: 'fam_a', balance: 1000000);

      await balanceService.applyTransaction(
        kind: 'dividend',
        amount: 50000,
        fromAccountId: 'acc_1',
      );

      final acc = await accountDao.getById('acc_1', 'fam_a');
      expect(acc!.balance, 1050000);
    });

    test('insurance premium deducts from account balance', () async {
      await _seedFamily('fam_a');
      await _insertAccount(id: 'acc_1', familyId: 'fam_a', balance: 1000000);

      await balanceService.applyTransaction(
        kind: 'insurancePremium',
        amount: 250000,
        fromAccountId: 'acc_1',
      );

      final acc = await accountDao.getById('acc_1', 'fam_a');
      expect(acc!.balance, 750000);
    });
  });
}
