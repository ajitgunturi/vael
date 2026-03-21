import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/financial/balance_reconciliation.dart';

void main() {
  group('BalanceReconciliation', () {
    group('reconcile', () {
      test('should detect no discrepancies when balanced', () {
        final result = BalanceReconciliation.reconcile(
          accounts: [
            AccountBalance(id: 'a1', name: 'HDFC Savings', balance: 5000000),
            AccountBalance(id: 'a2', name: 'ICICI CC', balance: 200000),
          ],
          transactionSums: {'a1': 5000000, 'a2': 200000},
        );

        expect(result.discrepancies, isEmpty);
        expect(result.isClean, true);
      });

      test('should detect balance mismatch', () {
        final result = BalanceReconciliation.reconcile(
          accounts: [
            AccountBalance(id: 'a1', name: 'HDFC Savings', balance: 5000000),
          ],
          transactionSums: {
            'a1': 4800000, // ₹2K short
          },
        );

        expect(result.discrepancies.length, 1);
        expect(result.discrepancies[0].accountId, 'a1');
        expect(result.discrepancies[0].recordedBalance, 5000000);
        expect(result.discrepancies[0].computedBalance, 4800000);
        expect(result.discrepancies[0].difference, 200000);
        expect(result.isClean, false);
      });

      test('should handle account with no transactions', () {
        final result = BalanceReconciliation.reconcile(
          accounts: [AccountBalance(id: 'a1', name: 'Empty', balance: 0)],
          transactionSums: {},
        );

        // No transactions = computed balance is 0, matches
        expect(result.isClean, true);
      });

      test('should handle account with zero balance but transactions', () {
        final result = BalanceReconciliation.reconcile(
          accounts: [AccountBalance(id: 'a1', name: 'Closed', balance: 0)],
          transactionSums: {
            'a1': 500000, // transactions sum to ₹5K but balance is 0
          },
        );

        expect(result.discrepancies.length, 1);
        expect(result.discrepancies[0].difference, -500000);
      });

      test('should reconcile multiple accounts independently', () {
        final result = BalanceReconciliation.reconcile(
          accounts: [
            AccountBalance(id: 'a1', name: 'OK', balance: 1000000),
            AccountBalance(id: 'a2', name: 'Bad', balance: 2000000),
            AccountBalance(id: 'a3', name: 'Also OK', balance: 3000000),
          ],
          transactionSums: {
            'a1': 1000000,
            'a2': 1500000, // ₹5K off
            'a3': 3000000,
          },
        );

        expect(result.discrepancies.length, 1);
        expect(result.discrepancies[0].accountId, 'a2');
      });
    });
  });

  group('PlanningInsights', () {
    group('budgetDrift', () {
      test('should detect consistent overspend as upward drift', () {
        final drift = PlanningInsights.budgetDrift(
          monthlyActuals: [
            MonthlyActual(year: 2026, month: 1, amount: 110000),
            MonthlyActual(year: 2026, month: 2, amount: 115000),
            MonthlyActual(year: 2026, month: 3, amount: 120000),
          ],
          budgetLimit: 100000,
        );

        expect(drift.isDrifting, true);
        expect(drift.direction, DriftDirection.upward);
        expect(drift.averageOverspend, greaterThan(0));
        expect(drift.trendPercent, greaterThan(0));
      });

      test('should detect stable spending as no drift', () {
        final drift = PlanningInsights.budgetDrift(
          monthlyActuals: [
            MonthlyActual(year: 2026, month: 1, amount: 95000),
            MonthlyActual(year: 2026, month: 2, amount: 98000),
            MonthlyActual(year: 2026, month: 3, amount: 92000),
          ],
          budgetLimit: 100000,
        );

        expect(drift.isDrifting, false);
      });

      test('should require at least 3 months of data', () {
        final drift = PlanningInsights.budgetDrift(
          monthlyActuals: [
            MonthlyActual(year: 2026, month: 1, amount: 120000),
            MonthlyActual(year: 2026, month: 2, amount: 130000),
          ],
          budgetLimit: 100000,
        );

        expect(drift.isDrifting, false); // insufficient data
      });
    });

    group('atRiskGoals', () {
      test('should flag goals significantly behind schedule', () {
        final flags = PlanningInsights.flagAtRiskGoals(
          goals: [
            GoalProgress(
              id: 'g1',
              name: 'Emergency Fund',
              targetAmount: 60000000, // ₹6L
              currentSavings: 10000000, // ₹1L — only 16%
              monthsElapsed: 12,
              totalMonths: 24,
            ),
            GoalProgress(
              id: 'g2',
              name: 'Vacation',
              targetAmount: 20000000,
              currentSavings: 15000000, // 75% at 50% time — on track
              monthsElapsed: 12,
              totalMonths: 24,
            ),
          ],
        );

        expect(flags.length, 1);
        expect(flags[0].goalId, 'g1');
        expect(flags[0].severity, RiskSeverity.high);
      });

      test('should return empty for all on-track goals', () {
        final flags = PlanningInsights.flagAtRiskGoals(
          goals: [
            GoalProgress(
              id: 'g1',
              name: 'On Track',
              targetAmount: 100000,
              currentSavings: 80000,
              monthsElapsed: 8,
              totalMonths: 10,
            ),
          ],
        );

        expect(flags, isEmpty);
      });

      test('should flag overdue goals', () {
        final flags = PlanningInsights.flagAtRiskGoals(
          goals: [
            GoalProgress(
              id: 'g1',
              name: 'Overdue',
              targetAmount: 100000,
              currentSavings: 50000,
              monthsElapsed: 13,
              totalMonths: 12,
            ),
          ],
        );

        expect(flags.length, 1);
        expect(flags[0].severity, RiskSeverity.critical);
      });
    });
  });
}
