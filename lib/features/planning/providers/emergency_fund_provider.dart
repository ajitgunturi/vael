import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/financial/budget_summary.dart';
import '../../../core/financial/emergency_fund_engine.dart';
import '../../../core/providers/category_providers.dart';
import '../../../core/providers/database_providers.dart';
import '../../../core/providers/transaction_providers.dart';
import 'life_profile_provider.dart';

// ---------------------------------------------------------------------------
// Data class
// ---------------------------------------------------------------------------

/// Computed emergency fund state for display.
class EmergencyFundState {
  final int suggestedTargetMonths;

  /// Override or suggested.
  final int targetMonths;
  final int monthlyEssentialPaise;
  final int totalEfBalancePaise;
  final double coverageMonths;
  final int targetAmountPaise;

  /// Number of months of transaction data used for the average.
  final int monthsOfData;

  /// Whether the user has manually overridden the target months.
  final bool hasOverride;

  const EmergencyFundState({
    required this.suggestedTargetMonths,
    required this.targetMonths,
    required this.monthlyEssentialPaise,
    required this.totalEfBalancePaise,
    required this.coverageMonths,
    required this.targetAmountPaise,
    required this.monthsOfData,
    required this.hasOverride,
  });
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// Watches accounts flagged as emergency fund for a family.
final efAccountsProvider = StreamProvider.family<List<Account>, String>((
  ref,
  familyId,
) {
  final dao = ref.watch(accountDaoProvider);
  return dao.watchEmergencyFundAccounts(familyId);
});

/// Watches accounts that have a liquidity tier assigned.
final tierAccountsProvider = StreamProvider.family<List<Account>, String>((
  ref,
  familyId,
) {
  final dao = ref.watch(accountDaoProvider);
  return dao.watchByLiquidityTier(familyId);
});

/// Groups accounts by liquidity tier and sums balances.
///
/// Returns `{tier: totalBalancePaise}`. Balance-only aggregation (TIER-02).
final tierSummaryProvider = Provider.family<Map<String, int>, List<Account>>((
  ref,
  accounts,
) {
  final summary = <String, int>{};
  for (final a in accounts) {
    final tier = a.liquidityTier;
    if (tier == null) {
      continue; // defensive; tierAccountsProvider already filters
    }
    summary[tier] = (summary[tier] ?? 0) + a.balance;
  }
  return summary;
});

/// Computes rolling average of monthly essential expenses.
///
/// Returns a record with [monthlyAveragePaise] and [monthsUsed] (how many
/// months actually had data). The caller needs both: the average for the
/// fund computation, and the count for the short-history disclaimer.
final monthlyEssentialsProvider =
    FutureProvider.family<
      ({int monthlyAveragePaise, int monthsUsed}),
      ({String familyId, DateTime now})
    >((ref, params) async {
      final txDao = ref.watch(transactionDaoProvider);
      final catDao = ref.watch(categoryDaoProvider);
      final acctDao = ref.watch(accountDaoProvider);

      // Fetch all categories and accounts once.
      final categories = await catDao.getAll(params.familyId);
      final accounts = await acctDao.getAll(params.familyId);

      // Walk back up to 6 months and compute actuals for each.
      final monthlyActuals = <Map<String, int>>[];
      final now = params.now;

      for (int i = 0; i < 6; i++) {
        // Month boundaries: first day of month-i to last day of month-i.
        final year = now.month - i <= 0
            ? now.year - ((i - now.month + 1) ~/ 12 + 1)
            : now.year;
        final month = ((now.month - 1 - i) % 12) + 1;
        final start = DateTime(year, month);
        final end = DateTime(year, month + 1).subtract(const Duration(days: 1));

        final txns = await txDao.getByDateRange(params.familyId, start, end);
        if (txns.isEmpty) continue;

        final actuals = BudgetSummary.computeActualsByGroup(
          transactions: txns,
          categories: categories,
          accounts: accounts,
        );
        monthlyActuals.add(actuals);
      }

      final avg = EmergencyFundEngine.monthlyEssentialAverage(monthlyActuals);
      return (monthlyAveragePaise: avg, monthsUsed: monthlyActuals.length);
    });

/// Composite EF state for the detail screen.
final emergencyFundStateProvider =
    FutureProvider.family<
      EmergencyFundState,
      ({String userId, String familyId})
    >((ref, params) async {
      // Life profile for income stability and override.
      final profile = await ref.watch(
        lifeProfileProvider((
          userId: params.userId,
          familyId: params.familyId,
        )).future,
      );

      final incomeStability = profile?.incomeStability ?? 'salariedStable';
      final override = profile?.efTargetMonthsOverride;

      // Monthly essentials.
      final essentialsData = await ref.watch(
        monthlyEssentialsProvider((
          familyId: params.familyId,
          now: DateTime.now(),
        )).future,
      );
      final (:monthlyAveragePaise, :monthsUsed) = essentialsData;

      // EF accounts and total balance.
      final efAccounts = await ref.watch(
        efAccountsProvider(params.familyId).future,
      );
      final totalEfBalancePaise = efAccounts.fold<int>(
        0,
        (sum, a) => sum + a.balance,
      );

      // Engine computations.
      final suggestedMonths = EmergencyFundEngine.suggestedTargetMonths(
        incomeStability,
      );
      final targetMonths = override ?? suggestedMonths;
      final coverage = EmergencyFundEngine.coverageMonths(
        totalEfBalancePaise,
        monthlyAveragePaise,
      );
      final targetAmount = EmergencyFundEngine.targetAmountPaise(
        monthlyAveragePaise,
        targetMonths,
      );

      return EmergencyFundState(
        suggestedTargetMonths: suggestedMonths,
        targetMonths: targetMonths,
        monthlyEssentialPaise: monthlyAveragePaise,
        totalEfBalancePaise: totalEfBalancePaise,
        coverageMonths: coverage,
        targetAmountPaise: targetAmount,
        monthsOfData: monthsUsed,
        hasOverride: override != null,
      );
    });
