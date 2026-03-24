import 'package:flutter/material.dart';

import '../../../shared/theme/color_tokens.dart';
import '../../../shared/theme/spacing.dart';

/// Reusable tappable card for a single financial health metric.
///
/// When [showSetup] is true, displays a "Set up" CTA button instead of the
/// metric value. Used on the planning dashboard for unconfigured features.
class HealthMetricCard extends StatelessWidget {
  const HealthMetricCard({
    super.key,
    required this.label,
    this.value,
    this.subtitle,
    this.valueColor,
    this.icon,
    this.onTap,
    this.showSetup = false,
    this.setupLabel = 'Set up',
  });

  final String label;
  final String? value;
  final String? subtitle;
  final Color? valueColor;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool showSetup;
  final String setupLabel;

  @override
  Widget build(BuildContext context) {
    final colors = ColorTokens.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: '$label: ${showSetup ? "not configured" : value}',
      child: Card(
        elevation: 0,
        color: colors.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: colors.onSurfaceVariant),
                      const SizedBox(width: Spacing.xs),
                    ],
                    Expanded(
                      child: Text(
                        label,
                        style: textTheme.labelMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                if (showSetup)
                  OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.md,
                        vertical: Spacing.xs,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(setupLabel),
                  )
                else ...[
                  Text(
                    value ?? '--',
                    style: textTheme.headlineSmall?.copyWith(
                      color: valueColor ?? colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: Spacing.xs),
                    Text(
                      subtitle!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
