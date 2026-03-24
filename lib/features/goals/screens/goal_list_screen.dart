import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../shared/theme/spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/goal_providers.dart';
import '../widgets/goal_card.dart';
import '../widgets/goal_type_picker.dart';
import '../widgets/sinking_fund_card.dart';

/// Lists all goals for a family in a tabbed layout.
///
/// Tabs: Sinking Funds (default) | Investments | Purchases.
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
    _tabController = TabController(length: 3, vsync: this);
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
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SinkingFundsTab(familyId: widget.familyId),
          _InvestmentsTab(familyId: widget.familyId),
          _PurchasesTab(familyId: widget.familyId),
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
            ...active.map((g) => SinkingFundCard(goal: g)),
            if (completed.isNotEmpty)
              ExpansionTile(
                title: Text('Completed (${completed.length})'),
                initiallyExpanded: false,
                children: completed
                    .map((g) => SinkingFundCard(goal: g))
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
