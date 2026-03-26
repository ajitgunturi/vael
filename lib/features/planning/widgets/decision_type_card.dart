import 'package:flutter/material.dart';

import '../../../shared/theme/color_tokens.dart';
import '../../../shared/theme/spacing.dart';

/// Selectable card for a decision type in the wizard Step 1 grid.
///
/// Shows an icon, label, and description. Selected state uses
/// primaryContainer background with primary 2dp border.
class DecisionTypeCard extends StatelessWidget {
  const DecisionTypeCard({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = ColorTokens.of(context);
    final theme = Theme.of(context);

    return Semantics(
      label: '$label. $description${isSelected ? '. Selected' : ''}',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.primaryContainer
                : colors.surfaceContainer,
            borderRadius: BorderRadius.circular(Spacing.cardRadius),
            border: isSelected
                ? Border.all(color: colors.primary, width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: colors.onSurfaceVariant),
              const SizedBox(height: Spacing.sm),
              Text(label, style: theme.textTheme.titleMedium),
              const SizedBox(height: Spacing.xs),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
