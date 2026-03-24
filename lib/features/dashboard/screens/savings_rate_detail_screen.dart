import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/models/money.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/theme/spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/savings_rate_providers.dart';
import '../widgets/savings_rate_trend_chart.dart';

/// Savings rate detail screen showing current month hero, 12-month trend chart,
/// and tappable month breakdown.
class SavingsRateDetailScreen extends ConsumerStatefulWidget {
  const SavingsRateDetailScreen({super.key, required this.familyId});

  final String familyId;

  @override
  ConsumerState<SavingsRateDetailScreen> createState() =>
      _SavingsRateDetailScreenState();
}

class _SavingsRateDetailScreenState
    extends ConsumerState<SavingsRateDetailScreen> {
  MonthlyMetric? _selectedMetric;

  @override
  Widget build(BuildContext context) {
    final metricsAsync = ref.watch(savingsRateMetricsProvider(widget.familyId));

    return Scaffold(
      appBar: AppBar(title: const Text('Savings Rate')),
      body: metricsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $e'),
              const SizedBox(height: Spacing.md),
              FilledButton(
                onPressed: () =>
                    ref.invalidate(savingsRateMetricsProvider(widget.familyId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (metrics) => _buildBody(context, metrics),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<MonthlyMetric> metrics) {
    if (metrics.isEmpty) {
      return const EmptyState(
        icon: Icons.savings,
        title: 'No savings data yet',
        subtitle:
            'Add income and expense transactions to start tracking your savings rate.',
      );
    }

    // Default selected metric to current (last) month
    final selected = _selectedMetric ?? metrics.last;
    final currentRate = metrics.last.savingsRateBp / 100.0;

    return ListView(
      padding: const EdgeInsets.all(Spacing.md),
      children: [
        _buildHero(context, currentRate),
        const SizedBox(height: Spacing.lg),
        _buildTrendSection(context, metrics),
        const SizedBox(height: Spacing.md),
        _buildMonthBreakdown(context, selected),
      ],
    );
  }

  Widget _buildHero(BuildContext context, double rate) {
    final tokens = ColorTokens.of(context);
    final theme = Theme.of(context);
    final color = _healthColor(rate, tokens);
    final label = _healthLabel(rate);

    return Column(
      children: [
        Text(
          '${rate.toStringAsFixed(0)}%',
          style: theme.textTheme.displayLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Text(label, style: theme.textTheme.titleMedium?.copyWith(color: color)),
        const SizedBox(height: Spacing.xs),
        Text(
          'This month',
          style: theme.textTheme.bodySmall?.copyWith(
            color: tokens.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendSection(BuildContext context, List<MonthlyMetric> metrics) {
    final theme = Theme.of(context);
    final tokens = ColorTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('12-Month Trend', style: theme.textTheme.titleSmall),
        if (metrics.length < 12)
          Padding(
            padding: const EdgeInsets.only(top: Spacing.xs),
            child: Text(
              'Showing ${metrics.length} month${metrics.length == 1 ? '' : 's'} of data',
              style: theme.textTheme.bodySmall?.copyWith(
                color: tokens.onSurfaceVariant,
              ),
            ),
          ),
        const SizedBox(height: Spacing.sm),
        SavingsRateTrendChart(
          metrics: metrics,
          onMonthTap: (metric) => setState(() => _selectedMetric = metric),
        ),
      ],
    );
  }

  Widget _buildMonthBreakdown(BuildContext context, MonthlyMetric metric) {
    final theme = Theme.of(context);
    final tokens = ColorTokens.of(context);
    final rate = metric.savingsRateBp / 100.0;

    // Parse month for display
    final parts = metric.month.split('-');
    final year = int.parse(parts[0]);
    final mon = int.parse(parts[1]);
    final monthName = _monthNames[mon - 1];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$monthName $year', style: theme.textTheme.titleSmall),
            const SizedBox(height: Spacing.sm),
            _breakdownRow(
              context,
              'Income',
              Money(metric.totalIncomePaise).formatted,
              tokens.income,
            ),
            const SizedBox(height: Spacing.xs),
            _breakdownRow(
              context,
              'Expenses',
              Money(metric.totalExpensesPaise).formatted,
              tokens.expense,
            ),
            const Divider(height: Spacing.md),
            _breakdownRow(
              context,
              'Savings Rate',
              '${rate.toStringAsFixed(1)}%',
              _healthColor(rate, tokens),
            ),
          ],
        ),
      ),
    );
  }

  Widget _breakdownRow(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _healthColor(double rate, ColorTokens tokens) {
    if (rate >= 20) return tokens.income;
    if (rate >= 10) return tokens.warning;
    return tokens.expense;
  }

  String _healthLabel(double rate) {
    if (rate >= 20) return 'Healthy';
    if (rate >= 10) return 'Moderate';
    return 'Low';
  }

  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
}
