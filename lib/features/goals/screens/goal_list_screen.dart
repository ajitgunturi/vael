import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/goal_providers.dart';
import '../widgets/goal_card.dart';
import 'goal_form_screen.dart';

/// Lists all goals for a family with progress tracking.
class GoalListScreen extends ConsumerWidget {
  const GoalListScreen({super.key, required this.familyId});

  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalListProvider(familyId));

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
          return ListView.builder(
            padding: const EdgeInsets.all(Spacing.md),
            itemCount: goals.length,
            itemBuilder: (_, i) => GoalCard(goal: goals[i]),
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

  void _openForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GoalFormScreen(familyId: familyId)),
    );
  }
}
