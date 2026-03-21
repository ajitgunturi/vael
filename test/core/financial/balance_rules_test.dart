import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/financial/balance_rules.dart';

void main() {
  late AppDatabase db;
  late BalanceService service;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    service = BalanceService(db);
  });

  tearDown(() async {
    await db.close();
  });

  /// Seeds minimal family + user rows so foreign keys are satisfied.
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

  Future<int> _getBalance(String accountId) async {
    final row = await (db.select(
      db.accounts,
    )..where((a) => a.id.equals(accountId))).getSingle();
    return row.balance;
  }

  group('BalanceRules.computeDelta', () {
    test('income returns positive fromDelta', () {
      final result = BalanceRules.computeDelta(kind: 'income', amount: 50000);
      expect(result.fromDelta, 50000);
      expect(result.toDelta, isNull);
    });

    test('salary returns positive fromDelta', () {
      final result = BalanceRules.computeDelta(kind: 'salary', amount: 50000);
      expect(result.fromDelta, 50000);
      expect(result.toDelta, isNull);
    });

    test('dividend returns positive fromDelta', () {
      final result = BalanceRules.computeDelta(kind: 'dividend', amount: 50000);
      expect(result.fromDelta, 50000);
      expect(result.toDelta, isNull);
    });

    test('expense returns negative fromDelta', () {
      final result = BalanceRules.computeDelta(kind: 'expense', amount: 30000);
      expect(result.fromDelta, -30000);
      expect(result.toDelta, isNull);
    });

    test('emiPayment returns negative fromDelta', () {
      final result = BalanceRules.computeDelta(
        kind: 'emiPayment',
        amount: 30000,
      );
      expect(result.fromDelta, -30000);
      expect(result.toDelta, isNull);
    });

    test('insurancePremium returns negative fromDelta', () {
      final result = BalanceRules.computeDelta(
        kind: 'insurancePremium',
        amount: 30000,
      );
      expect(result.fromDelta, -30000);
      expect(result.toDelta, isNull);
    });

    test('transfer returns negative fromDelta and positive toDelta', () {
      final result = BalanceRules.computeDelta(kind: 'transfer', amount: 40000);
      expect(result.fromDelta, -40000);
      expect(result.toDelta, 40000);
    });
  });

  group('BalanceService.applyTransaction', () {
    test('should_add_income_to_from_account', () async {
      await _seedFamily('fam_a');
      await _insertAccount(id: 'acc_1', familyId: 'fam_a', balance: 0);

      await service.applyTransaction(
        kind: 'income',
        amount: 50000,
        fromAccountId: 'acc_1',
      );

      expect(await _getBalance('acc_1'), 50000);
    });

    test('should_add_salary_to_from_account', () async {
      await _seedFamily('fam_a');
      await _insertAccount(id: 'acc_1', familyId: 'fam_a', balance: 0);

      await service.applyTransaction(
        kind: 'salary',
        amount: 50000,
        fromAccountId: 'acc_1',
      );

      expect(await _getBalance('acc_1'), 50000);
    });

    test('should_add_dividend_to_from_account', () async {
      await _seedFamily('fam_a');
      await _insertAccount(id: 'acc_1', familyId: 'fam_a', balance: 0);

      await service.applyTransaction(
        kind: 'dividend',
        amount: 50000,
        fromAccountId: 'acc_1',
      );

      expect(await _getBalance('acc_1'), 50000);
    });

    test('should_subtract_expense_from_account', () async {
      await _seedFamily('fam_a');
      await _insertAccount(id: 'acc_1', familyId: 'fam_a', balance: 100000);

      await service.applyTransaction(
        kind: 'expense',
        amount: 30000,
        fromAccountId: 'acc_1',
      );

      expect(await _getBalance('acc_1'), 70000);
    });

    test('should_subtract_emi_payment_from_account', () async {
      await _seedFamily('fam_a');
      await _insertAccount(id: 'acc_1', familyId: 'fam_a', balance: 100000);

      await service.applyTransaction(
        kind: 'emiPayment',
        amount: 30000,
        fromAccountId: 'acc_1',
      );

      expect(await _getBalance('acc_1'), 70000);
    });

    test('should_subtract_insurance_premium_from_account', () async {
      await _seedFamily('fam_a');
      await _insertAccount(id: 'acc_1', familyId: 'fam_a', balance: 100000);

      await service.applyTransaction(
        kind: 'insurancePremium',
        amount: 30000,
        fromAccountId: 'acc_1',
      );

      expect(await _getBalance('acc_1'), 70000);
    });

    test('should_transfer_between_two_accounts', () async {
      await _seedFamily('fam_a');
      await _insertAccount(id: 'acc_a', familyId: 'fam_a', balance: 100000);
      await _insertAccount(id: 'acc_b', familyId: 'fam_a', balance: 0);

      await service.applyTransaction(
        kind: 'transfer',
        amount: 40000,
        fromAccountId: 'acc_a',
        toAccountId: 'acc_b',
      );

      expect(await _getBalance('acc_a'), 60000);
      expect(await _getBalance('acc_b'), 40000);
    });

    test('should_rollback_transfer_when_to_account_missing', () async {
      await _seedFamily('fam_a');
      await _insertAccount(id: 'acc_a', familyId: 'fam_a', balance: 100000);

      await expectLater(
        service.applyTransaction(
          kind: 'transfer',
          amount: 40000,
          fromAccountId: 'acc_a',
          toAccountId: 'acc_nonexistent',
        ),
        throwsA(isA<StateError>()),
      );

      // fromAccount balance must remain unchanged after rollback.
      expect(await _getBalance('acc_a'), 100000);
    });

    test('should_treat_self_transfer_as_no_op', () async {
      await _seedFamily('fam_a');
      await _insertAccount(id: 'acc_a', familyId: 'fam_a', balance: 100000);

      await service.applyTransaction(
        kind: 'transfer',
        amount: 40000,
        fromAccountId: 'acc_a',
        toAccountId: 'acc_a',
      );

      expect(await _getBalance('acc_a'), 100000);
    });

    test('should_accumulate_multiple_operations_correctly', () async {
      await _seedFamily('fam_a');
      await _insertAccount(id: 'acc_1', familyId: 'fam_a', balance: 0);

      await service.applyTransaction(
        kind: 'salary',
        amount: 50000,
        fromAccountId: 'acc_1',
      );
      await service.applyTransaction(
        kind: 'expense',
        amount: 20000,
        fromAccountId: 'acc_1',
      );
      await service.applyTransaction(
        kind: 'income',
        amount: 10000,
        fromAccountId: 'acc_1',
      );

      expect(await _getBalance('acc_1'), 40000);
    });
  });
}
