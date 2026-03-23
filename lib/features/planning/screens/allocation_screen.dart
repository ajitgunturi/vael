import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/financial/allocation_engine.dart';
import '../../../core/models/enums.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/theme/spacing.dart';
import '../providers/allocation_provider.dart';
import '../providers/life_profile_provider.dart';
import '../widgets/allocation_donut_pair.dart';
import '../widgets/rebalancing_delta_table.dart';
import 'glide_path_editor_screen.dart';
import '../../../features/investments/screens/investment_portfolio_screen.dart';
import 'life_profile_wizard_screen.dart';

/// Displays current vs target asset allocation with rebalancing guidance.
///
/// Entry points: Settings > Financial Planning > "Allocation Targets",
/// and InvestmentPortfolioScreen banner tap (NAV-07).
class AllocationScreen extends ConsumerWidget {
  const AllocationScreen({
    super.key,
    required this.familyId,
    required this.userId,
  });

  final String familyId;
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(
      lifeProfileProvider((userId: userId, familyId: familyId)),
    );
    final profile = profileAsync.whenOrNull(data: (p) => p);
    final userAge = profile != null ? _ageFromDob(profile.dateOfBirth) : 30;
    final riskProfile = profile?.riskProfile ?? 'moderate';

    final currentAsync = ref.watch(
      currentAllocationProvider((familyId: familyId, userAge: userAge)),
    );

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Asset Allocation')),
      body: currentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Could not compute allocation. Check your investment data and try again.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
        data: (currentValuePaise) {
          final hasHoldings = currentValuePaise.values.any((v) => v > 0);

          if (!hasHoldings) {
            return _EmptyNoHoldings(familyId: familyId, userId: userId);
          }

          if (profile == null) {
            return _NoProfileView(
              familyId: familyId,
              userId: userId,
              currentValuePaise: currentValuePaise,
            );
          }

          // Build custom targets from DB.
          final customTargetsAsync = ref.watch(
            customAllocationTargetsProvider(profile.id),
          );
          final customOverrides = customTargetsAsync.whenOrNull(
            data: (targets) => targets
                .map(
                  (t) => AllocationTargetOverride(
                    ageBandStart: t.ageBandStart,
                    ageBandEnd: t.ageBandEnd,
                    equityBp: t.equityBp,
                    debtBp: t.debtBp,
                    goldBp: t.goldBp,
                    cashBp: t.cashBp,
                  ),
                )
                .toList(),
          );

          final target = ref.watch(
            targetAllocationProvider((
              age: userAge,
              riskProfile: riskProfile,
              customTargets: customOverrides,
            )),
          );

          final deltas = ref.watch(
            rebalancingDeltasProvider((
              currentValuePaise: currentValuePaise,
              target: target,
            )),
          );

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AllocationDonutPair(
                      currentAllocation: currentValuePaise,
                      targetAllocation: target,
                    ),
                    const SizedBox(height: Spacing.lg),
                    RebalancingDeltaTable(deltas: deltas),
                    const SizedBox(height: Spacing.md),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => GlidePathEditorScreen(
                              lifeProfileId: profile.id,
                              riskProfile: riskProfile,
                              userAge: userAge,
                            ),
                          ),
                        ),
                        icon: const Text('Customize Targets'),
                        label: const Icon(Icons.chevron_right),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyNoHoldings extends StatelessWidget {
  const _EmptyNoHoldings({required this.familyId, required this.userId});

  final String familyId;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: Spacing.md),
            Text('No investments yet', style: theme.textTheme.headlineMedium),
            const SizedBox(height: Spacing.sm),
            Text(
              'Add your investments to see how your portfolio is allocated across asset classes.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.lg),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        InvestmentPortfolioScreen(familyId: familyId),
                  ),
                );
              },
              child: const Text('Add Investment'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoProfileView extends ConsumerWidget {
  const _NoProfileView({
    required this.familyId,
    required this.userId,
    required this.currentValuePaise,
  });

  final String familyId;
  final String userId;
  final Map<AssetClass, int> currentValuePaise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = ColorTokens.of(context);

    // Show current allocation only (no target) + CTA for profile setup.
    // Use a default target for display so the donut pair can still render.
    final defaultTarget = AllocationEngine.targetForAge(
      age: 30,
      riskProfile: 'moderate',
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AllocationDonutPair(
                currentAllocation: currentValuePaise,
                targetAllocation: defaultTarget,
              ),
              const SizedBox(height: Spacing.lg),
              // Profile setup card
              Card(
                color: colors.surfaceContainerHigh,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Spacing.cardRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set up your Life Profile',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: Spacing.sm),
                      Text(
                        'Your life profile provides age-based allocation targets. Current allocation is shown without targets.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: Spacing.md),
                      FilledButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => LifeProfileWizardScreen(
                              userId: userId,
                              familyId: familyId,
                            ),
                          ),
                        ),
                        child: const Text('Set Up Profile'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

int _ageFromDob(DateTime dob) {
  final now = DateTime.now();
  int age = now.year - dob.year;
  if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
    age--;
  }
  return age;
}
