import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/financial/milestone_engine.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/theme/spacing.dart';
import '../providers/milestone_provider.dart';

/// Formats paise into compact Indian display (e.g., "Rs 1.5 Cr", "Rs 80 L").
String _formatIndian(int paise) {
  final rupees = paise.abs() / 100;
  if (rupees >= 10000000) {
    final cr = rupees / 10000000;
    return 'Rs ${cr >= 10 ? cr.toStringAsFixed(1) : cr.toStringAsFixed(2)} Cr';
  } else if (rupees >= 100000) {
    final l = rupees / 100000;
    return 'Rs ${l >= 10 ? l.toStringAsFixed(1) : l.toStringAsFixed(2)} L';
  } else if (rupees >= 1000) {
    final k = rupees / 1000;
    return 'Rs ${k.toStringAsFixed(1)} K';
  }
  return 'Rs ${rupees.toStringAsFixed(0)}';
}

/// Individual milestone progress card showing age, target, projection, and status.
class MilestoneCard extends StatelessWidget {
  const MilestoneCard({super.key, required this.item, this.onEditTap});

  final MilestoneDisplayItem item;
  final VoidCallback? onEditTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = ColorTokens.of(context);

    final textColor = item.isPast ? colors.onSurfaceDisabled : colors.onSurface;
    final subtextColor = item.isPast
        ? colors.onSurfaceDisabled
        : colors.onSurfaceVariant;
    final progressColor = item.isPast ? colors.neutral : _statusColor(colors);
    final badgeBg = item.isPast
        ? colors.surfaceContainerHigh
        : colors.primaryContainer;
    final badgeTextColor = item.isPast
        ? colors.onSurfaceDisabled
        : colors.onPrimaryContainer;

    final progressRatio = item.targetAmountPaise > 0
        ? min(1.0, item.projectedAmountPaise / item.targetAmountPaise)
        : 0.0;

    return Semantics(
      label:
          'Age ${item.age} milestone: ${_statusLabel(item.status)}, '
          'target ${_formatIndian(item.targetAmountPaise)}, '
          'projected ${_formatIndian(item.projectedAmountPaise)}',
      child: Card(
        color: colors.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
          side: item.isPast
              ? BorderSide(color: colors.outlineVariant)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Age badge
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: badgeBg,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${item.age}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: badgeTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Target: ${_formatIndian(item.targetAmountPaise)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: subtextColor,
                          ),
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          '${item.isPast ? "Actual" : "Projected"}: '
                          '${_formatIndian(item.projectedAmountPaise)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status chip + edit
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildStatusChip(colors),
                      if (!item.isPast && onEditTap != null) ...[
                        const SizedBox(height: Spacing.xs),
                        Semantics(
                          label: 'Edit target for age ${item.age}',
                          child: GestureDetector(
                            onTap: onEditTap,
                            child: Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressRatio,
                  minHeight: 8,
                  backgroundColor: colors.outlineVariant,
                  valueColor: AlwaysStoppedAnimation(progressColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ColorTokens colors) {
    final (bg, fg) = _chipColors(colors);
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(
        _statusLabel(item.status),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: fg,
          height: 1,
        ),
      ),
    );
  }

  (Color, Color) _chipColors(ColorTokens colors) {
    return switch (item.status) {
      MilestoneStatus.onTrack || MilestoneStatus.reached => (
        colors.incomeContainer,
        colors.onIncomeContainer,
      ),
      MilestoneStatus.behind || MilestoneStatus.missed => (
        colors.expenseContainer,
        colors.onExpenseContainer,
      ),
      MilestoneStatus.ahead => (
        colors.primaryContainer,
        colors.onPrimaryContainer,
      ),
    };
  }

  Color _statusColor(ColorTokens colors) {
    return switch (item.status) {
      MilestoneStatus.onTrack || MilestoneStatus.reached => colors.income,
      MilestoneStatus.behind || MilestoneStatus.missed => colors.expense,
      MilestoneStatus.ahead => colors.primary,
    };
  }

  static String _statusLabel(MilestoneStatus status) {
    return switch (status) {
      MilestoneStatus.onTrack => 'On Track',
      MilestoneStatus.behind => 'Behind',
      MilestoneStatus.ahead => 'Ahead',
      MilestoneStatus.reached => 'Reached',
      MilestoneStatus.missed => 'Missed',
    };
  }
}
