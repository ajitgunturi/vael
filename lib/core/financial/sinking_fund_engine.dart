/// Pure static computation engine for sinking fund and savings rate logic.
///
/// All amounts are in **paise** (integer minor units).
/// Rates are in **basis points** (1 bp = 0.01%).
/// No DB imports, no mutable state, no async.
class SinkingFundEngine {
  SinkingFundEngine._();

  /// Monthly contribution needed to reach target on time (paise).
  ///
  /// Uses ceiling division so the last month never exceeds the needed amount.
  /// Returns 0 if the fund is already met or has expired.
  static int monthlyNeededPaise(
    int targetPaise,
    int currentPaise,
    int monthsRemaining,
  ) {
    if (currentPaise >= targetPaise) return 0;
    if (monthsRemaining <= 0) return 0;
    final remaining = targetPaise - currentPaise;
    return (remaining + monthsRemaining - 1) ~/ monthsRemaining;
  }

  /// Pace status relative to linear savings trajectory.
  ///
  /// Returns 'onTrack' if current >= linear expected amount,
  /// 'behind' if current >= 50% of expected, 'atRisk' otherwise.
  /// Fresh funds (monthsElapsed=0 or totalMonths=0) return 'onTrack'.
  static String paceStatus(
    int targetPaise,
    int currentPaise,
    int totalMonths,
    int monthsElapsed,
  ) {
    if (totalMonths <= 0 || monthsElapsed <= 0) return 'onTrack';
    final expected = targetPaise * monthsElapsed ~/ totalMonths;
    if (currentPaise >= expected) return 'onTrack';
    if (currentPaise >= expected ~/ 2) return 'behind';
    return 'atRisk';
  }

  /// Savings rate in basis points: (income - expenses) * 10000 / income.
  ///
  /// Returns 0 if income is 0.
  static int savingsRateBp(int incomePaise, int expensesPaise) {
    if (incomePaise == 0) return 0;
    return (incomePaise - expensesPaise) * 10000 ~/ incomePaise;
  }

  /// Days until target date. Returns 0 if target is in the past or today.
  static int daysRemaining(DateTime targetDate, DateTime now) {
    final diff = targetDate.difference(now).inDays;
    return diff > 0 ? diff : 0;
  }

  /// Whether the sinking fund has reached its target.
  static bool isComplete(int currentPaise, int targetPaise) {
    return currentPaise >= targetPaise;
  }
}
