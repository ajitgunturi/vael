import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/financial/milestone_engine.dart';
import 'package:vael/core/financial/financial_math.dart';

void main() {
  group('MilestoneEngine', () {
    group('projectNetWorthAtAge', () {
      test('projects FV of portfolio + FV of savings annuity', () {
        // currentNw=10L, age=30, targetAge=40, monthly=50K, return=10%
        final months = 10 * 12; // 120
        final monthlyRate = 0.10 / 12;
        final fvPortfolio = FinancialMath.fv(
          rate: monthlyRate,
          nper: months,
          pmt: 0,
          pv: -100000000,
        );
        final fvSavings = FinancialMath.fv(
          rate: monthlyRate,
          nper: months,
          pmt: -5000000,
        );
        final expected = fvPortfolio + fvSavings;

        final result = MilestoneEngine.projectNetWorthAtAge(
          currentNwPaise: 100000000,
          currentAge: 30,
          targetAge: 40,
          monthlySavingsPaise: 5000000,
          annualReturnRate: 0.10,
        );
        expect(result, expected);
      });

      test('returns currentNw when targetAge <= currentAge', () {
        final result = MilestoneEngine.projectNetWorthAtAge(
          currentNwPaise: 100000000,
          currentAge: 40,
          targetAge: 30,
          monthlySavingsPaise: 5000000,
          annualReturnRate: 0.10,
        );
        expect(result, 100000000);
      });
    });

    group('determineStatus', () {
      test('returns reached when past and actual >= target', () {
        final result = MilestoneEngine.determineStatus(
          currentAge: 40,
          milestoneAge: 30,
          targetAmountPaise: 100000000,
          actualOrProjectedPaise: 150000000,
        );
        expect(result, MilestoneStatus.reached);
      });

      test('returns missed when past and actual < target', () {
        final result = MilestoneEngine.determineStatus(
          currentAge: 40,
          milestoneAge: 30,
          targetAmountPaise: 100000000,
          actualOrProjectedPaise: 80000000,
        );
        expect(result, MilestoneStatus.missed);
      });

      test('returns ahead when future and ratio >= 1.05', () {
        final result = MilestoneEngine.determineStatus(
          currentAge: 30,
          milestoneAge: 40,
          targetAmountPaise: 100000000,
          actualOrProjectedPaise: 110000000,
        );
        expect(result, MilestoneStatus.ahead);
      });

      test('returns onTrack when future and ratio >= 0.90', () {
        final result = MilestoneEngine.determineStatus(
          currentAge: 30,
          milestoneAge: 40,
          targetAmountPaise: 100000000,
          actualOrProjectedPaise: 95000000,
        );
        expect(result, MilestoneStatus.onTrack);
      });

      test('returns behind when future and ratio < 0.90', () {
        final result = MilestoneEngine.determineStatus(
          currentAge: 30,
          milestoneAge: 40,
          targetAmountPaise: 100000000,
          actualOrProjectedPaise: 70000000,
        );
        expect(result, MilestoneStatus.behind);
      });
    });

    group('defaultTargets', () {
      test('returns targets for decade ages after current age', () {
        final targets = MilestoneEngine.defaultTargets(
          currentNwPaise: 100000000,
          currentAge: 25,
          monthlySavingsPaise: 5000000,
          annualReturnRate: 0.10,
        );

        // Should include ages 30, 40, 50, 60, 70 (all > 25)
        expect(targets.length, 5);
        expect(targets.map((t) => t.age).toList(), [30, 40, 50, 60, 70]);

        // Each projection should be > 0
        for (final t in targets) {
          expect(t.projectedPaise, greaterThan(0));
        }

        // Each successive age should have larger projection
        for (int i = 1; i < targets.length; i++) {
          expect(
            targets[i].projectedPaise,
            greaterThan(targets[i - 1].projectedPaise),
          );
        }
      });

      test('filters out ages <= currentAge', () {
        final targets = MilestoneEngine.defaultTargets(
          currentNwPaise: 500000000,
          currentAge: 45,
          monthlySavingsPaise: 5000000,
          annualReturnRate: 0.10,
        );

        // Should only include 50, 60, 70
        expect(targets.length, 3);
        expect(targets.map((t) => t.age).toList(), [50, 60, 70]);
      });
    });
  });
}
