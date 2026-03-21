import 'dart:math' as math;

/// A single month's projected financial state.
class ProjectionSnapshot {
  final int month;
  final int netWorth;
  final int monthlyIncome;
  final int monthlyExpenses;
  final int monthlySavings;

  const ProjectionSnapshot({
    required this.month,
    required this.netWorth,
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.monthlySavings,
  });
}

/// Result of a projection: list of monthly snapshots.
class ProjectionResult {
  final List<ProjectionSnapshot> months;

  const ProjectionResult({required this.months});
}

/// Three-scenario projection result.
class ThreeScenarioResult {
  final ProjectionResult optimistic;
  final ProjectionResult base;
  final ProjectionResult pessimistic;

  const ThreeScenarioResult({
    required this.optimistic,
    required this.base,
    required this.pessimistic,
  });
}

/// Forward-stepping 60-month financial projection engine.
///
/// Pure function: no DB access. Takes current state and growth assumptions,
/// produces monthly net worth trajectory.
///
/// Annual growth rates are applied at the start of each new year (month 13, 25, …).
/// Investment returns compound monthly on accumulated net worth.
/// All values in paise (integer minor units).
class ProjectionEngine {
  ProjectionEngine._();

  /// Projects net worth forward month-by-month.
  ///
  /// [startingNetWorth]     current net worth in paise
  /// [monthlyIncome]        current monthly income in paise
  /// [monthlyExpenses]      current monthly expenses in paise
  /// [monthlyEmi]           current monthly EMI in paise (default 0)
  /// [emiRemainingMonths]   months of EMI remaining (null = indefinite)
  /// [investmentReturnRate] annual return rate on accumulated assets (default 0.10)
  /// [expenseGrowthRate]    annual expense growth rate (default 0.06)
  /// [incomeGrowthRate]     annual income growth rate (default 0.08)
  /// [horizonMonths]        projection horizon (default 60)
  static ProjectionResult project({
    required int startingNetWorth,
    required int monthlyIncome,
    required int monthlyExpenses,
    int monthlyEmi = 0,
    int? emiRemainingMonths,
    double investmentReturnRate = 0.10,
    double expenseGrowthRate = 0.06,
    double incomeGrowthRate = 0.08,
    int horizonMonths = 60,
  }) {
    final monthlyReturn = investmentReturnRate / 12;
    final snapshots = <ProjectionSnapshot>[];

    double runningNW = startingNetWorth.toDouble();
    int currentIncome = monthlyIncome;
    int currentExpenses = monthlyExpenses;
    int emiMonthsLeft = emiRemainingMonths ?? horizonMonths;

    for (var m = 1; m <= horizonMonths; m++) {
      // Apply annual growth at the start of each new year (month 13, 25, …)
      if (m > 1 && (m - 1) % 12 == 0) {
        currentIncome = (currentIncome * (1 + incomeGrowthRate)).round();
        currentExpenses = (currentExpenses * (1 + expenseGrowthRate)).round();
      }

      // Investment returns compound on positive net worth only
      if (runningNW > 0 && monthlyReturn > 0) {
        runningNW *= (1 + monthlyReturn);
      }

      // Monthly cash flow
      final emi = emiMonthsLeft > 0 ? monthlyEmi : 0;
      final savings = currentIncome - currentExpenses - emi;
      runningNW += savings;
      if (emiMonthsLeft > 0) emiMonthsLeft--;

      snapshots.add(
        ProjectionSnapshot(
          month: m,
          netWorth: runningNW.round(),
          monthlyIncome: currentIncome,
          monthlyExpenses: currentExpenses,
          monthlySavings: savings,
        ),
      );
    }

    return ProjectionResult(months: snapshots);
  }

  /// Generates optimistic / base / pessimistic projections.
  ///
  /// Spreads: return rate ±2%, expense growth ∓1%, income growth ±1%.
  static ThreeScenarioResult threeScenarios({
    required int startingNetWorth,
    required int monthlyIncome,
    required int monthlyExpenses,
    int monthlyEmi = 0,
    int? emiRemainingMonths,
    double baseReturnRate = 0.10,
    double baseExpenseGrowth = 0.06,
    double baseIncomeGrowth = 0.08,
    int horizonMonths = 60,
  }) {
    final optimistic = project(
      startingNetWorth: startingNetWorth,
      monthlyIncome: monthlyIncome,
      monthlyExpenses: monthlyExpenses,
      monthlyEmi: monthlyEmi,
      emiRemainingMonths: emiRemainingMonths,
      investmentReturnRate: baseReturnRate + 0.02,
      expenseGrowthRate: math.max(0, baseExpenseGrowth - 0.01),
      incomeGrowthRate: baseIncomeGrowth + 0.01,
      horizonMonths: horizonMonths,
    );

    final base = project(
      startingNetWorth: startingNetWorth,
      monthlyIncome: monthlyIncome,
      monthlyExpenses: monthlyExpenses,
      monthlyEmi: monthlyEmi,
      emiRemainingMonths: emiRemainingMonths,
      investmentReturnRate: baseReturnRate,
      expenseGrowthRate: baseExpenseGrowth,
      incomeGrowthRate: baseIncomeGrowth,
      horizonMonths: horizonMonths,
    );

    final pessimistic = project(
      startingNetWorth: startingNetWorth,
      monthlyIncome: monthlyIncome,
      monthlyExpenses: monthlyExpenses,
      monthlyEmi: monthlyEmi,
      emiRemainingMonths: emiRemainingMonths,
      investmentReturnRate: math.max(0, baseReturnRate - 0.02),
      expenseGrowthRate: baseExpenseGrowth + 0.01,
      incomeGrowthRate: math.max(0, baseIncomeGrowth - 0.01),
      horizonMonths: horizonMonths,
    );

    return ThreeScenarioResult(
      optimistic: optimistic,
      base: base,
      pessimistic: pessimistic,
    );
  }
}
