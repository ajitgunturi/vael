import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/financial/financial_math.dart';
import 'package:vael/core/financial/goal_tracking.dart';

void main() {
  group('GoalTracking', () {
    group('inflationAdjustedTarget', () {
      test('should adjust target for inflation over years', () {
        // ₹10,00,000 at 6% inflation for 5 years
        final adjusted = GoalTracking.inflationAdjustedTarget(
          targetAmount: 10000000, // ₹10,000 in paise
          inflationRate: 0.06,
          yearsToTarget: 5,
        );

        // 10000000 * (1.06)^5 = 13382256 (matches FinancialMath.inflationAdjust)
        final expected = FinancialMath.inflationAdjust(
          amount: 10000000,
          rate: 0.06,
          years: 5,
        );
        expect(adjusted, expected);
      });

      test('should return target unchanged when inflation is zero', () {
        final adjusted = GoalTracking.inflationAdjustedTarget(
          targetAmount: 10000000,
          inflationRate: 0.0,
          yearsToTarget: 5,
        );
        expect(adjusted, 10000000);
      });

      test('should return target unchanged when years is zero', () {
        final adjusted = GoalTracking.inflationAdjustedTarget(
          targetAmount: 10000000,
          inflationRate: 0.06,
          yearsToTarget: 0,
        );
        expect(adjusted, 10000000);
      });
    });

    group('requiredMonthlySip', () {
      test('should compute SIP needed to close gap', () {
        // Need ₹13,38,226 in 60 months at 12% annual (1% monthly)
        final sip = GoalTracking.requiredMonthlySip(
          inflationAdjustedTarget: 13382256,
          currentSavings: 0,
          monthsRemaining: 60,
          expectedMonthlyReturn: 0.01,
        );

        // gap = 13382256. requiredSip(13382256, 0.01, 60)
        final expected = FinancialMath.requiredSip(
          target: 13382256,
          rate: 0.01,
          months: 60,
        );
        expect(sip, expected);
      });

      test('should account for current savings (reduces gap)', () {
        const target = 10000000;
        const saved = 3000000;
        const months = 36;
        const rate = 0.01;

        final sip = GoalTracking.requiredMonthlySip(
          inflationAdjustedTarget: target,
          currentSavings: saved,
          monthsRemaining: months,
          expectedMonthlyReturn: rate,
        );

        // Current savings grow: FV of 3000000 at 1% for 36 months
        final fvSaved = FinancialMath.fv(
          rate: rate,
          nper: months,
          pmt: 0,
          pv: -saved,
        );
        final gap = target - fvSaved;
        final expected = FinancialMath.requiredSip(
          target: gap,
          rate: rate,
          months: months,
        );
        expect(sip, expected);
      });

      test('should return zero when already funded', () {
        final sip = GoalTracking.requiredMonthlySip(
          inflationAdjustedTarget: 5000000,
          currentSavings: 10000000,
          monthsRemaining: 60,
          expectedMonthlyReturn: 0.01,
        );

        expect(sip, 0);
      });

      test('should handle zero return rate', () {
        final sip = GoalTracking.requiredMonthlySip(
          inflationAdjustedTarget: 6000000,
          currentSavings: 0,
          monthsRemaining: 60,
          expectedMonthlyReturn: 0.0,
        );

        // Simple division: 6000000 / 60 = 100000
        expect(sip, 100000);
      });
    });

    group('inferStatus', () {
      test('should be completed when savings >= target', () {
        final status = GoalTracking.inferStatus(
          currentSavings: 10000000,
          inflationAdjustedTarget: 10000000,
          monthsRemaining: 12,
        );
        expect(status, GoalTrackingStatus.completed);
      });

      test('should be completed when savings exceed target', () {
        final status = GoalTracking.inferStatus(
          currentSavings: 15000000,
          inflationAdjustedTarget: 10000000,
          monthsRemaining: 0,
        );
        expect(status, GoalTrackingStatus.completed);
      });

      test('should be onTrack when progress is on schedule', () {
        // 60 month goal, 30 months elapsed (30 remaining), 55% saved
        // Expected: 50% at midpoint, actual 55% → on track
        final status = GoalTracking.inferStatus(
          currentSavings: 5500000,
          inflationAdjustedTarget: 10000000,
          monthsRemaining: 30,
          totalMonths: 60,
        );
        expect(status, GoalTrackingStatus.onTrack);
      });

      test('should be atRisk when significantly behind schedule', () {
        // 60 month goal, 30 months elapsed (30 remaining), only 20% saved
        // Expected: 50% at midpoint, actual 20% → at risk
        final status = GoalTracking.inferStatus(
          currentSavings: 2000000,
          inflationAdjustedTarget: 10000000,
          monthsRemaining: 30,
          totalMonths: 60,
        );
        expect(status, GoalTrackingStatus.atRisk);
      });

      test('should be active when no progress data (fresh goal)', () {
        final status = GoalTracking.inferStatus(
          currentSavings: 0,
          inflationAdjustedTarget: 10000000,
          monthsRemaining: 60,
          totalMonths: 60,
        );
        // At start, 0/60 elapsed, 0% expected → active (just started)
        expect(status, GoalTrackingStatus.active);
      });

      test('should be atRisk when deadline passed but not funded', () {
        final status = GoalTracking.inferStatus(
          currentSavings: 5000000,
          inflationAdjustedTarget: 10000000,
          monthsRemaining: 0,
          totalMonths: 60,
        );
        expect(status, GoalTrackingStatus.atRisk);
      });
    });

    group('GoalSnapshot', () {
      test('should compute full snapshot with all derived fields', () {
        final snapshot = GoalTracking.computeSnapshot(
          targetAmount: 10000000,
          currentSavings: 2000000,
          inflationRate: 0.06,
          yearsToTarget: 5,
          monthsRemaining: 60,
          totalMonths: 60,
          expectedMonthlyReturn: 0.01,
        );

        expect(snapshot.inflationAdjustedTarget, isPositive);
        expect(snapshot.inflationAdjustedTarget,
            greaterThan(10000000)); // inflation adds
        expect(snapshot.requiredMonthlySip, isPositive);
        expect(snapshot.status, isNotNull);
        expect(snapshot.progressPercent, greaterThanOrEqualTo(0.0));
        expect(snapshot.progressPercent, lessThanOrEqualTo(100.0));
      });

      test('should compute progress as percentage of adjusted target', () {
        final snapshot = GoalTracking.computeSnapshot(
          targetAmount: 10000000,
          currentSavings: 5000000,
          inflationRate: 0.0, // no inflation for easier assertion
          yearsToTarget: 0,
          monthsRemaining: 30,
          totalMonths: 60,
          expectedMonthlyReturn: 0.01,
        );

        // With 0 inflation and 0 years, adjusted = 10000000
        // Progress = 5000000 / 10000000 * 100 = 50%
        expect(snapshot.progressPercent, closeTo(50.0, 0.01));
      });
    });
  });
}
