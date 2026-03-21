import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/financial/dashboard_aggregation.dart';
import 'package:vael/core/providers/database_providers.dart';
import 'package:vael/features/dashboard/providers/dashboard_providers.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
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

  Future<void> _insertAccount({
    required String id,
    required String familyId,
    String type = 'savings',
    int balance = 0,
    String visibility = 'shared',
  }) async {
    await db
        .into(db.accounts)
        .insert(
          AccountsCompanion(
            id: Value(id),
            name: Value('Account $id'),
            type: Value(type),
            balance: Value(balance),
            visibility: Value(visibility),
            familyId: Value(familyId),
            userId: Value('user_$familyId'),
          ),
        );
  }

  Future<void> _insertTransaction({
    required String id,
    required String familyId,
    required String accountId,
    required int amount,
    required String kind,
    required DateTime date,
  }) async {
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion(
            id: Value(id),
            amount: Value(amount),
            date: Value(date),
            kind: Value(kind),
            accountId: Value(accountId),
            familyId: Value(familyId),
          ),
        );
  }

  group('dashboardScopeProvider', () {
    test('defaults to family scope', () {
      final scope = container.read(dashboardScopeProvider);
      expect(scope, DashboardScope.family);
    });

    test('can be toggled to personal and back', () {
      container.read(dashboardScopeProvider.notifier).state =
          DashboardScope.personal;
      expect(container.read(dashboardScopeProvider), DashboardScope.personal);

      container.read(dashboardScopeProvider.notifier).state =
          DashboardScope.family;
      expect(container.read(dashboardScopeProvider), DashboardScope.family);
    });
  });

  group('dashboardDataProvider', () {
    test('provides grouped accounts and net worth', () async {
      await _seedFamily('fam_a');
      await _insertAccount(
        id: 'sav',
        familyId: 'fam_a',
        type: 'savings',
        balance: 500000,
      );
      await _insertAccount(
        id: 'cc',
        familyId: 'fam_a',
        type: 'creditCard',
        balance: 100000,
      );

      final sub = container.listen(dashboardDataProvider('fam_a'), (_, __) {});

      await Future<void>.delayed(Duration.zero);

      final state = sub.read();
      expect(state.value, isNotNull);
      final data = state.value!;
      expect(data.grouped.banking, hasLength(1));
      expect(data.grouped.creditCards, hasLength(1));
      expect(data.netWorth, 400000); // 500000 - 100000
    });

    test('provides monthly summary from current month transactions', () async {
      await _seedFamily('fam_a');
      await _insertAccount(
        id: 'acc_1',
        familyId: 'fam_a',
        type: 'savings',
        balance: 0,
      );

      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month, 1);

      await _insertTransaction(
        id: 'tx1',
        familyId: 'fam_a',
        accountId: 'acc_1',
        amount: 5000000,
        kind: 'salary',
        date: thisMonth,
      );
      await _insertTransaction(
        id: 'tx2',
        familyId: 'fam_a',
        accountId: 'acc_1',
        amount: 2000000,
        kind: 'expense',
        date: thisMonth.add(const Duration(days: 5)),
      );

      final sub = container.listen(dashboardDataProvider('fam_a'), (_, __) {});

      await Future<void>.delayed(Duration.zero);

      final state = sub.read();
      final data = state.value!;
      expect(data.monthlySummary.totalIncome, 5000000);
      expect(data.monthlySummary.totalExpenses, 2000000);
      expect(data.monthlySummary.netSavings, 3000000);
    });

    test('respects family scope — excludes private accounts', () async {
      await _seedFamily('fam_a');
      await _insertAccount(
        id: 'sav',
        familyId: 'fam_a',
        type: 'savings',
        balance: 500000,
        visibility: 'shared',
      );
      await _insertAccount(
        id: 'priv',
        familyId: 'fam_a',
        type: 'savings',
        balance: 300000,
        visibility: 'private_',
      );

      // Default scope is family
      final sub = container.listen(dashboardDataProvider('fam_a'), (_, __) {});

      await Future<void>.delayed(Duration.zero);

      final state = sub.read();
      final data = state.value!;
      // Only shared account in net worth
      expect(data.netWorth, 500000);
      expect(data.grouped.banking, hasLength(1));
    });
  });
}
