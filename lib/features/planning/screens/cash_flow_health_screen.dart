import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/color_tokens.dart';
import '../../../shared/theme/spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../cashflow/providers/cash_flow_providers.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../providers/savings_allocation_providers.dart';
import '../widgets/cash_flow_mini_view.dart';
import '../widgets/savings_waterfall_chart.dart';
import 'savings_allocation_screen.dart';

/// Cash flow health screen with income/expenses bar chart,
/// savings waterfall breakdown, and 7-day cash flow mini-view.
class CashFlowHealthScreen extends ConsumerWidget {
  const CashFlowHealthScreen({
    super.key,
    required this.familyId,
    required this.userId,
  });

  final String familyId;
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(dashboardDataProvider(familyId));

    return Scaffold(
      appBar: AppBar(title: const Text('Cash Flow Health')),
      body: dashAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (dash) {
          final income = dash.monthlySummary.totalIncome;
          final expenses = dash.monthlySummary.totalExpenses;

          if (income == 0 && expenses == 0) {
            return EmptyState(
              icon: Icons.show_chart,
              title: 'No cash flow data yet',
              subtitle:
                  'Add recurring income and expense rules to see your cash flow health.',
              actionLabel: 'Set Up Rules',
              onAction: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SavingsAllocationScreen(familyId: familyId),
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(Spacing.md),
            children: [
              _IncomeExpensesSection(
                incomePaise: income,
                expensesPaise: expenses,
              ),
              const SizedBox(height: Spacing.lg),
              _WaterfallSection(
                familyId: familyId,
                incomePaise: income,
                expensesPaise: expenses,
              ),
              const SizedBox(height: Spacing.lg),
              _MiniViewSection(familyId: familyId),
            ],
          );
        },
      ),
    );
  }
}

/// Section 1: Income vs Expenses horizontal bars.
class _IncomeExpensesSection extends StatelessWidget {
  const _IncomeExpensesSection({
    required this.incomePaise,
    required this.expensesPaise,
  });

  final int incomePaise;
  final int expensesPaise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = ColorTokens.of(context);
    final now = DateTime.now();
    final monthName = _monthNames[now.month - 1];

    final maxVal = math.max(incomePaise, expensesPaise);

    double barFraction(int value) {
      if (maxVal <= 0) return 0;
      return (value / maxVal).clamp(0.02, 1.0);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('This Month', style: theme.textTheme.titleSmall),
        Text(
          monthName,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        _bar(
          context,
          'Income',
          incomePaise,
          barFraction(incomePaise),
          colors.income,
        ),
        const SizedBox(height: Spacing.xs),
        _bar(
          context,
          'Expenses',
          expensesPaise,
          barFraction(expensesPaise),
          colors.expense,
        ),
      ],
    );
  }

  Widget _bar(
    BuildContext context,
    String label,
    int paise,
    double fraction,
    Color color,
  ) {
    final theme = Theme.of(context);
    final rupees = paise / 100;
    final compact = rupees >= 100000
        ? '${(rupees / 100000).toStringAsFixed(1)}L'
        : rupees >= 1000
        ? '${(rupees / 1000).toStringAsFixed(0)}K'
        : '${rupees.toInt()}';

    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(label, style: theme.textTheme.bodySmall),
        ),
        Expanded(
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: fraction,
            child: Container(
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(width: Spacing.xs),
        Text(compact, style: theme.textTheme.labelSmall),
      ],
    );
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

/// Section 2: Savings waterfall chart.
class _WaterfallSection extends ConsumerWidget {
  const _WaterfallSection({
    required this.familyId,
    required this.incomePaise,
    required this.expensesPaise,
  });

  final String familyId;
  final int incomePaise;
  final int expensesPaise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allocAsync = ref.watch(allocationAdvisoryProvider(familyId));

    return allocAsync.when(
      loading: () => const SizedBox(height: 60),
      error: (_, _) => const SizedBox.shrink(),
      data: (allocations) {
        if (allocations.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Savings Waterfall',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: Spacing.sm),
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => SavingsAllocationScreen(familyId: familyId),
                  ),
                ),
                child: const Text('Set up allocation rules'),
              ),
            ],
          );
        }

        final allocTotal = allocations.fold<int>(
          0,
          (sum, a) => sum + a.allocatedPaise,
        );
        final unallocated = math.max(
          0,
          incomePaise - expensesPaise - allocTotal,
        );

        return SavingsWaterfallChart(
          incomePaise: incomePaise,
          expensesPaise: expensesPaise,
          allocations: allocations,
          unallocatedPaise: unallocated,
        );
      },
    );
  }
}

/// Section 3: 7-day cash flow mini-view.
class _MiniViewSection extends ConsumerWidget {
  const _MiniViewSection({required this.familyId});

  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final month = DateTime(now.year, now.month);
    final projAsync = ref.watch(
      cashFlowProjectionProvider((familyId: familyId, month: month)),
    );

    return projAsync.when(
      loading: () => const SizedBox(height: 60),
      error: (_, _) => const CashFlowMiniView(projections: []),
      data: (projections) {
        // Filter to next 7 days from today
        final today = DateTime(now.year, now.month, now.day);
        final cutoff = today.add(const Duration(days: 7));
        final next7 = projections
            .where((p) => !p.date.isBefore(today) && p.date.isBefore(cutoff))
            .toList();
        return CashFlowMiniView(projections: next7);
      },
    );
  }
}
