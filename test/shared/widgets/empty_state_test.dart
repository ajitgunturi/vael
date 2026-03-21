import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/shared/widgets/empty_state.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('EmptyState', () {
    testWidgets('shows icon, title, and subtitle', (tester) async {
      await tester.pumpWidget(
        wrap(
          const EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No transactions yet',
            subtitle: 'Add your first transaction to get started',
          ),
        ),
      );

      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
      expect(find.text('No transactions yet'), findsOneWidget);
      expect(
        find.text('Add your first transaction to get started'),
        findsOneWidget,
      );
    });

    testWidgets('shows action button when provided', (tester) async {
      await tester.pumpWidget(
        wrap(
          EmptyState(
            icon: Icons.account_balance_wallet_outlined,
            title: 'No accounts',
            actionLabel: 'Add Account',
            onAction: () {},
          ),
        ),
      );

      expect(find.text('Add Account'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('action button triggers callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrap(
          EmptyState(
            icon: Icons.pie_chart_outline,
            title: 'No budgets',
            actionLabel: 'Create Budget',
            onAction: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Create Budget'));
      expect(tapped, isTrue);
    });

    testWidgets('does not show action button when onAction is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const EmptyState(icon: Icons.flag_outlined, title: 'No goals yet'),
        ),
      );

      expect(find.byType(FilledButton), findsNothing);
    });
  });
}
