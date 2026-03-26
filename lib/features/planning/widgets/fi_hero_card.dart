import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/models/money.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/theme/spacing.dart';

/// Formats paise into a compact Indian display (e.g. "Rs 3.2 Cr", "Rs 85 L").
String _formatCompactIndian(int paise) {
  final rupees = paise / 100;
  if (rupees >= 10000000) {
    // Crores
    final cr = rupees / 10000000;
    final display = cr >= 100
        ? '${cr.round()} Cr'
        : cr >= 10
        ? '${cr.toStringAsFixed(1)} Cr'
        : '${cr.toStringAsFixed(2)} Cr';
    return display;
  } else if (rupees >= 100000) {
    // Lakhs
    final l = rupees / 100000;
    final display = l >= 100
        ? '${l.round()} L'
        : l >= 10
        ? '${l.toStringAsFixed(1)} L'
        : '${l.toStringAsFixed(2)} L';
    return display;
  } else {
    return Money(paise).formatted;
  }
}

/// Large hero card displaying the FI number prominently.
///
/// Shows the Financial Independence Number with context about the
/// underlying assumptions (expenses, SWR, inflation).
class FiHeroCard extends StatelessWidget {
  const FiHeroCard({
    super.key,
    required this.fiNumberPaise,
    required this.expenseLabel,
    required this.swrPercent,
    required this.inflationPercent,
  });

  /// The computed FI number in paise.
  final int fiNumberPaise;

  /// Pre-formatted expense string (e.g. "Rs 6 L").
  final String expenseLabel;

  /// SWR as a display percentage string (e.g. "3.0").
  final String swrPercent;

  /// Inflation as a display percentage string (e.g. "6.0").
  final String inflationPercent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = ColorTokens.of(context);
    final formattedAmount = 'Rs ${_formatCompactIndian(fiNumberPaise)}';

    return Card(
      color: colors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Financial Independence Number',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Semantics(
              label: 'Financial Independence number: $formattedAmount',
              excludeSemantics: true,
              child: Text(
                formattedAmount,
                style: theme.textTheme.displayLarge?.copyWith(
                  color: colors.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              'Annual expenses of $expenseLabel at $swrPercent% SWR, '
              'adjusted for $inflationPercent% inflation',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
