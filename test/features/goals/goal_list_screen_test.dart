import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vael/core/database/database.dart';
import 'package:vael/features/goals/providers/goal_providers.dart';
import 'package:vael/features/goals/screens/goal_list_screen.dart';
import 'package:vael/shared/theme/app_theme.dart';

const _familyId = 'fam_goals';

Goal _fakeGoal({
  required String id,
  required String name,
  required int targetAmount,
  int currentSavings = 0,
  String status = 'active',
  int priority = 1,
}) {
  return Goal(
    id: id,
    name: name,
    targetAmount: targetAmount,
    targetDate: DateTime(2027, 6, 1),
    currentSavings: currentSavings,
    inflationRate: 0.06,
    priority: priority,
    status: status,
    linkedAccountId: null,
    familyId: _familyId,
    createdAt: DateTime(2025),
  );
}

Widget _buildApp({required List<Goal> goals}) {
  return ProviderScope(
    overrides: [
      goalListProvider(_familyId).overrideWith((_) => Stream.value(goals)),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      home: const GoalListScreen(familyId: _familyId),
    ),
  );
}

void main() {
  group('GoalListScreen', () {
    testWidgets('shows empty state when no goals', (tester) async {
      await tester.pumpWidget(_buildApp(goals: []));
      await tester.pumpAndSettle();

      expect(find.text('No goals yet'), findsOneWidget);
    });

    testWidgets('shows goal cards with name and progress', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          goals: [
            _fakeGoal(
              id: 'g1',
              name: 'Emergency Fund',
              targetAmount: 50000000,
              currentSavings: 20000000,
            ),
            _fakeGoal(
              id: 'g2',
              name: 'House Down Payment',
              targetAmount: 200000000,
              currentSavings: 50000000,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Emergency Fund'), findsOneWidget);
      expect(find.text('House Down Payment'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
    });

    testWidgets('shows status chips for different statuses', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          goals: [
            _fakeGoal(
              id: 'g1',
              name: 'Active Goal',
              targetAmount: 100000,
              status: 'active',
            ),
            _fakeGoal(
              id: 'g2',
              name: 'Completed Goal',
              targetAmount: 100000,
              status: 'completed',
              currentSavings: 100000,
            ),
            _fakeGoal(
              id: 'g3',
              name: 'At Risk Goal',
              targetAmount: 100000,
              status: 'atRisk',
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('At Risk'), findsOneWidget);
    });

    testWidgets('shows FAB for adding new goal', (tester) async {
      await tester.pumpWidget(_buildApp(goals: []));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('shows formatted amounts in INR', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          goals: [
            _fakeGoal(
              id: 'g1',
              name: 'Big Goal',
              targetAmount: 100000000, // ₹10 lakh
              currentSavings: 25000000, // ₹2.5 lakh
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Indian notation: 10,00,000 and 2,50,000
      expect(find.textContaining('10,00,000'), findsOneWidget);
      expect(find.textContaining('2,50,000'), findsOneWidget);
    });
  });
}
