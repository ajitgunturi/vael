import 'package:flutter/material.dart';

import '../../../core/financial/allocation_engine.dart';
import '../../../core/models/enums.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/theme/spacing.dart';

/// Displays rebalancing guidance: asset class deltas with semantic colors.
///
/// Overweight rows use expenseContainer background, underweight rows use
/// incomeContainer background, and on-target rows (within 200bp) have no tint.
class RebalancingDeltaTable extends StatelessWidget {
  const RebalancingDeltaTable({super.key, required this.deltas});

  final List<RebalancingDelta> deltas;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = ColorTokens.of(context);

    return Card(
      color: colors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rebalancing Guidance', style: theme.textTheme.titleMedium),
            const SizedBox(height: Spacing.sm),
            ...deltas.map((d) => _DeltaRow(delta: d)),
          ],
        ),
      ),
    );
  }
}

class _DeltaRow extends StatelessWidget {
  const _DeltaRow({required this.delta});

  final RebalancingDelta delta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = ColorTokens.of(context);
    final acColors = _assetClassColors(colors);

    final isOverweight = delta.deltaPaise > 0;
    final isUnderweight = delta.deltaPaise < 0;
    final deltaBp = (delta.actualBp - delta.targetBp).abs();
    final isOnTarget = deltaBp <= 200;

    Color? bgColor;
    if (!isOnTarget) {
      if (isOverweight) {
        bgColor = colors.expenseContainer;
      } else if (isUnderweight) {
        bgColor = colors.incomeContainer;
      }
    }

    final absPaise = delta.deltaPaise.abs();
    final amountStr = _formatDeltaAmount(absPaise);
    final sign = isOverweight ? '+' : '-';
    final deltaLabel = isOnTarget
        ? 'on target'
        : isOverweight
        ? 'overweight ${(deltaBp / 100).toStringAsFixed(0)}%'
        : 'underweight ${(deltaBp / 100).toStringAsFixed(0)}%';
    final displayAmount = isOnTarget ? '' : '${sign}Rs $amountStr';

    final semanticsLabel = isOnTarget
        ? '${_displayName(delta.assetClass)}: on target'
        : '${_displayName(delta.assetClass)}: ${delta.deltaDescription} by '
              '${(deltaBp / 100).toStringAsFixed(0)}%, '
              '${isOverweight ? "reduce" : "increase"} by Rs $amountStr';

    return Semantics(
      label: semanticsLabel,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.sm,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(Spacing.sm),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: acColors[delta.assetClass],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Text(
                _displayName(delta.assetClass),
                style: theme.textTheme.titleMedium,
              ),
            ),
            if (displayAmount.isNotEmpty)
              Text(
                displayAmount,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            const SizedBox(width: Spacing.sm),
            Text(
              deltaLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isOnTarget
                    ? colors.onSurfaceVariant
                    : isOverweight
                    ? colors.expense
                    : colors.income,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDeltaAmount(int paise) {
    final rupees = paise / 100;
    if (rupees >= 10000000) {
      return '${(rupees / 10000000).toStringAsFixed(1)} Cr';
    } else if (rupees >= 100000) {
      return '${(rupees / 100000).toStringAsFixed(1)} L';
    } else if (rupees >= 1000) {
      return '${(rupees / 1000).toStringAsFixed(1)} K';
    }
    return rupees.toStringAsFixed(0);
  }

  static String _displayName(AssetClass ac) => switch (ac) {
    AssetClass.equity => 'Equity',
    AssetClass.debt => 'Debt',
    AssetClass.gold => 'Gold',
    AssetClass.cash => 'Cash',
  };

  static Map<AssetClass, Color> _assetClassColors(ColorTokens colors) => {
    AssetClass.equity: colors.chartLine1,
    AssetClass.debt: colors.chartLine3,
    AssetClass.gold: colors.warning,
    AssetClass.cash: colors.neutral,
  };
}
