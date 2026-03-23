import 'dart:math' as math;

import 'fi_calculator.dart';
import 'financial_math.dart';

/// Result of a purchase impact analysis on FI timeline.
class PurchaseImpact {
  /// Years to FI before the purchase.
  final int fiYearsBefore;

  /// Years to FI after the purchase (-1 if unreachable).
  final int fiYearsAfter;

  /// Delay in years caused by the purchase (-1 if FI becomes unreachable).
  final int fiDelayYears;

  /// Down payment amount in paise.
  final int downPaymentPaise;

  /// Monthly EMI in paise (0 if no loan).
  final int monthlyEmiPaise;

  const PurchaseImpact({
    required this.fiYearsBefore,
    required this.fiYearsAfter,
    required this.fiDelayYears,
    required this.downPaymentPaise,
    required this.monthlyEmiPaise,
  });
}

/// Pure static purchase planning engine.
///
/// Computes the impact of a major purchase on the FI timeline.
/// Composes [FiCalculator] and [FinancialMath] — no DB access, no async.
/// All amounts are in **paise** (integer minor units).
class PurchasePlannerEngine {
  PurchasePlannerEngine._();

  /// Computes the FI delay caused by a purchase.
  ///
  /// [purchaseAmountPaise] total purchase cost in paise.
  /// [downPaymentBp] down payment as basis points of purchase (10000 = 100%).
  /// [loanTenureMonths] and [loanInterestRate] are optional (null = no loan).
  static PurchaseImpact computeImpact({
    required int purchaseAmountPaise,
    required int downPaymentBp,
    required int currentPortfolioPaise,
    required int monthlySavingsPaise,
    required int annualExpensesPaise,
    required double annualReturnRate,
    required double swr,
    required double inflationRate,
    required int yearsToRetirement,
    int? loanTenureMonths,
    double? loanInterestRate,
  }) {
    // 1. Baseline FI computation.
    final fiNumber = FiCalculator.computeFiNumber(
      annualExpensesPaise: annualExpensesPaise,
      swr: swr,
      inflationRate: inflationRate,
      yearsToRetirement: yearsToRetirement,
    );

    final baselineYears = FiCalculator.yearsToFi(
      currentPortfolioPaise: currentPortfolioPaise,
      monthlySavingsPaise: monthlySavingsPaise,
      annualReturnRate: annualReturnRate,
      fiNumberPaise: fiNumber,
    );

    // 2. Down payment reduces portfolio.
    final downPayment = (purchaseAmountPaise * downPaymentBp / 10000).round();
    final afterPortfolio = math.max(0, currentPortfolioPaise - downPayment);

    // 3. Loan EMI reduces monthly savings.
    int emi = 0;
    if (loanTenureMonths != null &&
        loanInterestRate != null &&
        downPaymentBp < 10000) {
      final loanPrincipal = purchaseAmountPaise - downPayment;
      emi = FinancialMath.pmt(
        rate: loanInterestRate / 12,
        nper: loanTenureMonths,
        pv: -loanPrincipal,
      ).abs();
    }

    final afterMonthlySavings = math.max(0, monthlySavingsPaise - emi);

    // 4. Post-purchase FI computation.
    final afterYears = FiCalculator.yearsToFi(
      currentPortfolioPaise: afterPortfolio,
      monthlySavingsPaise: afterMonthlySavings,
      annualReturnRate: annualReturnRate,
      fiNumberPaise: fiNumber,
    );

    final delay = afterYears == -1 ? -1 : afterYears - baselineYears;

    return PurchaseImpact(
      fiYearsBefore: baselineYears,
      fiYearsAfter: afterYears,
      fiDelayYears: delay,
      downPaymentPaise: downPayment,
      monthlyEmiPaise: emi,
    );
  }

  /// Computes the education cost at a future year with annual escalation.
  ///
  /// [baseCostPaise] current cost in paise.
  /// [escalationRateBp] annual escalation in basis points (1000 = 10%).
  /// [years] number of years into the future.
  static int educationCostAtYear({
    required int baseCostPaise,
    required int escalationRateBp,
    required int years,
  }) {
    if (years == 0 || escalationRateBp == 0) return baseCostPaise;
    final rate = escalationRateBp / 10000;
    return (baseCostPaise * math.pow(1 + rate, years)).round();
  }
}
