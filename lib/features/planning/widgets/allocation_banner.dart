import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/enums.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/theme/spacing.dart';
import '../providers/allocation_provider.dart';
import '../screens/allocation_screen.dart';

/// NAV-07: Banner on InvestmentPortfolioScreen showing equity allocation.
///
/// Displays current equity % vs target, with tap navigation to
/// [AllocationScreen]. Hidden when no investment holdings exist.
class AllocationBanner extends ConsumerWidget {
  const AllocationBanner({
    super.key,
    required this.familyId,
    required this.userId,
    required this.userAge,
    this.riskProfile = 'moderate',
  });

  final String familyId;
  final String userId;
  final int userAge;
  final String riskProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAsync = ref.watch(
      currentAllocationProvider((familyId: familyId, userAge: userAge)),
    );

    return currentAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (currentValuePaise) {
        final hasHoldings = currentValuePaise.values.any((v) => v > 0);
        if (!hasHoldings) return const SizedBox.shrink();

        // Compute equity actual %.
        final total = currentValuePaise.values.fold<int>(0, (a, b) => a + b);
        final equityPaise = currentValuePaise[AssetClass.equity] ?? 0;
        final actualPct = total > 0 ? (equityPaise * 100 / total).round() : 0;

        // Compute equity target %.
        final target = ref.watch(
          targetAllocationProvider((
            age: userAge,
            riskProfile: riskProfile,
            customTargets: null,
          )),
        );
        final targetPct = (target.equityBp / 100).round();

        final theme = Theme.of(context);
        final colors = ColorTokens.of(context);

        return Semantics(
          label:
              'Equity allocation $actualPct% versus target $targetPct%. Tap to view allocation details.',
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    AllocationScreen(familyId: familyId, userId: userId),
              ),
            ),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: Spacing.sm),
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(Spacing.cardRadius),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Equity $actualPct% (target $targetPct%)',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    'View Allocation',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  Icon(Icons.chevron_right, size: 18, color: colors.primary),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
