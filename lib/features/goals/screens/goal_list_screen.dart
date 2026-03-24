import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/providers/session_providers.dart';
import '../../../shared/theme/spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../planning/providers/milestone_provider.dart';
import '../../planning/widgets/milestone_card.dart';
import '../providers/goal_providers.dart';
import '../widgets/goal_card.dart';
import '../widgets/contribution_sheet.dart';
import '../widgets/goal_type_picker.dart';
import '../widgets/sinking_fund_card.dart';

/// Lists all goals for a family in a tabbed layout.
///
/// Tabs: Sinking Funds (default) | Investments | Purchases | Milestones.
/// FAB opens GoalTypePicker bottom sheet for category selection.
class GoalListScreen extends ConsumerStatefulWidget {
  const GoalListScreen({super.key, required this.familyId});

  final String familyId;

  @override
  ConsumerState<GoalListScreen> createState() => _GoalListScreenState();
}

class _GoalListScreenState extends ConsumerState<GoalListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Sinking Funds'),
            Tab(text: 'Investments'),
            Tab(text: 'Purchases'),
            Tab(text: 'Milestones'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SinkingFundsTab(familyId: widget.familyId),
          _InvestmentsTab(familyId: widget.familyId),
          _PurchasesTab(familyId: widget.familyId),
          _MilestonesTab(familyId: widget.familyId),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showGoalTypePicker(context, widget.familyId),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Sinking Funds tab with active/completed split and ExpansionTile.
class _SinkingFundsTab extends ConsumerWidget {
  const _SinkingFundsTab({required this.familyId});

  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(sinkingFundGoalsProvider(familyId));

    return goalsAsync.when(
      data: (goals) {
        if (goals.isEmpty) {
          return const EmptyState(
            icon: Icons.savings,
            title: 'No sinking funds yet',
            subtitle: 'Save for specific upcoming expenses',
          );
        }

        final active = goals.where((g) => g.status != 'completed').toList();
        final completed = goals.where((g) => g.status == 'completed').toList();

        return ListView(
          padding: const EdgeInsets.all(Spacing.md),
          children: [
            ...active.map(
              (g) => SinkingFundCard(
                goal: g,
                onTap: g.status != 'completed'
                    ? () => showContributionSheet(context, g)
                    : null,
              ),
            ),
            if (completed.isNotEmpty)
              ExpansionTile(
                title: Text('Completed (${completed.length})'),
                initiallyExpanded: false,
                children: completed
                    .map(
                      (g) => SinkingFundCard(
                        goal: g,
                        onTap: g.status != 'completed'
                            ? () => showContributionSheet(context, g)
                            : null,
                      ),
                    )
                    .toList(),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

/// Investments tab using GoalCard for investment/retirement goals.
class _InvestmentsTab extends ConsumerWidget {
  const _InvestmentsTab({required this.familyId});

  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(investmentGoalsProvider(familyId));

    return _buildGoalList(
      goalsAsync,
      emptyIcon: Icons.trending_up,
      emptyTitle: 'No investment goals yet',
      emptySubtitle: 'Set a long-term wealth building target',
    );
  }
}

/// Purchases tab using GoalCard for purchase goals.
class _PurchasesTab extends ConsumerWidget {
  const _PurchasesTab({required this.familyId});

  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(purchaseGoalsProvider(familyId));

    return _buildGoalList(
      goalsAsync,
      emptyIcon: Icons.shopping_cart,
      emptyTitle: 'No purchase goals yet',
      emptySubtitle: 'Save for a big-ticket item',
    );
  }
}

/// Milestones tab showing net worth milestone cards from life profile data.
class _MilestonesTab extends ConsumerWidget {
  const _MilestonesTab({required this.familyId});

  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(sessionUserIdProvider);
    if (userId == null) {
      return const EmptyState(
        icon: Icons.flag_outlined,
        title: 'No user session',
        subtitle: 'Sign in to see milestones',
      );
    }

    final milestonesAsync = ref.watch(
      milestoneListProvider((userId: userId, familyId: familyId)),
    );

    return milestonesAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const EmptyState(
            icon: Icons.flag_outlined,
            title: 'No milestones yet',
            subtitle: 'Set up your life profile to see net worth milestones',
          );
        }

        return ListView(
          padding: const EdgeInsets.all(Spacing.md),
          children: items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.md),
                  child: MilestoneCard(item: item),
                ),
              )
              .toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

Widget _buildGoalList(
  AsyncValue<List<Goal>> goalsAsync, {
  required IconData emptyIcon,
  required String emptyTitle,
  required String emptySubtitle,
}) {
  return goalsAsync.when(
    data: (goals) {
      if (goals.isEmpty) {
        return EmptyState(
          icon: emptyIcon,
          title: emptyTitle,
          subtitle: emptySubtitle,
        );
      }

      return ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: goals.map((g) => GoalCard(goal: g)).toList(),
      );
    },
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (e, _) => Center(child: Text('Error: $e')),
  );
}
