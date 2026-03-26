import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_loading.dart';
import '../providers/life_profile_provider.dart';
import '../providers/milestone_provider.dart';
import '../widgets/milestone_card.dart';
import '../widgets/milestone_edit_sheet.dart';
import 'life_profile_wizard_screen.dart';

/// Dashboard showing 5 decade net-worth milestone cards with status tracking.
class MilestoneDashboardScreen extends ConsumerWidget {
  const MilestoneDashboardScreen({
    super.key,
    required this.familyId,
    required this.userId,
  });

  final String familyId;
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milestones = ref.watch(
      milestoneListProvider((userId: userId, familyId: familyId)),
    );
    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxWidth = screenWidth > 1200 ? 800.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(title: const Text('Net Worth Milestones')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: milestones.when(
            loading: () => ListView.builder(
              padding: const EdgeInsets.all(Spacing.md),
              itemCount: 5,
              itemBuilder: (_, __) => const SkeletonCard(height: 120),
            ),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.xl),
                child: Text('Error: $e'),
              ),
            ),
            data: (items) {
              if (items.isEmpty) {
                return EmptyState(
                  icon: Icons.flag_outlined,
                  title: 'No life profile yet',
                  subtitle:
                      'Set up your life profile to see personalized milestones '
                      'based on your age and goals.',
                  actionLabel: 'Set Up Profile',
                  onAction: () => _openLifeProfileWizard(context, ref),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(Spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Track your wealth at every decade',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: Spacing.md),
                    ...items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: Spacing.md),
                        child: MilestoneCard(
                          item: item,
                          onEditTap: item.isPast
                              ? null
                              : () => _openEditSheet(context, ref, item),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _openEditSheet(
    BuildContext context,
    WidgetRef ref,
    MilestoneDisplayItem item,
  ) {
    // Get the life profile id for persistence.
    final profileAsync = ref.read(
      lifeProfileProvider((userId: userId, familyId: familyId)),
    );
    final profile = profileAsync.value;
    if (profile == null) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => MilestoneEditSheet(
        age: item.age,
        currentProjectionPaise: item.projectedAmountPaise,
        currentTargetPaise: item.targetAmountPaise,
        userId: userId,
        familyId: familyId,
        lifeProfileId: profile.id,
        milestoneId: item.milestoneId,
      ),
    );
  }

  void _openLifeProfileWizard(BuildContext context, WidgetRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            LifeProfileWizardScreen(userId: userId, familyId: familyId),
      ),
    );
  }
}
