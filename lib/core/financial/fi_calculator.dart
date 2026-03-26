import 'financial_math.dart';

/// Pure static FI (Financial Independence) math engine.
///
/// All amounts are in **paise** (integer minor units).
/// Rates are decimals (e.g. 0.06 for 6%).
/// No DB imports, no mutable state, no async.
class FiCalculator {
  FiCalculator._();

  /// Computes the FI number: inflation-adjusted annual expenses divided by SWR.
  ///
  /// Returns the corpus needed at retirement to sustain [annualExpensesPaise]
  /// indefinitely at the given [swr] (safe withdrawal rate).
  ///
  /// Guards: returns 0 if [swr] <= 0.
  static int computeFiNumber({
    required int annualExpensesPaise,
    required double swr,
    required double inflationRate,
    required int yearsToRetirement,
  }) {
    if (swr <= 0) return 0;

    final adjusted = FinancialMath.inflationAdjust(
      amount: annualExpensesPaise,
      rate: inflationRate,
      years: yearsToRetirement,
    );

    return (adjusted / swr).round();
  }

  /// Estimates years to reach FI number via monthly compounding.
  ///
  /// Iterates month-by-month up to 1200 months (100 years).
  /// Returns 0 if [currentPortfolioPaise] >= [fiNumberPaise].
  /// Returns -1 if unreachable within 100 years.
  static int yearsToFi({
    required int currentPortfolioPaise,
    required int monthlySavingsPaise,
    required double annualReturnRate,
    required int fiNumberPaise,
  }) {
    if (currentPortfolioPaise >= fiNumberPaise) return 0;
    if (monthlySavingsPaise <= 0 && annualReturnRate <= 0) return -1;

    final monthlyRate = annualReturnRate / 12;
    double portfolio = currentPortfolioPaise.toDouble();

    for (int m = 1; m <= 1200; m++) {
      portfolio = portfolio * (1 + monthlyRate) + monthlySavingsPaise;
      if (portfolio >= fiNumberPaise) {
        return (m / 12).ceil();
      }
    }

    return -1;
  }

  /// Computes the Coast FI number: the present value of the FI number.
  ///
  /// This is the amount you need today such that, with no further savings
  /// and compounding at [annualReturnRate], you reach [fiNumberPaise] in
  /// [yearsToRetirement] years.
  ///
  /// Returns [fiNumberPaise] if [yearsToRetirement] <= 0 or [annualReturnRate] <= 0.
  static int coastFi({
    required int fiNumberPaise,
    required double annualReturnRate,
    required int yearsToRetirement,
  }) {
    if (yearsToRetirement <= 0 || annualReturnRate <= 0) return fiNumberPaise;

    final growthFactor = FinancialMath.power(
      1 + annualReturnRate,
      yearsToRetirement.toDouble(),
    );
    return (fiNumberPaise / growthFactor).round();
  }
}
