import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/daos/monthly_metrics_dao.dart';
import '../../../core/database/daos/transaction_dao.dart';
import '../../../core/database/database.dart';
import '../../../core/financial/dashboard_aggregation.dart';
import '../../../core/financial/sinking_fund_engine.dart';
import '../../../core/providers/database_providers.dart';

/// Provides [MonthlyMetricsDao] from the app database.
final monthlyMetricsDaoProvider = Provider<MonthlyMetricsDao>((ref) {
  return MonthlyMetricsDao(ref.watch(databaseProvider));
});

/// Computes and caches up to 12 months of savings rate metrics for [familyId].
///
/// Current month is always recomputed. Prior months use cache if available
/// and computedAt is recent enough. Returns metrics sorted by month ascending.
final savingsRateMetricsProvider =
    FutureProvider.family<List<MonthlyMetric>, String>((ref, familyId) async {
      final metricsDao = ref.watch(monthlyMetricsDaoProvider);
      final transactionDao = TransactionDao(ref.watch(databaseProvider));

      final now = DateTime.now();
      final currentMonth = _monthKey(now.year, now.month);

      // Build list of target months (current + 11 prior)
      final targetMonths = <String>[];
      for (var i = 11; i >= 0; i--) {
        final date = DateTime(now.year, now.month - i, 1);
        targetMonths.add(_monthKey(date.year, date.month));
      }

      // Fetch cached metrics
      final cached = await metricsDao.getRecent(familyId, 12);
      final cacheMap = <String, MonthlyMetric>{};
      for (final m in cached) {
        cacheMap[m.month] = m;
      }

      final results = <MonthlyMetric>[];

      for (final month in targetMonths) {
        final isCurrentMonth = month == currentMonth;

        // Use cache for prior months if available
        if (!isCurrentMonth && cacheMap.containsKey(month)) {
          results.add(cacheMap[month]!);
          continue;
        }

        // Compute fresh for current month or missing cache
        final parts = month.split('-');
        final year = int.parse(parts[0]);
        final mon = int.parse(parts[1]);
        final monthStart = DateTime(year, mon, 1);
        final monthEnd = DateTime(year, mon + 1, 0, 23, 59, 59);

        final transactions = await transactionDao.getByDateRange(
          familyId,
          monthStart,
          monthEnd,
        );

        final summary = DashboardAggregation.monthlySummary(transactions);
        final rateBp = SinkingFundEngine.savingsRateBp(
          summary.totalIncome,
          summary.totalExpenses,
        );

        final id = '${familyId}_$month';
        final computedAt = DateTime.now();

        // Upsert into cache
        await metricsDao.upsert(
          MonthlyMetricsCompanion(
            id: Value(id),
            familyId: Value(familyId),
            month: Value(month),
            totalIncomePaise: Value(summary.totalIncome),
            totalExpensesPaise: Value(summary.totalExpenses),
            savingsRateBp: Value(rateBp),
            netWorthPaise: const Value(0), // net worth tracked separately
            computedAt: Value(computedAt),
          ),
        );

        // Re-fetch to get the drift-generated object
        final metric = await metricsDao.getByMonth(familyId, month);
        if (metric != null) {
          results.add(metric);
        }
      }

      // Sort ascending by month
      results.sort((a, b) => a.month.compareTo(b.month));
      return results;
    });

/// Extracts the current month savings rate as a percentage from cached metrics.
final currentMonthRateProvider = Provider.family<double, String>((
  ref,
  familyId,
) {
  final metricsAsync = ref.watch(savingsRateMetricsProvider(familyId));
  return metricsAsync.when(
    data: (metrics) {
      if (metrics.isEmpty) return 0.0;
      final now = DateTime.now();
      final currentMonth = _monthKey(now.year, now.month);
      final current = metrics.where((m) => m.month == currentMonth);
      if (current.isEmpty) return 0.0;
      return current.first.savingsRateBp / 100.0;
    },
    loading: () => 0.0,
    error: (_, _) => 0.0,
  );
});

/// Formats a year/month pair as YYYY-MM.
String _monthKey(int year, int month) {
  return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';
}
