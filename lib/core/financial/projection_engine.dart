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

/// A recurring cash flow source consumed by the projection engine.
class ProjectionCashFlow {
  final String name;
  final int monthlyAmount; // paise
  final bool isIncome; // true = income, false = expense
  final int? durationMonths; // null = indefinite
  final double annualEscalation; // e.g. 0.10 for 10%

  const ProjectionCashFlow({
    required this.name,
    required this.monthlyAmount,
    required this.isIncome,
    this.durationMonths,
    this.annualEscalation = 0,
  });
}

/// Forward-stepping 60-month financial projection engine.
///
/// Pure function: no DB access. Takes current state and growth assumptions,
/// produces monthly net worth trajectory.
///
/// Can optionally consume recurring cash flows (from recurring rules) to
/// produce data-driven projections instead of flat assumptions.
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

  /// Projects net worth using actual recurring cash flows from the DB.
  ///
  /// Instead of flat monthlyIncome/monthlyExpenses, this method consumes
  /// structured [ProjectionCashFlow] sources (derived from recurring rules,
  /// salary, EMIs, SIPs, etc.) and applies per-source escalation rates.
  static ProjectionResult projectFromCashFlows({
    required int startingNetWorth,
    required List<ProjectionCashFlow> cashFlows,
    double investmentReturnRate = 0.10,
    int horizonMonths = 60,
  }) {
    final monthlyReturn = investmentReturnRate / 12;
    final snapshots = <ProjectionSnapshot>[];

    double runningNW = startingNetWorth.toDouble();

    for (var m = 1; m <= horizonMonths; m++) {
      // Investment returns compound on positive net worth
      if (runningNW > 0 && monthlyReturn > 0) {
        runningNW *= (1 + monthlyReturn);
      }

      int totalIncome = 0;
      int totalExpenses = 0;

      for (final cf in cashFlows) {
        // Check duration
        if (cf.durationMonths != null && m > cf.durationMonths!) continue;

        // Apply annual escalation
        final yearsElapsed = (m - 1) ~/ 12;
        final escalated =
            (cf.monthlyAmount * math.pow(1 + cf.annualEscalation, yearsElapsed))
                .round();

        if (cf.isIncome) {
          totalIncome += escalated;
        } else {
          totalExpenses += escalated;
        }
      }

      final savings = totalIncome - totalExpenses;
      runningNW += savings;

      snapshots.add(
        ProjectionSnapshot(
          month: m,
          netWorth: runningNW.round(),
          monthlyIncome: totalIncome,
          monthlyExpenses: totalExpenses,
          monthlySavings: savings,
        ),
      );
    }

    return ProjectionResult(months: snapshots);
  }

  /// Generates three scenarios from cash flows with return rate spreads.
  static ThreeScenarioResult threeScenariosCashFlow({
    required int startingNetWorth,
    required List<ProjectionCashFlow> cashFlows,
    double baseReturnRate = 0.10,
    int horizonMonths = 60,
  }) {
    return ThreeScenarioResult(
      optimistic: projectFromCashFlows(
        startingNetWorth: startingNetWorth,
        cashFlows: cashFlows,
        investmentReturnRate: baseReturnRate + 0.02,
        horizonMonths: horizonMonths,
      ),
      base: projectFromCashFlows(
        startingNetWorth: startingNetWorth,
        cashFlows: cashFlows,
        investmentReturnRate: baseReturnRate,
        horizonMonths: horizonMonths,
      ),
      pessimistic: projectFromCashFlows(
        startingNetWorth: startingNetWorth,
        cashFlows: cashFlows,
        investmentReturnRate: math.max(0, baseReturnRate - 0.02),
        horizonMonths: horizonMonths,
      ),
    );
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
