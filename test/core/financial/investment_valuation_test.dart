import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/financial/investment_valuation.dart';
import 'package:vael/core/models/enums.dart';

void main() {
  group('InvestmentValuation', () {
    group('defaultReturnRate', () {
      test('should return expected defaults for each bucket type', () {
        expect(
          InvestmentValuation.defaultReturnRate(BucketType.mutualFunds),
          0.12,
        );
        expect(InvestmentValuation.defaultReturnRate(BucketType.stocks), 0.14);
        expect(InvestmentValuation.defaultReturnRate(BucketType.ppf), 0.071);
        expect(InvestmentValuation.defaultReturnRate(BucketType.epf), 0.081);
        expect(InvestmentValuation.defaultReturnRate(BucketType.nps), 0.10);
        expect(
          InvestmentValuation.defaultReturnRate(BucketType.fixedDeposit),
          0.07,
        );
        expect(InvestmentValuation.defaultReturnRate(BucketType.bonds), 0.08);
        expect(InvestmentValuation.defaultReturnRate(BucketType.policy), 0.05);
      });
    });

    group('projectBucket', () {
      test('should project single bucket over 12 months at 12% annual', () {
        final projections = InvestmentValuation.projectBucket(
          currentValue: 100000000, // ₹10L
          monthlyContribution: 1000000, // ₹10K SIP
          annualReturnRate: 0.12,
          months: 12,
        );

        expect(projections.length, 12);
        // First month: 10L * (1 + 0.01) + 10K = ₹10,20,000 = 102000000 paise
        expect(projections[0], closeTo(102000000, 50000));
        // Values should monotonically increase
        for (var i = 1; i < projections.length; i++) {
          expect(projections[i], greaterThan(projections[i - 1]));
        }
      });

      test('should handle zero contribution', () {
        final projections = InvestmentValuation.projectBucket(
          currentValue: 100000000,
          monthlyContribution: 0,
          annualReturnRate: 0.12,
          months: 12,
        );

        // Pure compound growth
        expect(projections.last, closeTo(112682503, 10000));
      });

      test('should handle zero return rate', () {
        final projections = InvestmentValuation.projectBucket(
          currentValue: 100000000,
          monthlyContribution: 1000000,
          annualReturnRate: 0,
          months: 12,
        );

        // Just adding 10K/month
        expect(projections.last, 112000000);
      });
    });

    group('portfolioSummary', () {
      test('should compute total invested and current values', () {
        final buckets = [
          BucketData(
            type: BucketType.mutualFunds,
            investedAmount: 50000000,
            currentValue: 60000000,
          ),
          BucketData(
            type: BucketType.ppf,
            investedAmount: 20000000,
            currentValue: 25000000,
          ),
        ];

        final summary = InvestmentValuation.portfolioSummary(buckets);

        expect(summary.totalInvested, 70000000);
        expect(summary.totalCurrentValue, 85000000);
        expect(summary.totalGain, 15000000);
        expect(summary.overallReturnPercent, closeTo(21.43, 0.01));
      });

      test('should handle empty portfolio', () {
        final summary = InvestmentValuation.portfolioSummary([]);

        expect(summary.totalInvested, 0);
        expect(summary.totalCurrentValue, 0);
        expect(summary.totalGain, 0);
        expect(summary.overallReturnPercent, 0.0);
      });

      test('should handle portfolio with losses', () {
        final buckets = [
          BucketData(
            type: BucketType.stocks,
            investedAmount: 50000000,
            currentValue: 40000000,
          ),
        ];

        final summary = InvestmentValuation.portfolioSummary(buckets);

        expect(summary.totalGain, -10000000);
        expect(summary.overallReturnPercent, closeTo(-20.0, 0.01));
      });
    });

    group('projectPortfolio', () {
      test('should project multiple buckets and sum total', () {
        final buckets = [
          BucketData(
            type: BucketType.mutualFunds,
            investedAmount: 50000000,
            currentValue: 60000000,
            monthlyContribution: 500000,
            returnRate: 0.12,
          ),
          BucketData(
            type: BucketType.fixedDeposit,
            investedAmount: 20000000,
            currentValue: 20000000,
            monthlyContribution: 0,
            returnRate: 0.07,
          ),
        ];

        final projections = InvestmentValuation.projectPortfolio(
          buckets: buckets,
          months: 12,
        );

        expect(projections.length, 12);
        // Portfolio should grow
        expect(projections.last, greaterThan(80000000));
        // Should be sum of individual bucket projections
        for (var i = 0; i < 12; i++) {
          expect(projections[i], greaterThan(0));
        }
      });
    });

    group('goalCourseCorrection', () {
      test('should suggest SIP increase when behind target', () {
        final correction = InvestmentValuation.goalCourseCorrection(
          currentValue: 50000000, // ₹5L
          targetValue: 200000000, // ₹20L
          monthsRemaining: 60,
          currentMonthlySip: 100000, // ₹1K — too low
          expectedReturnRate: 0.12,
        );

        expect(correction.isOnTrack, false);
        expect(correction.suggestedMonthlySip, greaterThan(100000));
        expect(correction.projectedShortfall, greaterThan(0));
      });

      test('should report on track when SIP is sufficient', () {
        final correction = InvestmentValuation.goalCourseCorrection(
          currentValue: 150000000, // ₹15L
          targetValue: 200000000, // ₹20L
          monthsRemaining: 60,
          currentMonthlySip: 500000, // ₹5K — more than enough
          expectedReturnRate: 0.12,
        );

        expect(correction.isOnTrack, true);
        expect(correction.projectedShortfall, 0);
      });
    });
  });
}
