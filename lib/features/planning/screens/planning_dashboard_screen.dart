import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/financial/insights_engine.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/theme/spacing.dart';
import '../../../shared/utils/formatters.dart';
import '../../dashboard/screens/savings_rate_detail_screen.dart';
import '../../goals/screens/goal_list_screen.dart';
import '../providers/insights_provider.dart';
import '../providers/planning_health_providers.dart';
import '../widgets/health_metric_card.dart';
import '../widgets/insight_alert_card.dart';
import 'allocation_screen.dart';
import 'emergency_fund_screen.dart';
import 'fi_calculator_screen.dart';
import 'life_profile_wizard_screen.dart';
import 'milestone_dashboard_screen.dart';

/// Planning dashboard with 5-number financial health view.
///
/// Displays Net Worth, Savings Rate, Emergency Fund coverage, FI Progress,
/// and Milestone status as tappable cards. Unconfigured features show
/// "Set up" CTAs for graceful degradation.
class PlanningDashboardScreen extends ConsumerWidget {
  const PlanningDashboardScreen({
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
    final insightsAsync = ref.watch(
      insightsProvider((familyId: familyId, userId: userId)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Financial Health')),
      body: healthAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (health) => _HealthGrid(
          health: health,
          familyId: familyId,
          userId: userId,
          insights: insightsAsync.whenOrNull(data: (d) => d) ?? [],
        ),
      ),
    );
  }
}

class _HealthGrid extends StatelessWidget {
  const _HealthGrid({
    required this.health,
    required this.familyId,
    required this.userId,
    required this.insights,
  });

  final PlanningHealthData health;
  final String familyId;
  final String userId;
  final List<PlanningInsight> insights;

  void _navigateForInsight(BuildContext context, InsightType type) {
    final Widget screen;
    switch (type) {
      case InsightType.efBelowTarget:
        screen = EmergencyFundScreen(familyId: familyId, userId: userId);
      case InsightType.allocationOffTarget:
        screen = AllocationScreen(familyId: familyId, userId: userId);
      case InsightType.fiDateSlipping:
        screen = FiCalculatorScreen(familyId: familyId, userId: userId);
      case InsightType.sinkingFundUnderfunded:
        screen = GoalListScreen(familyId: familyId);
    }
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorTokens.of(context);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(Spacing.md),
      children: [
        // Alerts section (only when insights exist)
        if (insights.isNotEmpty) ...[
          Text(
            'Alerts',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          for (final insight in insights)
            InsightAlertCard(
              insight: insight,
              onTap: () => _navigateForInsight(context, insight.type),
            ),
          const SizedBox(height: Spacing.md),
        ],
        // 2-column grid with first 4 cards
        GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.6,
          crossAxisSpacing: Spacing.sm,
          mainAxisSpacing: Spacing.sm,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // 1. Net Worth
            HealthMetricCard(
              label: 'Net Worth',
              value: health.netWorthPaise != null
                  ? '\u20B9${formatIndianNumber(health.netWorthPaise! ~/ 100)}'
                  : '--',
              icon: Icons.account_balance_wallet,
              onTap: () {},
            ),

            // 2. Savings Rate
            HealthMetricCard(
              label: 'Savings Rate',
              value: health.savingsRatePercent != null
                  ? '${health.savingsRatePercent!.toStringAsFixed(0)}%'
                  : '--',
              valueColor: _savingsRateColor(health.savingsRatePercent, colors),
              icon: Icons.savings,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SavingsRateDetailScreen(familyId: familyId),
                ),
              ),
            ),

            // 3. Emergency Fund
            if (health.hasEmergencyFund)
              HealthMetricCard(
                label: 'Emergency Fund',
                value:
                    '${health.efCoverageMonths?.toStringAsFixed(1) ?? '0'} mo',
                subtitle: 'of ${health.efTargetMonths ?? 0} mo target',
                icon: Icons.shield,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        EmergencyFundScreen(familyId: familyId, userId: userId),
                  ),
                ),
              )
            else
              HealthMetricCard(
                label: 'Emergency Fund',
                icon: Icons.shield,
                showSetup: true,
                setupLabel: 'Set up EF',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        EmergencyFundScreen(familyId: familyId, userId: userId),
                  ),
                ),
              ),

            // 4. FI Progress
            if (health.hasLifeProfile)
              HealthMetricCard(
                label: 'FI Progress',
                value:
                    '${health.fiProgressPercent?.toStringAsFixed(0) ?? '0'}%',
                subtitle: health.yearsToFi != null
                    ? '${health.yearsToFi} yr to FI'
                    : null,
                icon: Icons.flag,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        FiCalculatorScreen(familyId: familyId, userId: userId),
                  ),
                ),
              )
            else
              HealthMetricCard(
                label: 'FI Progress',
                icon: Icons.flag,
                showSetup: true,
                setupLabel: 'Set up Profile',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => LifeProfileWizardScreen(
                      userId: userId,
                      familyId: familyId,
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: Spacing.sm),

        // 5. Milestones — full-width row below the grid
        if (health.hasLifeProfile)
          HealthMetricCard(
            label: 'Milestones',
            value:
                '${health.milestoneOnTrackCount ?? 0}/${health.milestoneTotalCount ?? 0}',
            subtitle: 'on track',
            icon: Icons.emoji_events,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => MilestoneDashboardScreen(
                  familyId: familyId,
                  userId: userId,
                ),
              ),
            ),
          )
        else
          HealthMetricCard(
            label: 'Milestones',
            icon: Icons.emoji_events,
            showSetup: true,
            setupLabel: 'Set up Profile',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    LifeProfileWizardScreen(userId: userId, familyId: familyId),
              ),
            ),
          ),
      ],
    );
  }

  /// Returns a color for the savings rate based on health bands:
  /// >= 20% green, >= 10% amber, < 10% red.
  Color? _savingsRateColor(double? rate, ColorTokens colors) {
    if (rate == null) return null;
    if (rate >= 20) return colors.income;
    if (rate >= 10) return colors.warning;
    return colors.expense;
  }
}
