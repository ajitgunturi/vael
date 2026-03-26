import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/financial/cash_flow_engine.dart';
import '../../../shared/theme/spacing.dart';

/// Inline threshold warning row matching locked format from CONTEXT.md:
/// "Balance drops to Rs X on [date] -- below Rs Y minimum"
class CashFlowAlertRow extends StatelessWidget {
  const CashFlowAlertRow({
    super.key,
    required this.alert,
    required this.accountName,
  });

  final ThresholdAlert alert;
  final String accountName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final balanceRupees = alert.balancePaise ~/ 100;
    final thresholdRupees = alert.thresholdPaise ~/ 100;
    final dateStr = DateFormat('dd MMM').format(alert.date);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: const Border(left: BorderSide(color: Colors.amber, width: 4)),
        borderRadius: BorderRadius.circular(Spacing.xs),
      ),
      padding: const EdgeInsets.all(Spacing.sm),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.amber,
            size: 20,
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              'Balance drops to Rs $balanceRupees on $dateStr -- below Rs $thresholdRupees minimum',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.amber.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
