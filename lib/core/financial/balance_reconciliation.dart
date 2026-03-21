/// Lightweight account balance input for reconciliation.
class AccountBalance {
  final String id;
  final String name;
  final int balance; // paise

  const AccountBalance({
    required this.id,
    required this.name,
    required this.balance,
  });
}

/// A single balance discrepancy.
class BalanceDiscrepancy {
  final String accountId;
  final String accountName;
  final int recordedBalance; // what the account table says
  final int computedBalance; // what transaction sums say
  /// Positive = recorded > computed (phantom money).
  /// Negative = recorded < computed (missing from balance).
  final int difference;

  const BalanceDiscrepancy({
    required this.accountId,
    required this.accountName,
    required this.recordedBalance,
    required this.computedBalance,
    required this.difference,
  });
}

/// Result of a reconciliation run.
class ReconciliationResult {
  final List<BalanceDiscrepancy> discrepancies;
  bool get isClean => discrepancies.isEmpty;

  const ReconciliationResult({required this.discrepancies});
}

/// Validates account balances against transaction sums.
///
/// Run on app foreground to catch drift between the stored balance
/// and the sum of all transaction deltas.
class BalanceReconciliation {
  BalanceReconciliation._();

  /// Compares each account's recorded balance to the computed sum.
  ///
  /// [transactionSums] maps accountId → net balance from transactions.
  /// Accounts not in the map are assumed to have computed balance of 0.
  static ReconciliationResult reconcile({
    required List<AccountBalance> accounts,
    required Map<String, int> transactionSums,
  }) {
    final discrepancies = <BalanceDiscrepancy>[];

    for (final account in accounts) {
      final computed = transactionSums[account.id] ?? 0;
      if (account.balance != computed) {
        discrepancies.add(
          BalanceDiscrepancy(
            accountId: account.id,
            accountName: account.name,
            recordedBalance: account.balance,
            computedBalance: computed,
            difference: account.balance - computed,
          ),
        );
      }
    }

    return ReconciliationResult(discrepancies: discrepancies);
  }
}

// --- Planning Insights ---

/// Monthly actual spending for drift detection.
class MonthlyActual {
  final int year;
  final int month;
  final int amount; // paise

  const MonthlyActual({
    required this.year,
    required this.month,
    required this.amount,
  });
}

enum DriftDirection { upward, downward, stable }

/// Budget drift analysis result.
class BudgetDriftResult {
  final bool isDrifting;
  final DriftDirection direction;
  final int averageOverspend; // paise (positive = over budget)
  final double trendPercent; // month-over-month average change %

  const BudgetDriftResult({
    required this.isDrifting,
    required this.direction,
    required this.averageOverspend,
    required this.trendPercent,
  });
}

/// Goal progress input for risk assessment.
class GoalProgress {
  final String id;
  final String name;
  final int targetAmount;
  final int currentSavings;
  final int monthsElapsed;
  final int totalMonths;

  const GoalProgress({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentSavings,
    required this.monthsElapsed,
    required this.totalMonths,
  });
}

enum RiskSeverity { moderate, high, critical }

/// A flagged at-risk goal.
class GoalRiskFlag {
  final String goalId;
  final String goalName;
  final RiskSeverity severity;
  final double progressPercent;
  final double expectedPercent;

  const GoalRiskFlag({
    required this.goalId,
    required this.goalName,
    required this.severity,
    required this.progressPercent,
    required this.expectedPercent,
  });
}

/// Detects budget drift and flags at-risk goals.
class PlanningInsights {
  PlanningInsights._();

  /// Detects budget drift over a rolling window (minimum 3 months).
  ///
  /// Drift is detected when:
  /// 1. Average spending exceeds budget by >5%
  /// 2. Spending shows a consistent upward trend (each month higher than previous)
  static BudgetDriftResult budgetDrift({
    required List<MonthlyActual> monthlyActuals,
    required int budgetLimit,
  }) {
    if (monthlyActuals.length < 3) {
      return const BudgetDriftResult(
        isDrifting: false,
        direction: DriftDirection.stable,
        averageOverspend: 0,
        trendPercent: 0,
      );
    }

    // Use last 3 months
    final recent = monthlyActuals.length > 3
        ? monthlyActuals.sublist(monthlyActuals.length - 3)
        : monthlyActuals;

    final avgSpend =
        recent.fold<int>(0, (s, m) => s + m.amount) ~/ recent.length;
    final avgOverspend = avgSpend - budgetLimit;

    // Compute trend: average month-over-month change
    double totalChange = 0;
    for (var i = 1; i < recent.length; i++) {
      if (recent[i - 1].amount > 0) {
        totalChange +=
            (recent[i].amount - recent[i - 1].amount) / recent[i - 1].amount;
      }
    }
    final trendPct = totalChange / (recent.length - 1) * 100;

    // Drift = average overspend > 5% of budget AND upward trend
    final overBudgetPct = budgetLimit > 0
        ? avgOverspend / budgetLimit * 100
        : 0.0;
    final isDrifting = overBudgetPct > 5 && trendPct > 0;

    final direction = isDrifting
        ? DriftDirection.upward
        : (trendPct < -5 ? DriftDirection.downward : DriftDirection.stable);

    return BudgetDriftResult(
      isDrifting: isDrifting,
      direction: direction,
      averageOverspend: avgOverspend,
      trendPercent: trendPct,
    );
  }

  /// Flags goals that are behind schedule.
  ///
  /// Severity:
  /// - critical: past deadline and not funded
  /// - high: <50% of expected linear progress
  /// - moderate: 50-80% of expected linear progress
  static List<GoalRiskFlag> flagAtRiskGoals({
    required List<GoalProgress> goals,
  }) {
    final flags = <GoalRiskFlag>[];

    for (final goal in goals) {
      if (goal.currentSavings >= goal.targetAmount) continue; // funded

      final progressPct = goal.targetAmount > 0
          ? goal.currentSavings / goal.targetAmount * 100
          : 0.0;

      // Overdue
      if (goal.monthsElapsed >= goal.totalMonths) {
        flags.add(
          GoalRiskFlag(
            goalId: goal.id,
            goalName: goal.name,
            severity: RiskSeverity.critical,
            progressPercent: progressPct,
            expectedPercent: 100,
          ),
        );
        continue;
      }

      final expectedPct = goal.totalMonths > 0
          ? goal.monthsElapsed / goal.totalMonths * 100
          : 0.0;

      final ratio = expectedPct > 0 ? progressPct / expectedPct : 1.0;

      if (ratio < 0.5) {
        flags.add(
          GoalRiskFlag(
            goalId: goal.id,
            goalName: goal.name,
            severity: RiskSeverity.high,
            progressPercent: progressPct,
            expectedPercent: expectedPct,
          ),
        );
      } else if (ratio < 0.8) {
        flags.add(
          GoalRiskFlag(
            goalId: goal.id,
            goalName: goal.name,
            severity: RiskSeverity.moderate,
            progressPercent: progressPct,
            expectedPercent: expectedPct,
          ),
        );
      }
    }

    return flags;
  }
}
