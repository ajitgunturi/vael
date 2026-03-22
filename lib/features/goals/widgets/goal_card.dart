import 'package:flutter/material.dart';

import '../../../core/database/database.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/theme/spacing.dart';
import '../../../shared/utils/formatters.dart';

/// Reusable goal card showing name, status, progress bar, and amounts.
///
/// Extracted from DashboardScreen._GoalTile for use in both
/// the dashboard goals section and the dedicated GoalListScreen.
class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.goal, this.onTap});

  final Goal goal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = ColorTokens.of(context);
    final progress = goal.targetAmount > 0
        ? (goal.currentSavings / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final status = _statusLabel(goal.status, tokens);
    final savedFormatted = formatIndianNumber(goal.currentSavings ~/ 100);
    final targetFormatted = formatIndianNumber(goal.targetAmount ~/ 100);

    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.sm + Spacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      goal.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    status.label,
                    style: TextStyle(color: status.color, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: tokens.surfaceContainerHigh,
                  valueColor: AlwaysStoppedAnimation(status.color),
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                '₹$savedFormatted / ₹$targetFormatted',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static ({String label, Color color}) _statusLabel(
    String status,
    ColorTokens tokens,
  ) {
    return switch (status) {
      'completed' => (label: 'Completed', color: tokens.income),
      'onTrack' => (label: 'On Track', color: tokens.income),
      'atRisk' => (label: 'At Risk', color: tokens.expense),
      _ => (label: 'Active', color: tokens.neutral),
    };
  }
}
