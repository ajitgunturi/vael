import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/financial/budget_summary.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/theme/spacing.dart';
import '../../../shared/utils/formatters.dart';

/// Donut chart showing actual spend distribution across budget categories.
class BudgetDonutChart extends StatelessWidget {
  const BudgetDonutChart({super.key, required this.rows});

  final List<BudgetSummaryRow> rows;

  static const _groupColors = <String, Color>{
    'ESSENTIAL': Color(0xFF2D5A27),
    'NON_ESSENTIAL': Color(0xFF1A4A7A),
    'INVESTMENTS': Color(0xFF8B6914),
    'HOME_EXPENSES': Color(0xFF6B3FA0),
    'MISSING': Color(0xFF757575),
  };

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalSpent = rows.fold<int>(0, (sum, r) => sum + r.actualSpent);

    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: rows
                  .map(
                    (r) => PieChartSectionData(
                      value: r.actualSpent.toDouble(),
                      color:
                          _groupColors[r.categoryGroup] ??
                          ColorTokens.neutralStatic,
                      radius: 32,
                      showTitle: false,
                    ),
                  )
                  .toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 56,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '₹${formatIndianNumber(totalSpent ~/ 100)}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'spent',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ColorTokens.of(context).onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
