import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/financial/dashboard_aggregation.dart';
import '../../../core/financial/goal_tracking.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/utils/formatters.dart';
import '../providers/dashboard_providers.dart';

/// Main dashboard showing net worth, monthly summary, goals, and scope toggle.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({
    super.key,
    required this.familyId,
    this.goals = const [],
  });

  final String familyId;
  final List<Goal> goals;

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
            onChanged: (s) => ref.read(dashboardScopeProvider.notifier).state = s,
          ),
        ],
      ),
      body: dataAsync.when(
        data: (data) => _DashboardBody(data: data, goals: goals),
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
  const _DashboardBody({required this.data, required this.goals});

  final DashboardData data;
  final List<Goal> goals;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _NetWorthCard(netWorth: data.netWorth),
        const SizedBox(height: 16),
        _MonthlySummaryCard(summary: data.monthlySummary),
        const SizedBox(height: 16),
        if (goals.isNotEmpty) _GoalsSection(goals: goals),
      ],
    );
  }
}

class _NetWorthCard extends StatelessWidget {
  const _NetWorthCard({required this.netWorth});

  final int netWorth;

  @override
  Widget build(BuildContext context) {
    final isPositive = netWorth >= 0;
    final color = isPositive ? ColorTokens.positive : ColorTokens.negative;
    final sign = isPositive ? '' : '-';
    final formatted = formatIndianNumber(netWorth.abs() ~/ 100);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Net Worth',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '$sign₹$formatted',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlySummaryCard extends StatelessWidget {
  const _MonthlySummaryCard({required this.summary});

  final MonthlySummary summary;

  @override
  Widget build(BuildContext context) {
    final incomeFormatted = formatIndianNumber(summary.totalIncome ~/ 100);
    final expenseFormatted = formatIndianNumber(summary.totalExpenses ~/ 100);
    final savingsFormatted = formatIndianNumber(summary.netSavings.abs() ~/ 100);
    final savingsColor =
        summary.netSavings >= 0 ? ColorTokens.positive : ColorTokens.negative;
    final savingsSign = summary.netSavings >= 0 ? '+' : '-';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This Month',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _summaryRow(context, 'Income', '₹$incomeFormatted',
                ColorTokens.positive),
            _summaryRow(context, 'Expenses', '₹$expenseFormatted',
                ColorTokens.negative),
            const Divider(),
            _summaryRow(context, 'Net Savings',
                '$savingsSign₹$savingsFormatted', savingsColor),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(
      BuildContext context, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value,
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
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
        const SizedBox(height: 8),
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
    final progress = goal.targetAmount > 0
        ? (goal.currentSavings / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final status = _statusLabel(goal.status);
    final savedFormatted = formatIndianNumber(goal.currentSavings ~/ 100);
    final targetFormatted = formatIndianNumber(goal.targetAmount ~/ 100);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(goal.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                Text(status.label,
                    style: TextStyle(color: status.color, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(status.color),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '₹$savedFormatted / ₹$targetFormatted',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  static ({String label, Color color}) _statusLabel(String status) {
    return switch (status) {
      'completed' => (label: 'Completed', color: ColorTokens.positive),
      'onTrack' => (label: 'On Track', color: ColorTokens.positive),
      'atRisk' => (label: 'At Risk', color: ColorTokens.negative),
      // ignore: deprecated_member_use
      _ => (label: 'Active', color: ColorTokens.neutralStatic),
    };
  }
}
