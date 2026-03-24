import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/financial/cash_flow_engine.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/theme/spacing.dart';

/// Compact 7-day cash flow preview with threshold alerts.
///
/// Each row shows: day name, net flow for that day, and a warning icon
/// if any threshold alert exists for that day.
class CashFlowMiniView extends StatelessWidget {
  const CashFlowMiniView({super.key, required this.projections});

  /// Next 7 days of projections.
  final List<DayProjection> projections;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = ColorTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Next 7 Days', style: theme.textTheme.titleSmall),
        const SizedBox(height: Spacing.sm),
        if (projections.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.md),
            child: Text(
              'No upcoming cash flow',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          )
        else
          ...projections.map((day) => _buildRow(context, day, colors)),
      ],
    );
  }

  Widget _buildRow(
    BuildContext context,
    DayProjection day,
    ColorTokens colors,
  ) {
    final theme = Theme.of(context);
    final hasAlert = day.alerts.isNotEmpty;

    // Net flow: sum income positive, expense negative
    int netFlow = 0;
    for (final item in day.items) {
      switch (item.kind) {
        case 'income':
          netFlow += item.amountPaise;
        case 'expense':
          netFlow -= item.amountPaise;
        case 'transfer':
          // Transfers are neutral in net flow
          break;
      }
    }

    final dayLabel = DateFormat('E d').format(day.date);
    final netRupees = netFlow / 100;
    final sign = netFlow >= 0 ? '+' : '';
    final flowColor = netFlow >= 0 ? colors.income : colors.expense;

    return Container(
      height: 36,
      decoration: hasAlert
          ? BoxDecoration(
              color: colors.warningContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            )
          : null,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(dayLabel, style: theme.textTheme.bodySmall),
          ),
          Expanded(
            child: Text(
              '$sign${netRupees.toStringAsFixed(0)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: flowColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          if (hasAlert) ...[
            const SizedBox(width: 4),
            Icon(Icons.warning_amber, size: 16, color: colors.warning),
          ],
        ],
      ),
    );
  }
}
