import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/color_tokens.dart';
import '../../../shared/theme/spacing.dart';
import '../../../shared/utils/formatters.dart';
import '../../planning/providers/planning_health_providers.dart';
import '../../planning/screens/planning_dashboard_screen.dart';

/// Condensed 5-number financial health summary card for the main dashboard.
///
/// Shows Net Worth, Savings Rate, Emergency Fund, FI Progress, and Milestones
/// as compact badges. Hidden when no life profile is configured.
class FinancialHealthSummaryCard extends ConsumerWidget {
  const FinancialHealthSummaryCard({
    super.key,
    required this.familyId,
    required this.userId,
  });

  final String familyId;
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(
      planningHealthProvider((familyId: familyId, userId: userId)),
    );

    return healthAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (data) {
        if (!data.hasLifeProfile) return const SizedBox.shrink();
        return _HealthCard(data: data, familyId: familyId, userId: userId);
      },
    );
  }
}

class _HealthCard extends StatelessWidget {
  const _HealthCard({
    required this.data,
    required this.familyId,
    required this.userId,
  });

  final PlanningHealthData data;
  final String familyId;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final colors = ColorTokens.of(context);

    return Card(
      elevation: 0,
      color: colors.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.sm + Spacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Financial Health',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PlanningDashboardScreen(
                        familyId: familyId,
                        userId: userId,
                      ),
                    ),
                  ),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xs),
            // Badges
            Wrap(
              spacing: Spacing.xs,
              runSpacing: Spacing.xs,
              children: [
                _MetricBadge(
                  label: 'NW',
                  value: data.netWorthPaise != null
                      ? '\u20B9${formatIndianNumber(data.netWorthPaise! ~/ 100)}'
                      : '--',
                  icon: Icons.account_balance_wallet,
                  accentColor: colors.primary,
                ),
                _MetricBadge(
                  label: 'SR',
                  value: data.savingsRatePercent != null
                      ? '${data.savingsRatePercent!.toStringAsFixed(0)}%'
                      : '--',
                  icon: Icons.savings,
                  accentColor: _savingsRateColor(
                    data.savingsRatePercent,
                    colors,
                  ),
                ),
                _MetricBadge(
                  label: 'EF',
                  value: data.hasEmergencyFund
                      ? '${data.efCoverageMonths?.toStringAsFixed(1) ?? '0'}mo'
                      : '--',
                  icon: Icons.shield,
                  accentColor: colors.primary,
                ),
                _MetricBadge(
                  label: 'FI',
                  value: data.hasLifeProfile
                      ? '${data.fiProgressPercent?.toStringAsFixed(0) ?? '0'}%'
                      : '--',
                  icon: Icons.flag,
                  accentColor: colors.primary,
                ),
                _MetricBadge(
                  label: 'MS',
                  value: data.hasLifeProfile
                      ? '${data.milestoneOnTrackCount ?? 0}/${data.milestoneTotalCount ?? 0}'
                      : '--',
                  icon: Icons.emoji_events,
                  accentColor: colors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _savingsRateColor(double? rate, ColorTokens colors) {
    if (rate == null) return colors.neutral;
    if (rate >= 20) return colors.income;
    if (rate >= 10) return colors.warning;
    return colors.expense;
  }
}

class _MetricBadge extends StatelessWidget {
  const _MetricBadge({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Spacing.sm),
        border: Border.all(color: ColorTokens.of(context).outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: Spacing.xs),
          Icon(icon, size: 14, color: accentColor),
          const SizedBox(width: Spacing.xs),
          Text(
            '$label: $value',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
