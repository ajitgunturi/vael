import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/financial/dashboard_aggregation.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
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
  }

  Future<Account> _insertAccount({
    required String id,
    required String familyId,
    String type = 'savings',
    int balance = 0,
    String visibility = 'shared',
    DateTime? deletedAt,
  }) async {
    final companion = AccountsCompanion(
      id: Value(id),
      name: Value('Account $id'),
      type: Value(type),
      balance: Value(balance),
      visibility: Value(visibility),
      familyId: Value(familyId),
      userId: Value('user_$familyId'),
      deletedAt: Value(deletedAt),
    );
    await db.into(db.accounts).insert(companion);
    return (await (db.select(db.accounts)
              ..where((a) => a.id.equals(id)))
            .getSingle());
  }

  Future<void> _insertTransaction({
    required String id,
    required String familyId,
    required String accountId,
    required int amount,
    required String kind,
    required DateTime date,
    String? toAccountId,
  }) async {
    await db.into(db.transactions).insert(TransactionsCompanion(
          id: Value(id),
          amount: Value(amount),
          date: Value(date),
          kind: Value(kind),
          accountId: Value(accountId),
          toAccountId: Value(toAccountId),
          familyId: Value(familyId),
        ));
  }

  group('AccountGrouping', () {
    test('groups accounts into banking, investments, loans, creditCards',
        () async {
      await _seedFamily('fam_a');

      final accounts = <Account>[];
      accounts.add(await _insertAccount(
          id: 'sav', familyId: 'fam_a', type: 'savings', balance: 100000));
      accounts.add(await _insertAccount(
          id: 'cur', familyId: 'fam_a', type: 'current', balance: 200000));
      accounts.add(await _insertAccount(
          id: 'inv', familyId: 'fam_a', type: 'investment', balance: 500000));
      accounts.add(await _insertAccount(
          id: 'wal', familyId: 'fam_a', type: 'wallet', balance: 50000));
      accounts.add(await _insertAccount(
          id: 'cc', familyId: 'fam_a', type: 'creditCard', balance: 75000));
      accounts.add(await _insertAccount(
          id: 'loan', familyId: 'fam_a', type: 'loan', balance: 1000000));

      final grouped = DashboardAggregation.groupAccounts(accounts);

      expect(grouped.banking, hasLength(3)); // savings, current, wallet
      expect(grouped.investments, hasLength(1));
      expect(grouped.loans, hasLength(1));
      expect(grouped.creditCards, hasLength(1));
    });

    test('empty accounts yields empty groups', () {
      final grouped = DashboardAggregation.groupAccounts([]);

      expect(grouped.banking, isEmpty);
      expect(grouped.investments, isEmpty);
      expect(grouped.loans, isEmpty);
      expect(grouped.creditCards, isEmpty);
    });
  });

  group('NetWorth', () {
    test('computes assets minus liabilities', () async {
      await _seedFamily('fam_a');

      final accounts = <Account>[];
      accounts.add(await _insertAccount(
          id: 'sav', familyId: 'fam_a', type: 'savings', balance: 500000));
      accounts.add(await _insertAccount(
          id: 'inv', familyId: 'fam_a', type: 'investment', balance: 1000000));
      accounts.add(await _insertAccount(
          id: 'cc', familyId: 'fam_a', type: 'creditCard', balance: 200000));
      accounts.add(await _insertAccount(
          id: 'loan', familyId: 'fam_a', type: 'loan', balance: 300000));

      final netWorth = DashboardAggregation.computeNetWorth(accounts);

      // (500000 + 1000000) - (200000 + 300000) = 1000000
      expect(netWorth, 1000000);
    });

    test('returns zero for no accounts', () {
      expect(DashboardAggregation.computeNetWorth([]), 0);
    });
  });

  group('MonthlySummary', () {
    test('computes income, expenses, and net savings for a month', () async {
      await _seedFamily('fam_a');
      await _insertAccount(
          id: 'acc_1', familyId: 'fam_a', type: 'savings', balance: 0);

      final transactions = <Transaction>[];
      // Income
      await _insertTransaction(
          id: 'tx1',
          familyId: 'fam_a',
          accountId: 'acc_1',
          amount: 5000000,
          kind: 'salary',
          date: DateTime(2025, 3, 1));
      await _insertTransaction(
          id: 'tx2',
          familyId: 'fam_a',
          accountId: 'acc_1',
          amount: 100000,
          kind: 'dividend',
          date: DateTime(2025, 3, 15));

      // Expenses
      await _insertTransaction(
          id: 'tx3',
          familyId: 'fam_a',
          accountId: 'acc_1',
          amount: 2000000,
          kind: 'expense',
          date: DateTime(2025, 3, 5));
      await _insertTransaction(
          id: 'tx4',
          familyId: 'fam_a',
          accountId: 'acc_1',
          amount: 500000,
          kind: 'emiPayment',
          date: DateTime(2025, 3, 10));

      // Fetch transactions for the month
      final txns = await db.select(db.transactions).get();

      final summary = DashboardAggregation.monthlySummary(txns);

      expect(summary.totalIncome, 5100000); // salary + dividend
      expect(summary.totalExpenses, 2500000); // expense + emi
      expect(summary.netSavings, 2600000); // income - expenses
    });

    test('transfers are excluded from income/expense totals', () async {
      await _seedFamily('fam_a');
      await _insertAccount(
          id: 'acc_1', familyId: 'fam_a', type: 'savings', balance: 0);
      await _insertAccount(
          id: 'acc_2', familyId: 'fam_a', type: 'savings', balance: 0);

      await _insertTransaction(
          id: 'tx1',
          familyId: 'fam_a',
          accountId: 'acc_1',
          toAccountId: 'acc_2',
          amount: 1000000,
          kind: 'transfer',
          date: DateTime(2025, 3, 1));

      final txns = await db.select(db.transactions).get();
      final summary = DashboardAggregation.monthlySummary(txns);

      expect(summary.totalIncome, 0);
      expect(summary.totalExpenses, 0);
      expect(summary.netSavings, 0);
    });

    test('empty transactions yields zero summary', () {
      final summary = DashboardAggregation.monthlySummary([]);

      expect(summary.totalIncome, 0);
      expect(summary.totalExpenses, 0);
      expect(summary.netSavings, 0);
    });

    test('insurancePremium counts as expense', () async {
      await _seedFamily('fam_a');
      await _insertAccount(
          id: 'acc_1', familyId: 'fam_a', type: 'savings', balance: 0);

      await _insertTransaction(
          id: 'tx1',
          familyId: 'fam_a',
          accountId: 'acc_1',
          amount: 250000,
          kind: 'insurancePremium',
          date: DateTime(2025, 3, 1));

      final txns = await db.select(db.transactions).get();
      final summary = DashboardAggregation.monthlySummary(txns);

      expect(summary.totalExpenses, 250000);
    });

    test('income kind counts toward income total', () async {
      await _seedFamily('fam_a');
      await _insertAccount(
          id: 'acc_1', familyId: 'fam_a', type: 'savings', balance: 0);

      await _insertTransaction(
          id: 'tx1',
          familyId: 'fam_a',
          accountId: 'acc_1',
          amount: 300000,
          kind: 'income',
          date: DateTime(2025, 3, 1));

      final txns = await db.select(db.transactions).get();
      final summary = DashboardAggregation.monthlySummary(txns);

      expect(summary.totalIncome, 300000);
    });
  });

  group('ScopeFiltering', () {
    test('family scope includes shared and familyWide, excludes private',
        () async {
      await _seedFamily('fam_a');

      final accounts = <Account>[];
      accounts.add(await _insertAccount(
          id: 'shared',
          familyId: 'fam_a',
          visibility: 'shared',
          balance: 100));
      accounts.add(await _insertAccount(
          id: 'family_wide',
          familyId: 'fam_a',
          visibility: 'familyWide',
          balance: 200));
      accounts.add(await _insertAccount(
          id: 'priv',
          familyId: 'fam_a',
          visibility: 'private_',
          balance: 300));

      final filtered = DashboardAggregation.filterByScope(
        accounts,
        scope: DashboardScope.family,
      );

      expect(filtered, hasLength(2));
      expect(filtered.map((a) => a.id), containsAll(['shared', 'family_wide']));
    });

    test('personal scope includes accounts for a specific userId', () async {
      await _seedFamily('fam_a');
      // Add second user
      await db.into(db.users).insert(UsersCompanion.insert(
            id: 'user2',
            email: 'user2@test.com',
            displayName: 'User 2',
            role: 'member',
            familyId: 'fam_a',
          ));

      final accounts = <Account>[];
      accounts.add(await _insertAccount(
          id: 'mine', familyId: 'fam_a', balance: 100));
      // Insert account for user2 directly
      await db.into(db.accounts).insert(AccountsCompanion(
            id: const Value('theirs'),
            name: const Value('Account theirs'),
            type: const Value('savings'),
            balance: const Value(200),
            visibility: const Value('shared'),
            familyId: const Value('fam_a'),
            userId: const Value('user2'),
          ));
      accounts.add(await (db.select(db.accounts)
                ..where((a) => a.id.equals('theirs')))
              .getSingle());
      // Re-read 'mine' to have correct Account object
      accounts[0] = await (db.select(db.accounts)
                ..where((a) => a.id.equals('mine')))
              .getSingle();

      final filtered = DashboardAggregation.filterByScope(
        accounts,
        scope: DashboardScope.personal,
        userId: 'user_fam_a',
      );

      expect(filtered, hasLength(1));
      expect(filtered.first.id, 'mine');
    });
  });
}
