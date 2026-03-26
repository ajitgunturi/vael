import 'package:flutter/material.dart';

import '../../../core/financial/insights_engine.dart';
import '../../../shared/theme/spacing.dart';

/// Displays a single [PlanningInsight] as a color-coded alert card.
///
/// Left border strip color indicates severity:
/// - critical: [ColorScheme.error]
/// - warning: amber.shade700
/// - info: [ColorScheme.tertiary]
///
/// Tappable via [onTap] to navigate to the relevant detail screen.
class InsightAlertCard extends StatelessWidget {
  const InsightAlertCard({super.key, required this.insight, this.onTap});

  final PlanningInsight insight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Color borderColor;
    final IconData iconData;

    switch (insight.severity) {
      case InsightSeverity.critical:
        borderColor = colorScheme.error;
        iconData = Icons.error;
      case InsightSeverity.warning:
        borderColor = Colors.amber.shade700;
        iconData = Icons.warning_amber;
      case InsightSeverity.info:
        borderColor = colorScheme.tertiary;
        iconData = Icons.info_outline;
    }

    return Semantics(
      label: '${insight.severity.name}: ${insight.title}',
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: Spacing.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Colored left border strip
                Container(width: 4, color: borderColor),
                const SizedBox(width: Spacing.sm),
                Icon(iconData, color: borderColor, size: 20),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: Spacing.sm,
                      horizontal: Spacing.xs,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          insight.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          insight.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (onTap != null)
                  const Padding(
                    padding: EdgeInsets.only(right: Spacing.sm),
                    child: Icon(Icons.chevron_right, size: 20),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
