import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/financial/decision_modeler.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/money.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/theme/spacing.dart';

/// Hero card showing the FI impact of a decision in semantic colors.
///
/// - fiDelayYears > 0 -> "Delays FI by {n} years" in expense color
/// - fiDelayYears < 0 -> "FI {n} years closer" in income color
/// - fiDelayYears == 0 -> "No impact on FI date" in onSurfaceVariant
/// - fiYearsAfter == -1 (sentinel) -> "FI impact unavailable" in onSurfaceVariant
class DecisionImpactCard extends StatelessWidget {
  const DecisionImpactCard({
    super.key,
    required this.impact,
    required this.decisionType,
  });

  final DecisionImpact impact;
  final DecisionType decisionType;

  IconData get _typeIcon => switch (decisionType) {
    DecisionType.jobChange => Icons.work_outline,
    DecisionType.salaryNegotiation => Icons.trending_up,
    DecisionType.majorPurchase => Icons.home_outlined,
    DecisionType.investmentWithdrawal => Icons.account_balance_wallet_outlined,
    DecisionType.rentalChange => Icons.apartment_outlined,
    DecisionType.custom => Icons.tune,
  };

  @override
  Widget build(BuildContext context) {
    final colors = ColorTokens.of(context);
    final theme = Theme.of(context);

    final headline = _buildHeadline();
    final semanticColor = _resolveColor(colors);

    return Semantics(
      label: 'Decision impact: ${headline.toLowerCase()}',
      child: Card(
        color: colors.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_typeIcon, size: 32, color: colors.onSurfaceVariant),
              const SizedBox(height: Spacing.sm),
              Text(
                headline,
                style: theme.textTheme.displayMedium?.copyWith(
                  color: semanticColor,
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: Spacing.md),
              // Detail rows
              _DetailRow(
                label: 'FI Date',
                value:
                    'age ${impact.fiYearsBefore} yrs -> age ${impact.fiYearsAfter} yrs',
                valueColor: semanticColor,
                theme: theme,
                colors: colors,
              ),
              const SizedBox(height: Spacing.sm),
              ...impact.nwImpactAtMilestoneAges.entries
                  .take(1)
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.sm),
                      child: _DetailRow(
                        label: 'Net worth at ${e.key}',
                        value:
                            '${_formatCompact(e.value.beforePaise)} -> ${_formatCompact(e.value.afterPaise)}',
                        valueColor: semanticColor,
                        theme: theme,
                        colors: colors,
                      ),
                    ),
                  ),
              _DetailRow(
                label: 'Monthly cash flow',
                value: _formatCashFlowChange(impact.monthlyCashFlowChangePaise),
                valueColor: semanticColor,
                theme: theme,
                colors: colors,
              ),
              // Tax preview for withdrawals
              if (impact.taxDescription != null) ...[
                const SizedBox(height: Spacing.md),
                Container(
                  padding: const EdgeInsets.all(Spacing.md),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(Spacing.cardRadius),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_outlined,
                        size: 20,
                        color: colors.warning,
                      ),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: Text(
                          impact.taxDescription!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _buildHeadline() {
    if (impact.fiYearsAfter == -1 && impact.fiYearsBefore != -1) {
      return 'FI impact unavailable';
    }
    if (impact.fiDelayYears > 0) {
      return 'Delays FI by ${impact.fiDelayYears} years';
    }
    if (impact.fiDelayYears < 0) {
      return 'FI ${impact.fiDelayYears.abs()} years closer';
    }
    return 'No impact on FI date';
  }

  Color _resolveColor(ColorTokens colors) {
    if (impact.fiYearsAfter == -1 && impact.fiYearsBefore != -1) {
      return colors.onSurfaceVariant;
    }
    if (impact.fiDelayYears > 0) return colors.expense;
    if (impact.fiDelayYears < 0) return colors.income;
    return colors.onSurfaceVariant;
  }

  static String _formatCompact(int paise) {
    final rupees = paise / 100;
    if (rupees.abs() >= 10000000) {
      return 'Rs ${(rupees / 10000000).toStringAsFixed(1)} Cr';
    }
    if (rupees.abs() >= 100000) {
      return 'Rs ${(rupees / 100000).toStringAsFixed(1)} L';
    }
    return Money(paise).formatted;
  }

  static String _formatCashFlowChange(int paise) {
    if (paise == 0) return 'No change';
    final prefix = paise > 0 ? '+' : '';
    return '$prefix${_formatCompact(paise)}/mo';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.theme,
    required this.colors,
  });

  final String label;
  final String value;
  final Color valueColor;
  final ThemeData theme;
  final ColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: valueColor,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
