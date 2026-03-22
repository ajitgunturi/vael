import 'package:flutter/material.dart';

import '../../../shared/theme/spacing.dart';

/// A selectable card displaying a risk profile option.
///
/// Shows an icon, risk level name, description, and default equity allocation
/// percentage. Cards are visually distinct when selected (primary border + fill).
class RiskProfileCard extends StatelessWidget {
  const RiskProfileCard({
    super.key,
    required this.riskProfile,
    required this.isSelected,
    required this.onTap,
  });

  /// One of 'CONSERVATIVE', 'MODERATE', 'AGGRESSIVE'.
  final String riskProfile;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _configFor(riskProfile);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              config.icon,
              size: 32,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              config.label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              config.equityLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              config.description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskConfig {
  final IconData icon;
  final String label;
  final String equityLabel;
  final String description;

  const _RiskConfig({
    required this.icon,
    required this.label,
    required this.equityLabel,
    required this.description,
  });
}

_RiskConfig _configFor(String riskProfile) {
  return switch (riskProfile) {
    'CONSERVATIVE' => const _RiskConfig(
      icon: Icons.shield,
      label: 'Conservative',
      equityLabel: '35% Equity',
      description: 'Lower risk, stable growth',
    ),
    'AGGRESSIVE' => const _RiskConfig(
      icon: Icons.rocket_launch,
      label: 'Aggressive',
      equityLabel: '85% Equity',
      description: 'Higher risk, higher potential',
    ),
    _ => const _RiskConfig(
      icon: Icons.balance,
      label: 'Moderate',
      equityLabel: '60% Equity',
      description: 'Balanced risk and growth',
    ),
  };
}
