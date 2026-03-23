/// Pure static computation engine for emergency fund and cash tier logic.
///
/// All amounts are in **paise** (integer minor units).
/// No DB imports, no mutable state, no async.
class EmergencyFundEngine {
  EmergencyFundEngine._();

  /// The CategoryGroup string keys considered essential expenses.
  /// Matches the DB groupName values used by
  /// BudgetSummary.computeActualsByGroup output (uppercase slug format).
  static const essentialGroups = {
    'ESSENTIAL',
    'HOME_EXPENSES',
    'LIVING_EXPENSE',
  };

  /// Rolling average of essential expenses in paise.
  ///
  /// [monthlyActuals] is a list of per-month {groupName: paiseAmount} maps
  /// (as returned by BudgetSummary.computeActualsByGroup).
  /// Uses all available months. Returns 0 if the list is empty.
  static int monthlyEssentialAverage(List<Map<String, int>> monthlyActuals) {
    if (monthlyActuals.isEmpty) return 0;

    int totalPaise = 0;
    for (final month in monthlyActuals) {
      for (final entry in month.entries) {
        if (essentialGroups.contains(entry.key)) {
          totalPaise += entry.value;
        }
      }
    }
    return totalPaise ~/ monthlyActuals.length;
  }

  /// Suggested EF target months based on income stability string.
  ///
  /// salariedStable=3, salariedVariable=6, freelance=9, selfEmployed=12.
  /// Returns 6 as safe default for unknown values.
  static int suggestedTargetMonths(String incomeStability) {
    return switch (incomeStability) {
      'salariedStable' => 3,
      'salariedVariable' => 6,
      'freelance' => 9,
      'selfEmployed' => 12,
      _ => 6,
    };
  }

  /// Coverage months = totalEfBalancePaise / monthlyEssentialPaise.
  ///
  /// Returns 0.0 if monthlyEssentialPaise <= 0.
  static double coverageMonths(
    int totalEfBalancePaise,
    int monthlyEssentialPaise,
  ) {
    if (monthlyEssentialPaise <= 0) return 0.0;
    return totalEfBalancePaise / monthlyEssentialPaise;
  }

  /// Target emergency fund amount = monthlyEssentialPaise * targetMonths.
  static int targetAmountPaise(int monthlyEssentialPaise, int targetMonths) {
    return monthlyEssentialPaise * targetMonths;
  }

  /// Optimal tier distribution: 1 month instant, 2 months short-term, rest long-term.
  ///
  /// Returns {instant: N, shortTerm: N, longTerm: N} where values are month counts.
  static Map<String, int> suggestTierDistribution({required int targetMonths}) {
    final instant = targetMonths >= 1 ? 1 : 0;
    final remaining = targetMonths - instant;
    final shortTerm = remaining >= 2 ? 2 : remaining;
    final longTerm = remaining - shortTerm;

    return {
      'instant': instant,
      'shortTerm': shortTerm,
      'longTerm': longTerm < 0 ? 0 : longTerm,
    };
  }

  /// Auto-suggest liquidity tier based on AccountType string.
  ///
  /// savings/current/wallet -> 'instant', investment -> 'longTerm'.
  /// creditCard/loan -> null (not suitable for EF).
  static String? suggestTier(String accountType) {
    return switch (accountType) {
      'savings' || 'current' || 'wallet' => 'instant',
      'investment' => 'longTerm',
      _ => null,
    };
  }
}
