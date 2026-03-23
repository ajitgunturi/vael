import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/financial/budget_summary.dart';
import '../../../core/providers/session_providers.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/theme/spacing.dart';
import '../../../shared/utils/formatters.dart';
import '../../planning/providers/emergency_fund_provider.dart';
import '../../planning/screens/emergency_fund_screen.dart';
import '../providers/budget_providers.dart';
import 'budget_form_screen.dart';

/// Displays budget groups with progress bars, remaining amounts, and
/// interactive FAB + tappable cards for create/edit flows.
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
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (familyId: familyId, year: year, month: month);
    final summaryAsync = ref.watch(budgetSummaryProvider(key));

    return Scaffold(
      appBar: AppBar(title: Text('Budget — ${_monthNames[month]} $year')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context, ref),
        child: const Icon(Icons.add),
      ),
      body: summaryAsync.when(
        data: (rows) => rows.isEmpty
            ? _buildEmptyState(context)
            : _buildBudgetList(context, ref, rows),
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
          // ignore: deprecated_member_use
          Icon(
            Icons.pie_chart_outline,
            size: 48,
            color: ColorTokens.neutralStatic,
          ),
          SizedBox(height: Spacing.md),
          Text('No budgets set'),
          SizedBox(height: Spacing.sm),
          Text('Set spending limits for category groups'),
        ],
      ),
    );
  }

  Widget _buildBudgetList(
    BuildContext context,
    WidgetRef ref,
    List<BudgetSummaryRow> rows,
  ) {
    // Fetch EF coverage for the essential group subtitle.
    final userId = ref.watch(sessionUserIdProvider);
    final efAsync = userId != null
        ? ref.watch(
            emergencyFundStateProvider((userId: userId, familyId: familyId)),
          )
        : null;

    return ListView.builder(
      padding: const EdgeInsets.all(Spacing.md),
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        final isEssential = row.categoryGroup == 'ESSENTIAL';
        final coverageText = isEssential
            ? efAsync?.whenOrNull(
                data: (ef) =>
                    '${ef.coverageMonths.toStringAsFixed(1)} months covered',
              )
            : null;

        return _BudgetGroupCard(
          row: row,
          efCoverageSubtitle: coverageText,
          onTap: () => _navigateToForm(
            context,
            ref,
            editBudgetId: row.budgetId,
            initialGroup: row.categoryGroup,
            initialAmount: row.limitAmount,
          ),
          onEfTap: isEssential && userId != null
              ? () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        EmergencyFundScreen(familyId: familyId, userId: userId),
                  ),
                )
              : null,
        );
      },
    );
  }

  void _navigateToForm(
    BuildContext context,
    WidgetRef ref, {
    String? editBudgetId,
    String? initialGroup,
    int? initialAmount,
  }) {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => BudgetFormScreen(
              familyId: familyId,
              year: year,
              month: month,
              editBudgetId: editBudgetId,
              initialGroup: initialGroup,
              initialAmount: initialAmount,
            ),
          ),
        )
        .then((_) {
          // Refresh budget data after form closes
          final key = (familyId: familyId, year: year, month: month);
          ref.invalidate(budgetSummaryProvider(key));
        });
  }
}

class _BudgetGroupCard extends StatelessWidget {
  const _BudgetGroupCard({
    required this.row,
    required this.onTap,
    this.efCoverageSubtitle,
    this.onEfTap,
  });

  final BudgetSummaryRow row;
  final VoidCallback onTap;
  final String? efCoverageSubtitle;
  final VoidCallback? onEfTap;

  @override
  Widget build(BuildContext context) {
    final progress = row.limitAmount > 0
        ? (row.actualSpent / row.limitAmount).clamp(0.0, 1.5)
        : 1.0;
    final barColor = row.isOverspent
        ? ColorTokens.negative
        : ColorTokens.positive;
    final spentFormatted = formatIndianNumber(row.actualSpent ~/ 100);
    final limitFormatted = row.limitAmount > 0
        ? formatIndianNumber(row.limitAmount ~/ 100)
        : '—';

    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.sm + 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
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
              if (efCoverageSubtitle != null)
                GestureDetector(
                  onTap: onEfTap,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 14,
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          efCoverageSubtitle!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.green.shade700),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: Spacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(barColor),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹$spentFormatted / ₹$limitFormatted',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (!row.isOverspent && row.limitAmount > 0)
                    Text(
                      '₹${formatIndianNumber(row.remaining ~/ 100)} remaining',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ColorTokens.positive,
                      ),
                    ),
                ],
              ),
            ],
          ),
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
