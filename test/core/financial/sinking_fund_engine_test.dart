import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/financial/sinking_fund_engine.dart';

void main() {
  group('SinkingFundEngine', () {
    group('monthlyNeededPaise', () {
      test('normal case: (100000 - 40000) / 6 = 10000', () {
        expect(SinkingFundEngine.monthlyNeededPaise(100000, 40000, 6), 10000);
      });

      test('returns 0 when currentSavings >= targetAmount', () {
        expect(SinkingFundEngine.monthlyNeededPaise(100000, 100000, 6), 0);
        expect(SinkingFundEngine.monthlyNeededPaise(100000, 150000, 6), 0);
      });

      test('returns 0 when monthsRemaining <= 0', () {
        expect(SinkingFundEngine.monthlyNeededPaise(100000, 40000, 0), 0);
        expect(SinkingFundEngine.monthlyNeededPaise(100000, 40000, -1), 0);
      });

      test('ceiling division: 1 paise over 3 months => 1', () {
        expect(SinkingFundEngine.monthlyNeededPaise(1, 0, 3), 1);
      });

      test('ceiling division: 7 paise over 3 months => 3', () {
        // (7 + 3 - 1) ~/ 3 = 9 ~/ 3 = 3
        expect(SinkingFundEngine.monthlyNeededPaise(7, 0, 3), 3);
      });

      test('exact division: 9 paise over 3 months => 3', () {
        expect(SinkingFundEngine.monthlyNeededPaise(9, 0, 3), 3);
      });
    });

    group('paceStatus', () {
      test('currentSavings >= linearExpected => onTrack', () {
        // totalMonths=12, monthsElapsed=6, target=120000
        // expected = 120000 * 6 / 12 = 60000
        expect(SinkingFundEngine.paceStatus(120000, 60000, 12, 6), 'onTrack');
        expect(SinkingFundEngine.paceStatus(120000, 70000, 12, 6), 'onTrack');
      });

      test('currentSavings >= 50% of expected => behind', () {
        // expected = 120000 * 6 / 12 = 60000; 50% = 30000
        expect(SinkingFundEngine.paceStatus(120000, 30000, 12, 6), 'behind');
        expect(SinkingFundEngine.paceStatus(120000, 50000, 12, 6), 'behind');
      });

      test('currentSavings < 50% of expected => atRisk', () {
        // expected = 60000; 50% = 30000; 29999 < 30000
        expect(SinkingFundEngine.paceStatus(120000, 29999, 12, 6), 'atRisk');
      });

      test('monthsElapsed=0 => onTrack (fresh fund)', () {
        expect(SinkingFundEngine.paceStatus(120000, 0, 12, 0), 'onTrack');
      });

      test('totalMonths=0 => onTrack (fresh fund)', () {
        expect(SinkingFundEngine.paceStatus(120000, 0, 0, 0), 'onTrack');
      });
    });

    group('savingsRateBp', () {
      test('20% savings rate => 2000 bp', () {
        expect(SinkingFundEngine.savingsRateBp(100000, 80000), 2000);
      });

      test('income=0 => 0', () {
        expect(SinkingFundEngine.savingsRateBp(0, 50000), 0);
      });

      test('100% savings rate => 10000 bp', () {
        expect(SinkingFundEngine.savingsRateBp(100000, 0), 10000);
      });

      test('negative savings (expenses > income) => negative bp', () {
        expect(SinkingFundEngine.savingsRateBp(100000, 120000), -2000);
      });
    });

    group('daysRemaining', () {
      test('targetDate in future => positive int', () {
        final now = DateTime(2026, 1, 1);
        final target = DateTime(2026, 1, 11);
        expect(SinkingFundEngine.daysRemaining(target, now), 10);
      });

      test('targetDate in past => 0', () {
        final now = DateTime(2026, 3, 1);
        final target = DateTime(2026, 1, 1);
        expect(SinkingFundEngine.daysRemaining(target, now), 0);
      });

      test('targetDate is today => 0', () {
        final now = DateTime(2026, 3, 1);
        expect(SinkingFundEngine.daysRemaining(now, now), 0);
      });
    });

    group('isComplete', () {
      test('current >= target => true', () {
        expect(SinkingFundEngine.isComplete(100, 100), true);
        expect(SinkingFundEngine.isComplete(150, 100), true);
      });

      test('current < target => false', () {
        expect(SinkingFundEngine.isComplete(99, 100), false);
      });
    });
  });
}
