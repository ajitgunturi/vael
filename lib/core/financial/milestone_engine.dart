import 'financial_math.dart';

/// Status of a net-worth milestone relative to current trajectory.
enum MilestoneStatus {
  /// Future milestone: projected >= 105% of target.
  ahead,

  /// Future milestone: projected >= 90% of target.
  onTrack,

  /// Future milestone: projected < 90% of target.
  behind,

  /// Past milestone: actual >= target.
  reached,

  /// Past milestone: actual < target.
  missed,
}

/// Pure static milestone projection engine.
///
/// All amounts are in **paise** (integer minor units).
/// Rates are decimals (e.g. 0.10 for 10%).
/// No DB imports, no mutable state, no async.
class MilestoneEngine {
  MilestoneEngine._();

  /// Projects net worth at [targetAge] given current portfolio and savings.
  ///
  /// Uses [FinancialMath.fv] for both the existing portfolio growth and
  /// the future value of the monthly savings annuity.
  ///
  /// Returns [currentNwPaise] if [targetAge] <= [currentAge].
  static int projectNetWorthAtAge({
    required int currentNwPaise,
    required int currentAge,
    required int targetAge,
    required int monthlySavingsPaise,
    required double annualReturnRate,
  }) {
    if (targetAge <= currentAge) return currentNwPaise;

    final years = targetAge - currentAge;
    final months = years * 12;
    final monthlyRate = annualReturnRate / 12;

    final fvPortfolio = FinancialMath.fv(
      rate: monthlyRate,
      nper: months,
      pmt: 0,
      pv: -currentNwPaise,
    );

    final fvSavings = FinancialMath.fv(
      rate: monthlyRate,
      nper: months,
      pmt: -monthlySavingsPaise,
    );

    return fvPortfolio + fvSavings;
  }

  /// Determines the status of a milestone based on age and amount.
  ///
  /// For past milestones ([currentAge] >= [milestoneAge]):
  /// - [reached] if [actualOrProjectedPaise] >= [targetAmountPaise]
  /// - [missed] otherwise
  ///
  /// For future milestones:
  /// - [ahead] if ratio >= 1.05
  /// - [onTrack] if ratio >= 0.90
  /// - [behind] otherwise
  static MilestoneStatus determineStatus({
    required int currentAge,
    required int milestoneAge,
    required int targetAmountPaise,
    required int actualOrProjectedPaise,
  }) {
    if (currentAge >= milestoneAge) {
      return actualOrProjectedPaise >= targetAmountPaise
          ? MilestoneStatus.reached
          : MilestoneStatus.missed;
    }

    final ratio = targetAmountPaise > 0
        ? actualOrProjectedPaise / targetAmountPaise
        : 1.0;

    if (ratio >= 1.05) return MilestoneStatus.ahead;
    if (ratio >= 0.90) return MilestoneStatus.onTrack;
    return MilestoneStatus.behind;
  }

  /// Generates default milestone targets for decade ages.
  ///
  /// Projects net worth at ages [30, 40, 50, 60, 70], filtering out
  /// ages <= [currentAge].
  static List<({int age, int projectedPaise})> defaultTargets({
    required int currentNwPaise,
    required int currentAge,
    required int monthlySavingsPaise,
    required double annualReturnRate,
  }) {
    const decadeAges = [30, 40, 50, 60, 70];
    return decadeAges
        .where((age) => age > currentAge)
        .map(
          (age) => (
            age: age,
            projectedPaise: projectNetWorthAtAge(
              currentNwPaise: currentNwPaise,
              currentAge: currentAge,
              targetAge: age,
              monthlySavingsPaise: monthlySavingsPaise,
              annualReturnRate: annualReturnRate,
            ),
          ),
        )
        .toList();
  }
}
