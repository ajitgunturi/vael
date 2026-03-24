import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/financial/cash_flow_engine.dart';

void main() {
  group('CashFlowEngine', () {
    group('projectMonth', () {
      test(
        '2 income + 3 expense items across 5 days returns 5 DayProjections sorted by date',
        () {
          final items = [
            CashFlowItem(
              date: DateTime(2026, 4, 5),
              ruleId: 'e3',
              ruleName: 'Groceries',
              accountId: 'a1',
              kind: 'expense',
              amountPaise: 200000,
            ),
            CashFlowItem(
              date: DateTime(2026, 4, 1),
              ruleId: 'i1',
              ruleName: 'Salary',
              accountId: 'a1',
              kind: 'income',
              amountPaise: 5000000,
            ),
            CashFlowItem(
              date: DateTime(2026, 4, 3),
              ruleId: 'e1',
              ruleName: 'Rent',
              accountId: 'a1',
              kind: 'expense',
              amountPaise: 1500000,
            ),
            CashFlowItem(
              date: DateTime(2026, 4, 10),
              ruleId: 'e2',
              ruleName: 'Utils',
              accountId: 'a1',
              kind: 'expense',
              amountPaise: 300000,
            ),
            CashFlowItem(
              date: DateTime(2026, 4, 15),
              ruleId: 'i2',
              ruleName: 'Freelance',
              accountId: 'a1',
              kind: 'income',
              amountPaise: 1000000,
            ),
          ];

          final result = CashFlowEngine.projectMonth(
            startingBalances: {'a1': 1000000},
            items: items,
            thresholds: {},
          );

          expect(result.length, 5);
          expect(result[0].date, DateTime(2026, 4, 1));
          expect(result[1].date, DateTime(2026, 4, 3));
          expect(result[2].date, DateTime(2026, 4, 5));
          expect(result[3].date, DateTime(2026, 4, 10));
          expect(result[4].date, DateTime(2026, 4, 15));
        },
      );

      test(
        'running balance starts from startingBalances and accumulates correctly',
        () {
          final items = [
            CashFlowItem(
              date: DateTime(2026, 4, 1),
              ruleId: 'i1',
              ruleName: 'Salary',
              accountId: 'a1',
              kind: 'income',
              amountPaise: 5000000,
            ),
            CashFlowItem(
              date: DateTime(2026, 4, 5),
              ruleId: 'e1',
              ruleName: 'Rent',
              accountId: 'a1',
              kind: 'expense',
              amountPaise: 1500000,
            ),
          ];

          final result = CashFlowEngine.projectMonth(
            startingBalances: {'a1': 1000000},
            items: items,
            thresholds: {},
          );

          // After income: 1000000 + 5000000 = 6000000
          expect(result[0].runningBalancesByAccount['a1'], 6000000);
          // After expense: 6000000 - 1500000 = 4500000
          expect(result[1].runningBalancesByAccount['a1'], 4500000);
        },
      );

      test('income adds, expense subtracts from account balance', () {
        final items = [
          CashFlowItem(
            date: DateTime(2026, 4, 1),
            ruleId: 'i1',
            ruleName: 'Inc',
            accountId: 'a1',
            kind: 'income',
            amountPaise: 100,
          ),
          CashFlowItem(
            date: DateTime(2026, 4, 2),
            ruleId: 'e1',
            ruleName: 'Exp',
            accountId: 'a1',
            kind: 'expense',
            amountPaise: 30,
          ),
        ];

        final result = CashFlowEngine.projectMonth(
          startingBalances: {'a1': 0},
          items: items,
          thresholds: {},
        );

        expect(result[0].runningBalancesByAccount['a1'], 100);
        expect(result[1].runningBalancesByAccount['a1'], 70);
      });

      test(
        'transfer subtracts from source, adds to destination (net zero)',
        () {
          final items = [
            CashFlowItem(
              date: DateTime(2026, 4, 1),
              ruleId: 't1',
              ruleName: 'Transfer',
              accountId: 'a1',
              toAccountId: 'a2',
              kind: 'transfer',
              amountPaise: 500,
            ),
          ];

          final result = CashFlowEngine.projectMonth(
            startingBalances: {'a1': 1000, 'a2': 2000},
            items: items,
            thresholds: {},
          );

          expect(result[0].runningBalancesByAccount['a1'], 500);
          expect(result[0].runningBalancesByAccount['a2'], 2500);
        },
      );

      test('threshold alert generated when balance drops below threshold', () {
        final items = [
          CashFlowItem(
            date: DateTime(2026, 4, 1),
            ruleId: 'e1',
            ruleName: 'Big Expense',
            accountId: 'a1',
            kind: 'expense',
            amountPaise: 8000,
          ),
        ];

        final result = CashFlowEngine.projectMonth(
          startingBalances: {'a1': 10000},
          items: items,
          thresholds: {'a1': 5000},
        );

        expect(result[0].alerts.length, 1);
        expect(result[0].alerts[0].accountId, 'a1');
        expect(result[0].alerts[0].date, DateTime(2026, 4, 1));
        expect(result[0].alerts[0].balancePaise, 2000);
        expect(result[0].alerts[0].thresholdPaise, 5000);
      });

      test('empty items list returns empty DayProjection list', () {
        final result = CashFlowEngine.projectMonth(
          startingBalances: {'a1': 10000},
          items: [],
          thresholds: {'a1': 5000},
        );

        expect(result, isEmpty);
      });

      test('only days with items appear (no gap-filling)', () {
        final items = [
          CashFlowItem(
            date: DateTime(2026, 4, 1),
            ruleId: 'i1',
            ruleName: 'Inc',
            accountId: 'a1',
            kind: 'income',
            amountPaise: 100,
          ),
          CashFlowItem(
            date: DateTime(2026, 4, 10),
            ruleId: 'e1',
            ruleName: 'Exp',
            accountId: 'a1',
            kind: 'expense',
            amountPaise: 50,
          ),
        ];

        final result = CashFlowEngine.projectMonth(
          startingBalances: {'a1': 0},
          items: items,
          thresholds: {},
        );

        expect(result.length, 2);
        expect(result[0].date, DateTime(2026, 4, 1));
        expect(result[1].date, DateTime(2026, 4, 10));
      });

      test('multiple accounts tracked independently', () {
        final items = [
          CashFlowItem(
            date: DateTime(2026, 4, 1),
            ruleId: 'e1',
            ruleName: 'Big',
            accountId: 'a1',
            kind: 'expense',
            amountPaise: 9000,
          ),
          CashFlowItem(
            date: DateTime(2026, 4, 1),
            ruleId: 'i1',
            ruleName: 'Inc',
            accountId: 'a2',
            kind: 'income',
            amountPaise: 5000,
          ),
        ];

        final result = CashFlowEngine.projectMonth(
          startingBalances: {'a1': 10000, 'a2': 10000},
          items: items,
          thresholds: {'a1': 5000, 'a2': 5000},
        );

        // a1: 10000 - 9000 = 1000 (below 5000 threshold -> alert)
        // a2: 10000 + 5000 = 15000 (above threshold -> no alert)
        expect(result[0].alerts.length, 1);
        expect(result[0].alerts[0].accountId, 'a1');
        expect(result[0].runningBalancesByAccount['a1'], 1000);
        expect(result[0].runningBalancesByAccount['a2'], 15000);
      });
    });
  });
}
