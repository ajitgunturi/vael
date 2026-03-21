import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/financial/recurring_scheduler.dart';

void main() {
  group('RecurringScheduler', () {
    group('computeDueDates', () {
      test('should generate monthly due dates', () {
        final rule = RecurringRule(
          id: 'r1',
          name: 'Rent',
          kind: 'expense',
          amount: 2500000, // ₹25K
          accountId: 'acc1',
          frequencyMonths: 1.0,
          startDate: DateTime(2026, 1, 1),
          isPaused: false,
        );

        final dues = RecurringScheduler.computeDueDates(
          rule: rule,
          from: DateTime(2026, 1, 1),
          until: DateTime(2026, 4, 1),
        );

        expect(dues.length, 3);
        expect(dues[0], DateTime(2026, 1, 1));
        expect(dues[1], DateTime(2026, 2, 1));
        expect(dues[2], DateTime(2026, 3, 1));
      });

      test('should generate quarterly due dates', () {
        final rule = RecurringRule(
          id: 'r2',
          name: 'Insurance',
          kind: 'insurancePremium',
          amount: 1000000,
          accountId: 'acc1',
          frequencyMonths: 3.0,
          startDate: DateTime(2026, 1, 15),
          isPaused: false,
        );

        final dues = RecurringScheduler.computeDueDates(
          rule: rule,
          from: DateTime(2026, 1, 1),
          until: DateTime(2027, 1, 1),
        );

        expect(dues.length, 4);
        expect(dues[0], DateTime(2026, 1, 15));
        expect(dues[1], DateTime(2026, 4, 15));
        expect(dues[2], DateTime(2026, 7, 15));
        expect(dues[3], DateTime(2026, 10, 15));
      });

      test('should generate annual due dates', () {
        final rule = RecurringRule(
          id: 'r3',
          name: 'LIC Premium',
          kind: 'insurancePremium',
          amount: 5000000,
          accountId: 'acc1',
          frequencyMonths: 12.0,
          startDate: DateTime(2025, 3, 1),
          isPaused: false,
        );

        final dues = RecurringScheduler.computeDueDates(
          rule: rule,
          from: DateTime(2025, 1, 1),
          until: DateTime(2028, 1, 1),
        );

        expect(dues.length, 3);
        expect(dues[0], DateTime(2025, 3, 1));
        expect(dues[1], DateTime(2026, 3, 1));
        expect(dues[2], DateTime(2027, 3, 1));
      });

      test('should skip dates before from', () {
        final rule = RecurringRule(
          id: 'r4',
          name: 'Salary',
          kind: 'salary',
          amount: 15000000,
          accountId: 'acc1',
          frequencyMonths: 1.0,
          startDate: DateTime(2025, 6, 1),
          isPaused: false,
        );

        final dues = RecurringScheduler.computeDueDates(
          rule: rule,
          from: DateTime(2026, 1, 1),
          until: DateTime(2026, 4, 1),
        );

        expect(dues.length, 3);
        expect(dues[0], DateTime(2026, 1, 1));
      });

      test('should return empty for paused rules', () {
        final rule = RecurringRule(
          id: 'r5',
          name: 'Paused',
          kind: 'expense',
          amount: 100000,
          accountId: 'acc1',
          frequencyMonths: 1.0,
          startDate: DateTime(2026, 1, 1),
          isPaused: true,
        );

        final dues = RecurringScheduler.computeDueDates(
          rule: rule,
          from: DateTime(2026, 1, 1),
          until: DateTime(2026, 6, 1),
        );

        expect(dues, isEmpty);
      });

      test('should handle biweekly (0.5 months) frequency', () {
        final rule = RecurringRule(
          id: 'r6',
          name: 'Biweekly expense',
          kind: 'expense',
          amount: 500000,
          accountId: 'acc1',
          frequencyMonths: 0.5,
          startDate: DateTime(2026, 1, 1),
          isPaused: false,
        );

        final dues = RecurringScheduler.computeDueDates(
          rule: rule,
          from: DateTime(2026, 1, 1),
          until: DateTime(2026, 3, 1),
        );

        // ~4 occurrences in 2 months with 0.5-month frequency
        expect(dues.length, 4);
      });
    });

    group('escalation', () {
      test('should escalate amount annually', () {
        final rule = RecurringRule(
          id: 'r7',
          name: 'Salary',
          kind: 'salary',
          amount: 15000000, // ₹1.5L
          accountId: 'acc1',
          frequencyMonths: 1.0,
          startDate: DateTime(2025, 4, 1),
          isPaused: false,
          annualEscalationRate: 0.10, // 10% hike
        );

        // Year 1: base amount
        final y1Amount = RecurringScheduler.escalatedAmount(
          rule: rule,
          asOfDate: DateTime(2025, 6, 1),
        );
        expect(y1Amount, 15000000);

        // Year 2: +10%
        final y2Amount = RecurringScheduler.escalatedAmount(
          rule: rule,
          asOfDate: DateTime(2026, 6, 1),
        );
        expect(y2Amount, 16500000);

        // Year 3: +10% compound
        final y3Amount = RecurringScheduler.escalatedAmount(
          rule: rule,
          asOfDate: DateTime(2027, 6, 1),
        );
        expect(y3Amount, 18150000);
      });

      test('should not escalate when rate is zero', () {
        final rule = RecurringRule(
          id: 'r8',
          name: 'Rent',
          kind: 'expense',
          amount: 2500000,
          accountId: 'acc1',
          frequencyMonths: 1.0,
          startDate: DateTime(2025, 1, 1),
          isPaused: false,
          annualEscalationRate: 0,
        );

        final amount = RecurringScheduler.escalatedAmount(
          rule: rule,
          asOfDate: DateTime(2028, 1, 1),
        );
        expect(amount, 2500000);
      });
    });

    group('pendingTransactions', () {
      test('should generate pending transactions since last run', () {
        final rule = RecurringRule(
          id: 'r9',
          name: 'SIP',
          kind: 'expense',
          amount: 500000, // ₹5K
          accountId: 'acc1',
          frequencyMonths: 1.0,
          startDate: DateTime(2026, 1, 5),
          isPaused: false,
          lastExecutedDate: DateTime(2026, 2, 5),
        );

        final pending = RecurringScheduler.pendingTransactions(
          rule: rule,
          asOfDate: DateTime(2026, 5, 1),
        );

        // Should generate for March 5 and April 5 (Feb already executed)
        expect(pending.length, 2);
        expect(pending[0].date, DateTime(2026, 3, 5));
        expect(pending[1].date, DateTime(2026, 4, 5));
        expect(pending[0].amount, 500000);
      });

      test('should generate from start if never executed', () {
        final rule = RecurringRule(
          id: 'r10',
          name: 'New SIP',
          kind: 'expense',
          amount: 300000,
          accountId: 'acc1',
          frequencyMonths: 1.0,
          startDate: DateTime(2026, 3, 1),
          isPaused: false,
        );

        final pending = RecurringScheduler.pendingTransactions(
          rule: rule,
          asOfDate: DateTime(2026, 5, 15),
        );

        expect(pending.length, 3);
        expect(pending[0].date, DateTime(2026, 3, 1));
      });

      test('should apply escalation to pending amounts', () {
        final rule = RecurringRule(
          id: 'r11',
          name: 'Salary',
          kind: 'salary',
          amount: 10000000,
          accountId: 'acc1',
          frequencyMonths: 1.0,
          startDate: DateTime(2025, 1, 1),
          isPaused: false,
          annualEscalationRate: 0.10,
          lastExecutedDate: DateTime(2025, 12, 1),
        );

        final pending = RecurringScheduler.pendingTransactions(
          rule: rule,
          asOfDate: DateTime(2026, 3, 1),
        );

        // Year 2 amount = 10L * 1.10 = 11L = 11000000
        expect(pending.length, 2);
        expect(pending[0].amount, 11000000);
      });
    });

    group('edge cases', () {
      test('should handle end date before start date', () {
        final rule = RecurringRule(
          id: 'r12',
          name: 'Future',
          kind: 'expense',
          amount: 100000,
          accountId: 'acc1',
          frequencyMonths: 1.0,
          startDate: DateTime(2027, 1, 1),
          isPaused: false,
        );

        final dues = RecurringScheduler.computeDueDates(
          rule: rule,
          from: DateTime(2026, 1, 1),
          until: DateTime(2026, 6, 1),
        );

        expect(dues, isEmpty);
      });

      test('should handle end date specified on rule', () {
        final rule = RecurringRule(
          id: 'r13',
          name: 'Limited',
          kind: 'expense',
          amount: 100000,
          accountId: 'acc1',
          frequencyMonths: 1.0,
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 3, 15),
          isPaused: false,
        );

        final dues = RecurringScheduler.computeDueDates(
          rule: rule,
          from: DateTime(2026, 1, 1),
          until: DateTime(2026, 12, 1),
        );

        // Only Jan, Feb, Mar (Mar 1 is before endDate Mar 15)
        expect(dues.length, 3);
      });
    });
  });
}
