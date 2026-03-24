import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/financial/insights_engine.dart';
import '../../dashboard/providers/savings_rate_providers.dart';
import 'emergency_fund_provider.dart';
import 'planning_health_providers.dart';

/// Aggregates planning insights from multiple sources into a sorted list.
///
/// Watches emergency fund state and planning health. Reads previous month
/// yearsToFi from MonthlyMetrics for FI date slipping detection.
final insightsProvider =
    FutureProvider.family<
      List<PlanningInsight>,
      ({String familyId, String userId})
    >((ref, params) async {
      final insights = <PlanningInsight>[];

      // --- Emergency Fund alert ---
      final efAsync = ref.watch(
        emergencyFundStateProvider((
          userId: params.userId,
          familyId: params.familyId,
        )),
      );
      final efState = efAsync.value;
      if (efState != null && efState.totalEfBalancePaise > 0) {
        final efInsight = InsightsEngine.efBelowTarget(
          coverageMonths: efState.coverageMonths,
          targetMonths: efState.targetMonths,
        );
        if (efInsight != null) insights.add(efInsight);
      }

      // --- FI Date Slipping alert ---
      final healthAsync = ref.watch(
        planningHealthProvider((
          familyId: params.familyId,
          userId: params.userId,
        )),
      );
      final healthData = healthAsync.value;
      if (healthData != null && healthData.yearsToFi != null) {
        // Compute previous month string
        final now = DateTime.now();
        final prevDate = DateTime(now.year, now.month - 1, 1);
        final previousMonth =
            '${prevDate.year.toString().padLeft(4, '0')}-${prevDate.month.toString().padLeft(2, '0')}';

        // Read prior month yearsToFi from MonthlyMetrics
        final metricsDao = ref.read(monthlyMetricsDaoProvider);
        final priorMetric = await metricsDao.getByMonth(
          params.familyId,
          previousMonth,
        );

        final fiInsight = InsightsEngine.fiDateSlipping(
          currentYearsToFi: healthData.yearsToFi,
          previousYearsToFi: priorMetric?.yearsToFi,
        );
        if (fiInsight != null) insights.add(fiInsight);

        // Persist current yearsToFi to MonthlyMetrics for next month comparison
        final currentMonth =
            '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';
        final currentId = '${params.familyId}_$currentMonth';
        await metricsDao.updateYearsToFi(currentId, healthData.yearsToFi);
      }

      // Sort by severity: critical first, then warning, then info
      insights.sort((a, b) => a.severity.index.compareTo(b.severity.index));

      return insights;
    });
