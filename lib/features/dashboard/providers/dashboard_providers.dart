import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/daos/account_dao.dart';
import '../../../core/database/daos/transaction_dao.dart';
import '../../../core/financial/dashboard_aggregation.dart';
import '../../../core/providers/database_providers.dart';

/// Toggle between family-wide and personal dashboard scope.
final dashboardScopeProvider = StateProvider<DashboardScope>(
  (ref) => DashboardScope.family,
);

/// Combined dashboard data: grouped accounts, net worth, monthly summary,
/// savings rate, and net worth history for chart.
class DashboardData {
  final AccountGroups grouped;
  final int netWorth;
  final MonthlySummary monthlySummary;
  final double savingsRate;
  final List<({DateTime date, int netWorth})> netWorthHistory;

  const DashboardData({
    required this.grouped,
    required this.netWorth,
    required this.monthlySummary,
    this.savingsRate = 0.0,
    this.netWorthHistory = const [],
  });
}

/// Streams aggregated dashboard data for [familyId].
///
/// Combines account grouping, net worth, and monthly transaction summary.
/// Respects the current [dashboardScopeProvider] setting.
final dashboardDataProvider = StreamProvider.family<DashboardData, String>((
  ref,
  familyId,
) {
  final db = ref.watch(databaseProvider);
  final accountDao = AccountDao(db);
  final transactionDao = TransactionDao(db);
  final scope = ref.watch(dashboardScopeProvider);

  // Watch accounts reactively
  return accountDao.watchAll(familyId).asyncMap((accounts) async {
    // Apply scope filter
    final scoped = DashboardAggregation.filterByScope(accounts, scope: scope);

    final grouped = DashboardAggregation.groupAccounts(scoped);
    final netWorth = DashboardAggregation.computeNetWorth(scoped);

    // Fetch current month transactions
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final transactions = await transactionDao.getByDateRange(
      familyId,
      monthStart,
      monthEnd,
    );
    final summary = DashboardAggregation.monthlySummary(transactions);

    final savingsRate = DashboardAggregation.computeSavingsRate(summary);

    return DashboardData(
      grouped: grouped,
      netWorth: netWorth,
      monthlySummary: summary,
      savingsRate: savingsRate,
    );
  });
});
