import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/financial/dashboard_aggregation.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/theme/spacing.dart';
import '../../../shared/utils/formatters.dart';
import '../providers/dashboard_providers.dart';

/// Main dashboard showing net worth hero, monthly tiles, quick actions,
/// savings rate badge, goals, and scope toggle.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({
    super.key,
    required this.familyId,
    this.goals = const [],
    this.onNavigateToTab,
  });

  final String familyId;
  final List<Goal> goals;

  /// Callback to navigate to a tab in the adaptive scaffold.
  /// Index matches AdaptiveScaffold.destinations: 0=Dashboard, 1=Accounts,
  /// 2=Transactions, 3=Budget, 4=Goals.
  final ValueChanged<int>? onNavigateToTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(dashboardDataProvider(familyId));
    final scope = ref.watch(dashboardScopeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          _ScopeToggle(
            scope: scope,
            onChanged: (s) => ref.read(dashboardScopeProvider.notifier).set(s),
          ),
        ],
      ),
      body: dataAsync.when(
        data: (data) => _DashboardBody(
          data: data,
          goals: goals,
          onNavigateToTab: onNavigateToTab,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ScopeToggle extends StatelessWidget {
  const _ScopeToggle({required this.scope, required this.onChanged});

  final DashboardScope scope;
  final ValueChanged<DashboardScope> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<DashboardScope>(
      segments: const [
        ButtonSegment(value: DashboardScope.family, label: Text('Family')),
        ButtonSegment(value: DashboardScope.personal, label: Text('Personal')),
      ],
      selected: {scope},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.data,
    required this.goals,
    this.onNavigateToTab,
  });

  final DashboardData data;
  final List<Goal> goals;
  final ValueChanged<int>? onNavigateToTab;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(Spacing.md),
      children: [
        _HeroNetWorthCard(
          netWorth: data.netWorth,
          onTap: onNavigateToTab != null ? () => onNavigateToTab!(1) : null,
        ),
        const SizedBox(height: Spacing.md),
        _CompactTilesRow(
          summary: data.monthlySummary,
          onNavigateToTab: onNavigateToTab,
        ),
        const SizedBox(height: Spacing.md),
        _SavingsRateBadge(rate: data.savingsRate),
        const SizedBox(height: Spacing.md),
        const _QuickActionsRow(),
        const SizedBox(height: Spacing.md),
        if (goals.isNotEmpty) _GoalsSection(goals: goals),
      ],
    );
  }
}

/// Hero net worth card per `UI_DESIGN.md` §2.2.
class _HeroNetWorthCard extends StatelessWidget {
  const _HeroNetWorthCard({required this.netWorth, this.onTap});

  final int netWorth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = ColorTokens.of(context);
    final isPositive = netWorth >= 0;
    final color = isPositive ? tokens.income : tokens.expense;
    final sign = isPositive ? '' : '-';
    final formatted = formatIndianNumber(netWorth.abs() ~/ 100);

    return Semantics(
      label: 'Net worth: $sign rupees $formatted',
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Spacing.lg,
              horizontal: Spacing.md,
            ),
            child: Column(
              children: [
                Text(
                  'Net Worth',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: tokens.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  '$sign₹$formatted',
                  style: Theme.of(
                    context,
                  ).textTheme.displayLarge?.copyWith(color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact side-by-side income / expense / net savings tiles.
class _CompactTilesRow extends StatelessWidget {
  const _CompactTilesRow({required this.summary, this.onNavigateToTab});

  final MonthlySummary summary;
  final ValueChanged<int>? onNavigateToTab;

  @override
  Widget build(BuildContext context) {
    final tokens = ColorTokens.of(context);
    return Row(
      children: [
        Expanded(
          child: _CompactTile(
            label: 'Income',
            value: '₹${formatIndianNumber(summary.totalIncome ~/ 100)}',
            color: tokens.income,
            onTap: onNavigateToTab != null ? () => onNavigateToTab!(2) : null,
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: _CompactTile(
            label: 'Expenses',
            value: '₹${formatIndianNumber(summary.totalExpenses ~/ 100)}',
            color: tokens.expense,
            onTap: onNavigateToTab != null ? () => onNavigateToTab!(3) : null,
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: _CompactTile(
            label: 'Net Savings',
            value:
                '${summary.netSavings >= 0 ? '+' : '-'}₹${formatIndianNumber(summary.netSavings.abs() ~/ 100)}',
            color: summary.netSavings >= 0 ? tokens.income : tokens.expense,
            onTap: onNavigateToTab != null ? () => onNavigateToTab!(2) : null,
          ),
        ),
      ],
    );
  }
}

class _CompactTile extends StatelessWidget {
  const _CompactTile({
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(Spacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: Spacing.xs),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Savings rate badge — green >= 20%, amber 10-20%, red < 10%.
class _SavingsRateBadge extends StatelessWidget {
  const _SavingsRateBadge({required this.rate});

  final double rate;

  @override
  Widget build(BuildContext context) {
    final tokens = ColorTokens.of(context);
    final Color chipColor;
    if (rate >= 20) {
      chipColor = tokens.income;
    } else if (rate >= 10) {
      chipColor = tokens.warning;
    } else {
      chipColor = tokens.expense;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        label: Text(
          'Savings Rate: ${rate.toStringAsFixed(0)}%',
          style: TextStyle(color: chipColor, fontWeight: FontWeight.w600),
        ),
        side: BorderSide(color: chipColor),
        backgroundColor: chipColor.withValues(alpha: 0.1),
      ),
    );
  }
}

/// Quick action tonal buttons.
class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Add Transaction'),
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: () {},
            icon: const Icon(Icons.account_balance),
            label: const Text('View Accounts'),
          ),
        ),
      ],
    );
  }
}

class _GoalsSection extends StatelessWidget {
  const _GoalsSection({required this.goals});

  final List<Goal> goals;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Goals', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: Spacing.sm),
        ...goals.map((g) => _GoalTile(goal: g)),
      ],
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final tokens = ColorTokens.of(context);
    final progress = goal.targetAmount > 0
        ? (goal.currentSavings / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final status = _statusLabel(goal.status, tokens);
    final savedFormatted = formatIndianNumber(goal.currentSavings ~/ 100);
    final targetFormatted = formatIndianNumber(goal.targetAmount ~/ 100);

    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.sm + Spacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  goal.name,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  status.label,
                  style: TextStyle(color: status.color, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: tokens.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation(status.color),
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              '₹$savedFormatted / ₹$targetFormatted',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  static ({String label, Color color}) _statusLabel(
    String status,
    ColorTokens tokens,
  ) {
    return switch (status) {
      'completed' => (label: 'Completed', color: tokens.income),
      'onTrack' => (label: 'On Track', color: tokens.income),
      'atRisk' => (label: 'At Risk', color: tokens.expense),
      _ => (label: 'Active', color: tokens.neutral),
    };
  }
}
