import 'package:flutter/material.dart';

import '../../../shared/theme/spacing.dart';

/// A labeled slider that displays a percentage but stores/emits integer
/// basis points (bp). 100 bp = 1%.
///
/// Example: Income Growth at 800 bp displays as "8.0%" on the slider.
class RateSlider extends StatelessWidget {
  const RateSlider({
    super.key,
    required this.label,
    required this.valueBp,
    required this.minBp,
    required this.maxBp,
    this.stepBp = 50,
    required this.onChanged,
  });

  /// Display label (e.g. "Income Growth").
  final String label;

  /// Current value in basis points.
  final int valueBp;

  /// Minimum value in basis points.
  final int minBp;

  /// Maximum value in basis points.
  final int maxBp;

  /// Step size in basis points (default 50 bp = 0.5%).
  final int stepBp;

  /// Callback emitting the new value in basis points.
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayPercent = (valueBp / 100).toStringAsFixed(1);
    final divisions = ((maxBp - minBp) / stepBp).round();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: theme.textTheme.bodyMedium),
              Text(
                '$displayPercent%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: valueBp.toDouble(),
            min: minBp.toDouble(),
            max: maxBp.toDouble(),
            divisions: divisions > 0 ? divisions : 1,
            label: '$displayPercent%',
            onChanged: (v) => onChanged(v.round()),
          ),
        ],
      ),
    );
  }
}
