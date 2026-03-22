import 'dart:math' as math;

import '../models/enums.dart';
import 'financial_math.dart';

/// Input data for a single investment bucket.
class BucketData {
  final BucketType type;
  final int investedAmount; // paise
  final int currentValue; // paise
  final int monthlyContribution; // paise (SIP)
  final double? returnRate; // annual, overrides default if set

  const BucketData({
    required this.type,
    required this.investedAmount,
    required this.currentValue,
    this.monthlyContribution = 0,
    this.returnRate,
  });

  double get effectiveReturnRate =>
      returnRate ?? InvestmentValuation.defaultReturnRate(type);
}

/// Portfolio-level summary.
class PortfolioSummary {
  final int totalInvested;
  final int totalCurrentValue;
  final int totalGain;
  final double overallReturnPercent;

  const PortfolioSummary({
    required this.totalInvested,
    required this.totalCurrentValue,
    required this.totalGain,
    required this.overallReturnPercent,
  });
}

/// Goal course correction result.
class CourseCorrection {
  final bool isOnTrack;
  final int projectedValue;
  final int projectedShortfall;
  final int suggestedMonthlySip;

  const CourseCorrection({
    required this.isOnTrack,
    required this.projectedValue,
    required this.projectedShortfall,
    required this.suggestedMonthlySip,
  });
}

/// Pure investment valuation and projection functions.
///
/// Buckets are purpose-driven containers (e.g. "retirement MFs", "education PPF")
/// — not individual holdings. Each has a type, invested amount, current value,
/// and expected return rate (defaulted per type, user-overridable).
class InvestmentValuation {
  InvestmentValuation._();

  /// Default annual return rates by bucket type (India-typical).
  static double defaultReturnRate(BucketType type) {
    return switch (type) {
      BucketType.mutualFunds => 0.12,
      BucketType.stocks => 0.14,
      BucketType.ppf => 0.071,
      BucketType.epf => 0.081,
      BucketType.nps => 0.10,
      BucketType.fixedDeposit => 0.07,
      BucketType.bonds => 0.08,
      BucketType.policy => 0.05,
    };
  }

  /// Returns the effective return rate using a 4-level priority:
  ///
  /// 1. [fixedRate] — user-specified fixed rate for a holding
  /// 2. [xirr] — computed XIRR from actual cash flows
  /// 3. [familyBaseline] — family-level baseline for the asset class
  /// 4. [defaultReturnRate] for [type] — India-typical defaults
  ///
  /// Returns the first non-null value in priority order.
  static double effectiveReturnRate({
    double? fixedRate,
    double? xirr,
    double? familyBaseline,
    required BucketType type,
  }) {
    return fixedRate ?? xirr ?? familyBaseline ?? defaultReturnRate(type);
  }

  /// Projects a single bucket's value forward month-by-month.
  ///
  /// Returns a list of projected values (paise) for each month.
  static List<int> projectBucket({
    required int currentValue,
    required int monthlyContribution,
    required double annualReturnRate,
    required int months,
  }) {
    final monthlyRate = annualReturnRate / 12;
    final projections = <int>[];
    double value = currentValue.toDouble();

    for (var m = 0; m < months; m++) {
      value = value * (1 + monthlyRate) + monthlyContribution;
      projections.add(value.round());
    }

    return projections;
  }

  /// Computes portfolio summary across all buckets.
  static PortfolioSummary portfolioSummary(List<BucketData> buckets) {
    if (buckets.isEmpty) {
      return const PortfolioSummary(
        totalInvested: 0,
        totalCurrentValue: 0,
        totalGain: 0,
        overallReturnPercent: 0.0,
      );
    }

    int invested = 0;
    int current = 0;
    for (final b in buckets) {
      invested += b.investedAmount;
      current += b.currentValue;
    }

    final gain = current - invested;
    final returnPct = invested > 0 ? (gain / invested) * 100 : 0.0;

    return PortfolioSummary(
      totalInvested: invested,
      totalCurrentValue: current,
      totalGain: gain,
      overallReturnPercent: returnPct,
    );
  }

  /// Projects total portfolio value forward by summing individual bucket projections.
  static List<int> projectPortfolio({
    required List<BucketData> buckets,
    required int months,
  }) {
    final totals = List<int>.filled(months, 0);

    for (final bucket in buckets) {
      final proj = projectBucket(
        currentValue: bucket.currentValue,
        monthlyContribution: bucket.monthlyContribution,
        annualReturnRate: bucket.effectiveReturnRate,
        months: months,
      );
      for (var i = 0; i < months; i++) {
        totals[i] += proj[i];
      }
    }

    return totals;
  }

  /// Evaluates whether current SIP pace reaches a goal, and suggests correction.
  static CourseCorrection goalCourseCorrection({
    required int currentValue,
    required int targetValue,
    required int monthsRemaining,
    required int currentMonthlySip,
    required double expectedReturnRate,
  }) {
    if (monthsRemaining <= 0) {
      return CourseCorrection(
        isOnTrack: currentValue >= targetValue,
        projectedValue: currentValue,
        projectedShortfall: math.max(0, targetValue - currentValue),
        suggestedMonthlySip: 0,
      );
    }

    // Project forward with current SIP
    final projections = projectBucket(
      currentValue: currentValue,
      monthlyContribution: currentMonthlySip,
      annualReturnRate: expectedReturnRate,
      months: monthsRemaining,
    );
    final projectedValue = projections.last;
    final shortfall = math.max(0, targetValue - projectedValue);
    final isOnTrack = projectedValue >= targetValue;

    // Compute required SIP if not on track
    int suggestedSip = currentMonthlySip;
    if (!isOnTrack) {
      // FV of current value at expected rate
      final fvCurrent = FinancialMath.fv(
        rate: expectedReturnRate / 12,
        nper: monthsRemaining,
        pmt: 0,
        pv: -currentValue,
      );
      final gap = targetValue - fvCurrent;
      if (gap > 0) {
        suggestedSip = FinancialMath.requiredSip(
          target: gap,
          rate: expectedReturnRate / 12,
          months: monthsRemaining,
        );
      }
    }

    return CourseCorrection(
      isOnTrack: isOnTrack,
      projectedValue: projectedValue,
      projectedShortfall: shortfall,
      suggestedMonthlySip: isOnTrack ? currentMonthlySip : suggestedSip,
    );
  }
}
