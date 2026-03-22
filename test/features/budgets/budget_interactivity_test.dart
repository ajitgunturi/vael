import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/financial/budget_summary.dart';
import 'package:vael/core/providers/category_providers.dart';
import 'package:vael/features/budgets/providers/budget_providers.dart';
import 'package:vael/features/budgets/screens/budget_screen.dart';

/// Dummy CategoryGroup data for tests.
final _testGroups = [
  CategoryGroup(
    id: 'ESSENTIAL',
    name: 'Essential',
    displayOrder: 0,
    familyId: 'fam_a',
  ),
  CategoryGroup(
    id: 'NON_ESSENTIAL',
    name: 'Non-Essential',
    displayOrder: 1,
    familyId: 'fam_a',
  ),
  CategoryGroup(
    id: 'INVESTMENTS',
    name: 'Investments',
    displayOrder: 2,
    familyId: 'fam_a',
  ),
  CategoryGroup(
    id: 'HOME_EXPENSES',
    name: 'Home Expenses',
    displayOrder: 3,
    familyId: 'fam_a',
  ),
];

void main() {
  Widget buildTestApp({required List<BudgetSummaryRow> rows}) {
    final key = (familyId: 'fam_a', year: 2025, month: 3);
    return ProviderScope(
      overrides: [
        budgetSummaryProvider(key).overrideWith((_) async => rows),
        categoryGroupsProvider(
          'fam_a',
        ).overrideWith((_) => Stream.value(_testGroups)),
      ],
      child: const MaterialApp(
        home: BudgetScreen(familyId: 'fam_a', year: 2025, month: 3),
      ),
    );
  }

  group('Budget Screen Interactivity', () {
    testWidgets('shows FAB to create a new budget', (tester) async {
      await tester.pumpWidget(buildTestApp(rows: []));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('tapping FAB navigates to budget form', (tester) async {
      await tester.pumpWidget(buildTestApp(rows: []));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Budget form should be visible
      expect(find.text('New Budget'), findsOneWidget);
    });

    testWidgets('budget cards are tappable', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          rows: [
            const BudgetSummaryRow(
              categoryGroup: 'ESSENTIAL',
              limitAmount: 1000000,
              actualSpent: 600000,
              budgetId: 'b1',
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Card should have InkWell for tap feedback
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('tapping a budget card navigates to edit form', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          rows: [
            const BudgetSummaryRow(
              categoryGroup: 'ESSENTIAL',
              limitAmount: 1000000,
              actualSpent: 600000,
              budgetId: 'b1',
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Essential'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Budget'), findsOneWidget);
    });

    testWidgets('shows remaining amount on budget cards', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          rows: [
            const BudgetSummaryRow(
              categoryGroup: 'ESSENTIAL',
              limitAmount: 1000000, // ₹10,000
              actualSpent: 600000, // ₹6,000
              budgetId: 'b1',
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Remaining: ₹4,000
      expect(find.textContaining('4,000'), findsOneWidget);
      expect(find.textContaining('remaining'), findsOneWidget);
    });

    testWidgets('budget form has category group dropdown and amount field', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp(rows: []));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });
  });
}
