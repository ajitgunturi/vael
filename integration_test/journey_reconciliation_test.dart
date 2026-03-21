import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:vael/core/database/database.dart';
import 'package:vael/core/financial/balance_reconciliation.dart';

import 'helpers/e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('Journey: Balance Reconciliation', () {
    testWidgets('should detect no discrepancy when balances match transactions', (tester) async {
      await seedTestFamily(db);
      // Seed account with ₹50,000 balance
      await seedAccount(db, id: 'sav', name: 'Savings', type: 'savings', balance: 5000000);

      // Seed matching transactions: salary ₹80,000 - expense ₹30,000 = ₹50,000
      await seedTransactionOnly(db,
        id: 'tx1', amount: 8000000, date: DateTime(2025, 3, 5),
        kind: 'salary', accountId: 'sav',
      );
      await seedTransactionOnly(db,
        id: 'tx2', amount: 3000000, date: DateTime(2025, 3, 10),
        kind: 'expense', accountId: 'sav',
      );

      // Reconcile: recorded=5000000, computed from txns=5000000 (80k-30k)
      final result = BalanceReconciliation.reconcile(
        accounts: [
          const AccountBalance(id: 'sav', name: 'Savings', balance: 5000000),
        ],
        transactionSums: {'sav': 5000000},
      );

      expect(result.isClean, isTrue);
      expect(result.discrepancies, isEmpty);

      // Pump app to verify account still renders correctly
      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);
      expect(find.textContaining('50,000'), findsWidgets);
    });

    testWidgets('should detect phantom money discrepancy', (tester) async {
      await seedTestFamily(db);
      // Recorded balance ₹1,00,000 but transactions only sum to ₹80,000
      await seedAccount(db, id: 'cur', name: 'Current', type: 'current', balance: 10000000);

      final result = BalanceReconciliation.reconcile(
        accounts: [
          const AccountBalance(id: 'cur', name: 'Current', balance: 10000000),
        ],
        transactionSums: {'cur': 8000000},
      );

      expect(result.isClean, isFalse);
      expect(result.discrepancies.length, 1);
      final d = result.discrepancies.first;
      expect(d.accountName, 'Current');
      expect(d.recordedBalance, 10000000);
      expect(d.computedBalance, 8000000);
      expect(d.difference, 2000000); // +₹20,000 phantom money

      // App should still render the recorded balance
      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);
      expect(find.textContaining('1,00,000'), findsWidgets);
    });

    testWidgets('should detect missing balance discrepancy', (tester) async {
      await seedTestFamily(db);
      // Recorded ₹40,000 but transactions sum to ₹60,000
      await seedAccount(db, id: 'wal', name: 'Wallet', type: 'wallet', balance: 4000000);

      final result = BalanceReconciliation.reconcile(
        accounts: [
          const AccountBalance(id: 'wal', name: 'Wallet', balance: 4000000),
        ],
        transactionSums: {'wal': 6000000},
      );

      expect(result.isClean, isFalse);
      expect(result.discrepancies.first.difference, -2000000); // -₹20,000 missing

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);
      expect(find.textContaining('40,000'), findsWidgets);
    });

    testWidgets('should reconcile multiple accounts independently', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'a1', name: 'Clean Account', type: 'savings', balance: 5000000);
      await seedAccount(db, id: 'a2', name: 'Drifted Account', type: 'current', balance: 10000000);

      final result = BalanceReconciliation.reconcile(
        accounts: [
          const AccountBalance(id: 'a1', name: 'Clean Account', balance: 5000000),
          const AccountBalance(id: 'a2', name: 'Drifted Account', balance: 10000000),
        ],
        transactionSums: {
          'a1': 5000000, // matches
          'a2': 7500000, // off by ₹25,000
        },
      );

      expect(result.isClean, isFalse);
      expect(result.discrepancies.length, 1);
      expect(result.discrepancies.first.accountId, 'a2');
      expect(result.discrepancies.first.difference, 2500000);

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);
    });

    testWidgets('should handle account with no transactions', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'new', name: 'New Account', type: 'savings', balance: 0);

      final result = BalanceReconciliation.reconcile(
        accounts: [
          const AccountBalance(id: 'new', name: 'New Account', balance: 0),
        ],
        transactionSums: {}, // no transactions
      );

      // Balance 0, computed 0 → clean
      expect(result.isClean, isTrue);

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);
    });

    testWidgets('should detect drift with budget planning insights', (tester) async {
      await seedTestFamily(db);

      // 3 months of rising spending against ₹50,000 budget
      final driftResult = PlanningInsights.budgetDrift(
        monthlyActuals: [
          const MonthlyActual(year: 2025, month: 1, amount: 5500000),
          const MonthlyActual(year: 2025, month: 2, amount: 5800000),
          const MonthlyActual(year: 2025, month: 3, amount: 6200000),
        ],
        budgetLimit: 5000000,
      );

      expect(driftResult.isDrifting, isTrue);
      expect(driftResult.direction, DriftDirection.upward);
      expect(driftResult.averageOverspend, greaterThan(0));

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);
    });

    testWidgets('should flag at-risk goals', (tester) async {
      await seedTestFamily(db);

      final flags = PlanningInsights.flagAtRiskGoals(
        goals: [
          const GoalProgress(
            id: 'g1', name: 'Emergency Fund',
            targetAmount: 30000000, currentSavings: 5000000,
            monthsElapsed: 18, totalMonths: 24,
          ),
          const GoalProgress(
            id: 'g2', name: 'Vacation',
            targetAmount: 10000000, currentSavings: 8000000,
            monthsElapsed: 6, totalMonths: 12,
          ),
        ],
      );

      // Emergency Fund: 16.7% progress at 75% timeline → high risk
      expect(flags.length, 1);
      expect(flags.first.goalId, 'g1');
      expect(flags.first.severity, RiskSeverity.high);

      // Vacation: 80% progress at 50% timeline → on track (no flag)

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);
    });
  });
}
