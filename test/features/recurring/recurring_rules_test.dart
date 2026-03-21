import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/features/recurring/screens/recurring_rules_screen.dart';

void main() {
  group('RecurringRuleCard', () {
    testWidgets('should display expense rule with frequency', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecurringRuleCard(
              name: 'Rent',
              kind: 'expense',
              amount: 2500000,
              frequencyMonths: 1.0,
              isPaused: false,
            ),
          ),
        ),
      );

      expect(find.text('Rent'), findsOneWidget);
      expect(find.textContaining('25,000'), findsOneWidget);
      expect(find.textContaining('Monthly'), findsOneWidget);
    });

    testWidgets('should show paused state with strikethrough', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecurringRuleCard(
              name: 'Paused SIP',
              kind: 'expense',
              amount: 500000,
              frequencyMonths: 1.0,
              isPaused: true,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Paused SIP'));
      expect(textWidget.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('should show play button for paused rules', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecurringRuleCard(
              name: 'Paused',
              kind: 'expense',
              amount: 100000,
              frequencyMonths: 1.0,
              isPaused: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('should show pause button for active rules', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecurringRuleCard(
              name: 'Active',
              kind: 'salary',
              amount: 15000000,
              frequencyMonths: 1.0,
              isPaused: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.pause), findsOneWidget);
    });

    testWidgets('should display quarterly frequency label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecurringRuleCard(
              name: 'Insurance',
              kind: 'insurancePremium',
              amount: 1000000,
              frequencyMonths: 3.0,
              isPaused: false,
            ),
          ),
        ),
      );

      expect(find.textContaining('Quarterly'), findsOneWidget);
    });
  });
}
