import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/financial/recurring_scheduler.dart';
import 'package:vael/features/cashflow/providers/cash_flow_providers.dart';

void main() {
  group('buildCashFlowItems', () {
    test('returns CashFlowItem for each due date of each rule', () {
      final rules = [
        RecurringRule(
          id: 'r1',
          name: 'Rent',
          kind: 'expense',
          amount: 2500000,
          accountId: 'acc1',
          frequencyMonths: 1.0,
          startDate: DateTime(2026, 1, 1),
          isPaused: false,
        ),
        RecurringRule(
          id: 'r2',
          name: 'Salary',
          kind: 'income',
          amount: 10000000,
          accountId: 'acc2',
          frequencyMonths: 1.0,
          startDate: DateTime(2026, 1, 5),
          isPaused: false,
        ),
      ];

      final items = buildCashFlowItems(
        rules,
        DateTime(2026, 3, 1),
        DateTime(2026, 4, 1),
      );

      // Each rule has 1 due date in March -> 2 items
      expect(items.length, 2);
      expect(items[0].ruleId, 'r1');
      expect(items[0].ruleName, 'Rent');
      expect(items[0].kind, 'expense');
      expect(items[0].accountId, 'acc1');
      expect(items[1].ruleId, 'r2');
      expect(items[1].ruleName, 'Salary');
      expect(items[1].kind, 'income');
    });

    test('returns multiple items for rule with multiple due dates', () {
      final rules = [
        RecurringRule(
          id: 'r3',
          name: 'Biweekly',
          kind: 'expense',
          amount: 500000,
          accountId: 'acc1',
          frequencyMonths: 0.5, // biweekly ~ every 15 days
          startDate: DateTime(2026, 1, 1),
          isPaused: false,
        ),
      ];

      final items = buildCashFlowItems(
        rules,
        DateTime(2026, 3, 1),
        DateTime(2026, 4, 1),
      );

      // Biweekly from Jan 1 should produce ~2 dates in March
      expect(items.length, greaterThanOrEqualTo(2));
      for (final item in items) {
        expect(item.ruleId, 'r3');
        expect(item.date.month, 3);
      }
    });

    test('skips deleted rules', () {
      final rules = [
        RecurringRule(
          id: 'r4',
          name: 'Deleted Rule',
          kind: 'expense',
          amount: 100000,
          accountId: 'acc1',
          frequencyMonths: 1.0,
          startDate: DateTime(2026, 1, 1),
          isPaused: false,
          deletedAt: DateTime(2026, 2, 15),
        ),
      ];

      final items = buildCashFlowItems(
        rules,
        DateTime(2026, 3, 1),
        DateTime(2026, 4, 1),
      );

      expect(items, isEmpty);
    });

    test('empty rules returns empty items', () {
      final items = buildCashFlowItems(
        [],
        DateTime(2026, 3, 1),
        DateTime(2026, 4, 1),
      );

      expect(items, isEmpty);
    });

    test('rule with no due dates in range returns no items', () {
      final rules = [
        RecurringRule(
          id: 'r5',
          name: 'Future',
          kind: 'income',
          amount: 500000,
          accountId: 'acc1',
          frequencyMonths: 1.0,
          startDate: DateTime(2026, 6, 1), // starts after window
          isPaused: false,
        ),
      ];

      final items = buildCashFlowItems(
        rules,
        DateTime(2026, 3, 1),
        DateTime(2026, 4, 1),
      );

      expect(items, isEmpty);
    });

    test('item amount uses escalatedAmount not raw rule amount', () {
      final rules = [
        RecurringRule(
          id: 'r6',
          name: 'Escalating',
          kind: 'expense',
          amount: 1000000, // 10K base
          accountId: 'acc1',
          frequencyMonths: 1.0,
          startDate: DateTime(2024, 3, 1), // 2 years ago
          isPaused: false,
          annualEscalationRate: 0.10, // 10% per year
        ),
      ];

      final items = buildCashFlowItems(
        rules,
        DateTime(2026, 3, 1),
        DateTime(2026, 4, 1),
      );

      expect(items.length, 1);
      // After 2 years of 10% escalation: 10000 * 1.1^2 = 12100 rupees = 1210000 paise
      expect(items[0].amountPaise, 1210000);
      expect(items[0].amountPaise, isNot(1000000)); // not raw amount
    });

    test('transfer rule populates toAccountId', () {
      final rules = [
        RecurringRule(
          id: 'r7',
          name: 'Savings Transfer',
          kind: 'transfer',
          amount: 2000000,
          accountId: 'acc1',
          toAccountId: 'acc2',
          frequencyMonths: 1.0,
          startDate: DateTime(2026, 1, 1),
          isPaused: false,
        ),
      ];

      final items = buildCashFlowItems(
        rules,
        DateTime(2026, 3, 1),
        DateTime(2026, 4, 1),
      );

      expect(items.length, 1);
      expect(items[0].toAccountId, 'acc2');
      expect(items[0].kind, 'transfer');
    });
  });
}
