import 'package:flutter/material.dart';

import '../../../core/models/enums.dart';
import '../../../shared/theme/spacing.dart';
import '../screens/goal_form_screen.dart';

/// Bottom sheet picker for selecting goal type before navigating to form.
///
/// Offers three options: Sinking Fund, Investment Goal, Major Purchase.
/// Each option navigates to [GoalFormScreen] with the corresponding category.
class GoalTypePicker extends StatelessWidget {
  const GoalTypePicker({super.key, required this.familyId});

  final String familyId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              child: Text(
                'New Goal',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: Spacing.sm),
            ListTile(
              leading: const Icon(Icons.savings),
              title: const Text('Sinking Fund'),
              subtitle: const Text('Short-term savings for a specific expense'),
              onTap: () => _navigate(context, GoalCategory.sinkingFund),
            ),
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: const Text('Investment Goal'),
              subtitle: const Text('Long-term wealth building target'),
              onTap: () => _navigate(context, GoalCategory.investmentGoal),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Major Purchase'),
              subtitle: const Text('Save for a big-ticket item'),
              onTap: () => _navigate(context, GoalCategory.purchase),
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, GoalCategory category) {
    Navigator.of(context).pop(); // close bottom sheet
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            GoalFormScreen(familyId: familyId, initialCategory: category),
      ),
    );
  }
}

/// Shows the [GoalTypePicker] as a modal bottom sheet.
void showGoalTypePicker(BuildContext context, String familyId) {
  showModalBottomSheet(
    context: context,
    builder: (_) => GoalTypePicker(familyId: familyId),
  );
}
