import 'package:flutter/material.dart';

import '../../../core/database/database.dart';
import '../../../core/financial/sinking_fund_engine.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/theme/spacing.dart';
import '../../../shared/utils/formatters.dart';

/// Card displaying sinking fund progress, pace, monthly needed, and days left.
///
/// Uses [SinkingFundEngine] for all computations. Color-codes the progress bar
/// by pace status: green (onTrack), amber (behind), red (atRisk).
class SinkingFundCard extends StatelessWidget {
  const SinkingFundCard({super.key, required this.goal, this.onTap});

  final Goal goal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = ColorTokens.of(context);
    final theme = Theme.of(context);
    final now = DateTime.now();

    final targetPaise = goal.targetAmount;
    final currentPaise = goal.currentSavings;
    final completed = SinkingFundEngine.isComplete(currentPaise, targetPaise);

    // Time calculations
    final daysLeft = SinkingFundEngine.daysRemaining(goal.targetDate, now);
    final totalMonths = _monthsBetween(goal.createdAt, goal.targetDate);
    final monthsRemaining = _monthsBetween(
      now,
      goal.targetDate,
    ).clamp(1, totalMonths);
    final monthsElapsed = totalMonths - monthsRemaining;

    final monthlyNeeded = SinkingFundEngine.monthlyNeededPaise(
      targetPaise,
      currentPaise,
      monthsRemaining,
    );
    final pace = SinkingFundEngine.paceStatus(
      targetPaise,
      currentPaise,
      totalMonths,
      monthsElapsed,
    );

    final progress = targetPaise > 0
        ? (currentPaise / targetPaise).clamp(0.0, 1.0)
        : 0.0;

    final paceColor = _paceColor(pace, tokens);
    final subTypeLabel = _subTypeLabel(goal.sinkingFundSubType);

    final savedFormatted = formatIndianNumber(currentPaise ~/ 100);
    final targetFormatted = formatIndianNumber(targetPaise ~/ 100);
    final monthlyFormatted = formatIndianNumber(monthlyNeeded ~/ 100);

    return Opacity(
      opacity: completed ? 0.6 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: Spacing.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(Spacing.sm + Spacing.xs),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Name + sub-type chip
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            goal.name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (subTypeLabel != null) ...[
                          const SizedBox(width: Spacing.xs),
                          _SubTypeChip(
                            label: completed ? 'Completed' : subTypeLabel,
                            color: completed ? tokens.income : tokens.primary,
                          ),
                        ] else if (completed) ...[
                          const SizedBox(width: Spacing.xs),
                          _SubTypeChip(
                            label: 'Completed',
                            color: tokens.income,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: Spacing.sm),
                    // Row 2: Progress bar
                    Semantics(
                      label: '${(progress * 100).round()} percent saved',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: tokens.surfaceContainerHigh,
                          valueColor: AlwaysStoppedAnimation(paceColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    // Row 3: amounts + days left
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\u20B9$savedFormatted / \u20B9$targetFormatted',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          completed ? 'Done' : '$daysLeft days left',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: tokens.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    // Row 4: monthly needed
                    if (!completed && monthlyNeeded > 0) ...[
                      const SizedBox(height: Spacing.xs),
                      Text(
                        'Save \u20B9$monthlyFormatted/mo to hit target',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: tokens.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
                // Checkmark overlay for completed
                if (completed)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(
                      Icons.check_circle,
                      color: tokens.income,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static int _monthsBetween(DateTime from, DateTime to) {
    final months = (to.year * 12 + to.month) - (from.year * 12 + from.month);
    return months > 0 ? months : 1;
  }

  static Color _paceColor(String pace, ColorTokens tokens) {
    return switch (pace) {
      'onTrack' => tokens.income,
      'behind' => tokens.warning,
      'atRisk' => tokens.expense,
      _ => tokens.neutral,
    };
  }

  static String? _subTypeLabel(String? subType) {
    if (subType == null || subType.isEmpty) return null;
    return switch (subType) {
      'tax' => 'Tax',
      'carMaintenance' => 'Car Maintenance',
      'travel' => 'Travel',
      'medical' => 'Medical',
      'insurance' => 'Insurance',
      'gifts' => 'Gifts',
      'homeRepair' => 'Home Repair',
      'techUpgrade' => 'Tech Upgrade',
      'custom' => 'Custom',
      _ => subType,
    };
  }
}

class _SubTypeChip extends StatelessWidget {
  const _SubTypeChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
