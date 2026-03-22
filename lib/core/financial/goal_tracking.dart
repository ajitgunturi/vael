import 'financial_math.dart';

/// Goal tracking status — computed from progress vs timeline.
enum GoalTrackingStatus { active, onTrack, atRisk, completed }

/// Point-in-time snapshot of a goal's computed state.
class GoalSnapshot {
  final int inflationAdjustedTarget;
  final int requiredMonthlySip;
  final GoalTrackingStatus status;
  final double progressPercent;

  const GoalSnapshot({
    required this.inflationAdjustedTarget,
    required this.requiredMonthlySip,
    required this.status,
    required this.progressPercent,
  });
}

/// Pure goal tracking computations.
///
/// All functions are stateless — no DB access. The caller provides
/// current savings, target, and timeline; this class computes derived state.
class GoalTracking {
  GoalTracking._();

  /// Adjusts target for inflation. Delegates to [FinancialMath.inflationAdjust].
  static int inflationAdjustedTarget({
    required int targetAmount,
    required double inflationRate,
    required int yearsToTarget,
  }) {
    return FinancialMath.inflationAdjust(
      amount: targetAmount,
      rate: inflationRate,
      years: yearsToTarget,
    );
  }

  /// Computes the monthly SIP needed to reach the inflation-adjusted target,
  /// accounting for existing savings that will compound.
  ///
  /// If current savings already cover the target (after compounding),
  /// returns 0.
  static int requiredMonthlySip({
    required int inflationAdjustedTarget,
    required int currentSavings,
    required int monthsRemaining,
    required double expectedMonthlyReturn,
  }) {
    if (monthsRemaining <= 0) return 0;

    // Future value of current savings
    final fvSavings = FinancialMath.fv(
      rate: expectedMonthlyReturn,
      nper: monthsRemaining,
      pmt: 0,
      pv: -currentSavings,
    );

    final gap = inflationAdjustedTarget - fvSavings;
    if (gap <= 0) return 0;

    return FinancialMath.requiredSip(
      target: gap,
      rate: expectedMonthlyReturn,
      months: monthsRemaining,
    );
  }

  /// Infers goal status from progress vs timeline.
  ///
  /// - [completed]: savings >= target
  /// - [active]: just started (no elapsed time)
  /// - [onTrack]: progress % >= expected % for elapsed time
  /// - [atRisk]: significantly behind schedule
  ///
  /// The threshold for atRisk is: actual progress < 80% of expected progress.
  static GoalTrackingStatus inferStatus({
    required int currentSavings,
    required int inflationAdjustedTarget,
    required int monthsRemaining,
    int? totalMonths,
  }) {
    // Funded
    if (currentSavings >= inflationAdjustedTarget) {
      return GoalTrackingStatus.completed;
    }

    // Deadline passed but not funded
    if (monthsRemaining <= 0) {
      return GoalTrackingStatus.atRisk;
    }

    // Can't determine on-track/at-risk without total timeline
    if (totalMonths == null || totalMonths <= 0) {
      return GoalTrackingStatus.active;
    }

    final monthsElapsed = totalMonths - monthsRemaining;

    // Just started — no meaningful progress expected yet
    if (monthsElapsed <= 0) {
      return GoalTrackingStatus.active;
    }

    // Linear expected progress (simplified — ignores compounding for status)
    final expectedProgress = monthsElapsed / totalMonths;
    final actualProgress = currentSavings / inflationAdjustedTarget;

    // On track if actual >= 80% of expected linear progress
    if (actualProgress >= expectedProgress * 0.8) {
      return GoalTrackingStatus.onTrack;
    }

    return GoalTrackingStatus.atRisk;
  }

  /// Computes a full goal snapshot with all derived fields.
  ///
  /// [linkedInvestmentValue] — if the goal has linked investment holdings,
  /// pass their aggregate currentValue (paise). It is added to
  /// [currentSavings] when computing progress, SIP requirement, and status.
  static GoalSnapshot computeSnapshot({
    required int targetAmount,
    required int currentSavings,
    required double inflationRate,
    required int yearsToTarget,
    required int monthsRemaining,
    required int totalMonths,
    required double expectedMonthlyReturn,
    int linkedInvestmentValue = 0,
  }) {
    final effectiveSavings = currentSavings + linkedInvestmentValue;

    final adjusted = inflationAdjustedTarget(
      targetAmount: targetAmount,
      inflationRate: inflationRate,
      yearsToTarget: yearsToTarget,
    );

    final sip = requiredMonthlySip(
      inflationAdjustedTarget: adjusted,
      currentSavings: effectiveSavings,
      monthsRemaining: monthsRemaining,
      expectedMonthlyReturn: expectedMonthlyReturn,
    );

    final status = inferStatus(
      currentSavings: effectiveSavings,
      inflationAdjustedTarget: adjusted,
      monthsRemaining: monthsRemaining,
      totalMonths: totalMonths,
    );

    final progress = adjusted > 0
        ? (effectiveSavings / adjusted * 100).clamp(0.0, 100.0)
        : 0.0;

    return GoalSnapshot(
      inflationAdjustedTarget: adjusted,
      requiredMonthlySip: sip,
      status: status,
      progressPercent: progress,
    );
  }
}
