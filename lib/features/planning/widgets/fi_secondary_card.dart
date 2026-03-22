import 'package:flutter/material.dart';

import '../../../shared/theme/color_tokens.dart';
import '../../../shared/theme/spacing.dart';

/// Card for secondary FI metrics (Years to FI, Coast FI).
///
/// When [isUnreachable] is true, displays "Not reachable at current rate"
/// in warning colors instead of the normal value.
class FiSecondaryCard extends StatelessWidget {
  const FiSecondaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.subtext,
    this.isUnreachable = false,
  });

  /// Card title (e.g. "Years to FI", "Coast FI").
  final String label;

  /// Display value (e.g. "18 years", "Rs 85 L").
  final String value;

  /// Context text below the value.
  final String subtext;

  /// Whether the metric is unreachable (shows warning state).
  final bool isUnreachable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = ColorTokens.of(context);

    final valueColor = isUnreachable
        ? colors.onWarningContainer
        : colors.onSurface;
    final displayValue = isUnreachable
        ? 'Not reachable at current rate'
        : value;
    final valueStyle = isUnreachable
        ? theme.textTheme.bodyMedium?.copyWith(color: valueColor)
        : theme.textTheme.headlineMedium?.copyWith(color: valueColor);

    return Card(
      color: isUnreachable ? colors.warningContainer : colors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(displayValue, style: valueStyle),
            if (!isUnreachable) ...[
              const SizedBox(height: Spacing.xs),
              Text(
                subtext,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
