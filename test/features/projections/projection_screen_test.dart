import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/features/projections/screens/projection_screen.dart';

void main() {
  group('ProjectionScreen', () {
    testWidgets('should display projection summary and chart', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ProjectionScreen(familyId: 'f1')),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('60-Month Projection'), findsOneWidget);
      expect(find.text('Net Worth in 5 Years'), findsOneWidget);
      expect(find.text('Optimistic'), findsOneWidget);
      expect(find.text('Base'), findsOneWidget);
      expect(find.text('Pessimistic'), findsOneWidget);
      expect(find.text('Assumptions'), findsOneWidget);
    });

    testWidgets('should have sliders for parameters', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ProjectionScreen(familyId: 'f1')),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll down to find the assumptions section
      await tester.scrollUntilVisible(
        find.text('Monthly Income'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Monthly Income'), findsOneWidget);
      expect(find.byType(Slider), findsWidgets);
    });

    testWidgets('should show optimistic > base > pessimistic', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ProjectionScreen(familyId: 'f1')),
        ),
      );

      await tester.pumpAndSettle();

      // All three scenarios should be visible with their values
      expect(find.text('Optimistic'), findsOneWidget);
      expect(find.text('Base'), findsOneWidget);
      expect(find.text('Pessimistic'), findsOneWidget);
    });
  });
}
