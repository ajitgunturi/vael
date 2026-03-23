import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../shared/theme/spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/goal_providers.dart';
import '../widgets/goal_card.dart';
import 'goal_form_screen.dart';

/// Lists all goals for a family, sectioned by goalCategory.
///
/// Sections: Investment Goals, Purchase Goals, Retirement.
/// Empty sections are hidden.
class GoalListScreen extends ConsumerWidget {
  const GoalListScreen({super.key, required this.familyId});

  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalListProvider(familyId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return EmptyState(
              icon: Icons.flag,
              title: 'No goals yet',
              subtitle: 'Set a savings target to start tracking progress',
              actionLabel: 'Add Goal',
              onAction: () => _openForm(context),
            );
          }

          // Group by category
          final investmentGoals = goals
              .where(
                (g) =>
                    g.goalCategory == 'investmentGoal' ||
                    g.goalCategory.isEmpty,
              )
              .toList();
          final purchaseGoals = goals
              .where((g) => g.goalCategory == 'purchase')
              .toList();
          final retirementGoals = goals
              .where((g) => g.goalCategory == 'retirement')
              .toList();

          return ListView(
            padding: const EdgeInsets.all(Spacing.md),
            children: [
              if (investmentGoals.isNotEmpty)
                _buildSection(
                  context,
                  theme,
                  'Investment Goals',
                  investmentGoals,
                ),
              if (purchaseGoals.isNotEmpty)
                _buildSection(context, theme, 'Purchase Goals', purchaseGoals),
              if (retirementGoals.isNotEmpty)
                _buildSection(context, theme, 'Retirement', retirementGoals),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    ThemeData theme,
    String title,
    List<Goal> goals,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...goals.map((goal) => GoalCard(goal: goal)),
        const SizedBox(height: Spacing.md),
      ],
    );
  }

  void _openForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GoalFormScreen(familyId: familyId)),
    );
  }
}
