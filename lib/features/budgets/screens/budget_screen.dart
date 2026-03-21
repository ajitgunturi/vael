import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/financial/budget_summary.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/utils/formatters.dart';
import '../providers/budget_providers.dart';

/// Displays budget groups with progress bars and spend summaries.
class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({
    super.key,
    required this.familyId,
    required this.year,
    required this.month,
  });

  final String familyId;
  final int year;
  final int month;

  static const _monthNames = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (familyId: familyId, year: year, month: month);
    final summaryAsync = ref.watch(budgetSummaryProvider(key));

    return Scaffold(
      appBar: AppBar(
        title: Text('Budget — ${_monthNames[month]} $year'),
      ),
      body: summaryAsync.when(
        data: (rows) => rows.isEmpty
            ? _buildEmptyState(context)
            : _buildBudgetList(context, rows),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pie_chart_outline, size: 48, color: ColorTokens.neutral),
          SizedBox(height: 16),
          Text('No budgets set'),
          SizedBox(height: 8),
          Text('Set spending limits for category groups'),
        ],
      ),
    );
  }

  Widget _buildBudgetList(BuildContext context, List<BudgetSummaryRow> rows) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rows.length,
      itemBuilder: (context, index) => _BudgetGroupCard(row: rows[index]),
    );
  }
}

class _BudgetGroupCard extends StatelessWidget {
  const _BudgetGroupCard({required this.row});

  final BudgetSummaryRow row;

  @override
  Widget build(BuildContext context) {
    final progress = row.limitAmount > 0
        ? (row.actualSpent / row.limitAmount).clamp(0.0, 1.5)
        : 1.0;
    final barColor = row.isOverspent ? ColorTokens.negative : ColorTokens.positive;
    final spentFormatted = formatIndianNumber(row.actualSpent ~/ 100);
    final limitFormatted = row.limitAmount > 0
        ? formatIndianNumber(row.limitAmount ~/ 100)
        : '—';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _groupLabel(row.categoryGroup),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (row.isOverspent)
                  Text(
                    'Overspent',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: ColorTokens.negative,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(barColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹$spentFormatted / ₹$limitFormatted',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  static String _groupLabel(String group) {
    switch (group) {
      case 'ESSENTIAL':
        return 'Essential';
      case 'NON_ESSENTIAL':
        return 'Non-Essential';
      case 'INVESTMENTS':
        return 'Investments';
      case 'HOME_EXPENSES':
        return 'Home Expenses';
      case 'MISSING':
        return 'Uncategorized';
      default:
        return group;
    }
  }
}
