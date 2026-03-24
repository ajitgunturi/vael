import 'package:flutter/material.dart';

import '../../../core/financial/savings_allocation_engine.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/theme/spacing.dart';

/// Formats paise into compact Indian display: "25K", "1.2L", "2Cr".
String _compact(int paise) {
  final rupees = paise / 100;
  if (rupees >= 10000000) {
    final cr = rupees / 10000000;
    return '${cr >= 10 ? cr.toStringAsFixed(0) : cr.toStringAsFixed(1)}Cr';
  } else if (rupees >= 100000) {
    final l = rupees / 100000;
    return '${l >= 10 ? l.toStringAsFixed(0) : l.toStringAsFixed(1)}L';
  } else if (rupees >= 1000) {
    final k = rupees / 1000;
    return '${k >= 10 ? k.toStringAsFixed(0) : k.toStringAsFixed(1)}K';
  }
  return '${rupees.toInt()}';
}

/// Stacked horizontal bar chart showing income allocation breakdown.
///
/// Segments: Expenses -> EF -> Sinking Funds -> Investments -> Opportunity Fund -> Unallocated.
/// Each segment is color-coded by target type with a label below.
class SavingsWaterfallChart extends StatelessWidget {
  const SavingsWaterfallChart({
    super.key,
    required this.incomePaise,
    required this.expensesPaise,
    required this.allocations,
    required this.unallocatedPaise,
  });

  final int incomePaise;
  final int expensesPaise;
  final List<AllocationAdvice> allocations;
  final int unallocatedPaise;

  @override
  Widget build(BuildContext context) {
    final colors = ColorTokens.of(context);
    final theme = Theme.of(context);

    if (incomePaise <= 0) {
      return const SizedBox.shrink();
    }

    // Build segments: each has a flex weight, color, and label
    final segments = <_Segment>[];

    // Expenses segment
    if (expensesPaise > 0) {
      segments.add(
        _Segment(
          paise: expensesPaise,
          color: colors.expense,
          label: 'Expenses',
        ),
      );
    }

    // Allocation segments
    for (final a in allocations) {
      if (a.allocatedPaise <= 0) continue;
      segments.add(
        _Segment(
          paise: a.allocatedPaise,
          color: _colorForTargetType(a.targetType, colors),
          label: a.targetName,
        ),
      );
    }

    // Unallocated
    if (unallocatedPaise > 0) {
      segments.add(
        _Segment(
          paise: unallocatedPaise,
          color: colors.onSurfaceVariant.withValues(alpha: 0.3),
          label: 'Free',
        ),
      );
    }

    // Calculate flex values (proportion of income)
    final totalPaise = segments.fold<int>(0, (sum, s) => sum + s.paise);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Savings Waterfall', style: theme.textTheme.titleSmall),
        const SizedBox(height: Spacing.sm),

        // The stacked bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 32,
            child: Row(
              children: segments.map((s) {
                final flex = (s.paise * 1000 / totalPaise).round().clamp(
                  1,
                  1000,
                );
                return Expanded(
                  flex: flex,
                  child: Container(color: s.color),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: Spacing.xs),

        // Labels below
        Row(
          children: segments.map((s) {
            final flex = (s.paise * 1000 / totalPaise).round().clamp(1, 1000);
            return Expanded(
              flex: flex,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Column(
                  children: [
                    Text(
                      _compact(s.paise),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        color: colors.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _colorForTargetType(String targetType, ColorTokens colors) {
    switch (targetType) {
      case 'emergencyFund':
        return const Color(0xFF2196F3);
      case 'sinkingFund':
        return const Color(0xFF009688);
      case 'investmentGoal':
        return colors.income;
      case 'opportunityFund':
        return const Color(0xFF9C27B0);
      default:
        return colors.neutral;
    }
  }
}

class _Segment {
  final int paise;
  final Color color;
  final String label;
  const _Segment({
    required this.paise,
    required this.color,
    required this.label,
  });
}
