import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vael/features/planning/providers/fi_calculator_provider.dart';
import 'package:vael/features/planning/screens/fi_calculator_screen.dart';
import 'package:vael/features/planning/widgets/fi_hero_card.dart';
import 'package:vael/features/planning/widgets/fi_secondary_card.dart';
import 'package:vael/features/planning/widgets/rate_slider.dart';
import 'package:vael/shared/theme/app_theme.dart';

const _familyId = 'fam_fi_screen';
const _userId = 'user_fi_screen';

/// Standalone defaults (no life profile).
const _standaloneInputs = FiInputs();

/// Simulated profile-backed defaults.
const _profileInputs = FiInputs(
  swrBp: 300,
  returnsBp: 1000,
  inflationBp: 600,
  monthlyExpensesPaise: 5000000,
  currentAge: 35,
  retirementAge: 60,
  currentPortfolioPaise: 0,
  monthlySavingsPaise: 0,
  hasLifeProfile: true,
);

void main() {
  /// Builds the app with [fiDefaultInputsProvider] overridden to avoid drift
  /// stream timers in widget tests. All screen-level tests use this approach;
  /// the actual stream wiring is verified in the provider unit tests.
  Widget buildApp({FiInputs inputs = _standaloneInputs}) {
    return ProviderScope(
      overrides: [
        fiDefaultInputsProvider.overrideWith((ref, params) => inputs),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: FiCalculatorScreen(familyId: _familyId, userId: _userId),
      ),
    );
  }

  group('FiCalculatorScreen', () {
    testWidgets('renders FI number hero card with displayLarge text', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      expect(find.byType(FiHeroCard), findsOneWidget);
      expect(find.text('Financial Independence Number'), findsOneWidget);
    });

    testWidgets('renders years-to-FI and Coast FI secondary cards', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      expect(find.byType(FiSecondaryCard), findsNWidgets(2));
      expect(find.text('Years to FI'), findsOneWidget);
      expect(find.text('Coast FI'), findsOneWidget);
    });

    testWidgets('renders 3 RateSlider widgets', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      expect(find.byType(RateSlider), findsNWidgets(3));
      expect(find.text('Safe Withdrawal Rate'), findsOneWidget);
      expect(find.text('Expected Returns'), findsOneWidget);
      expect(find.text('Inflation'), findsOneWidget);
    });

    testWidgets('standalone mode: shows profile banner when no life profile', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      expect(
        find.text('Set up your life profile for personalized results'),
        findsOneWidget,
      );
      expect(find.text('Set Up'), findsOneWidget);
    });

    testWidgets('with life profile: no profile banner shown', (tester) async {
      await tester.pumpWidget(buildApp(inputs: _profileInputs));
      await tester.pump();

      expect(
        find.text('Set up your life profile for personalized results'),
        findsNothing,
      );
    });

    testWidgets('slider interaction: changing SWR slider updates FI number', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      final heroFinder = find.byType(FiHeroCard);
      expect(heroFinder, findsOneWidget);

      final initialFi = tester.widget<FiHeroCard>(heroFinder).fiNumberPaise;

      // Scroll down to reveal the SWR slider (may be off-screen on 600px viewport)
      await tester.scrollUntilVisible(
        find.text('Safe Withdrawal Rate'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      // Drag the SWR slider to the right (higher SWR = lower FI number)
      final sliders = find.byType(Slider);
      expect(sliders, findsNWidgets(3));
      await tester.drag(sliders.first, const Offset(100, 0));
      await tester.pump();

      final updatedFi = tester
          .widget<FiHeroCard>(find.byType(FiHeroCard))
          .fiNumberPaise;
      expect(updatedFi, isNot(equals(initialFi)));
    });

    testWidgets('renders monthly expenses text field', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      expect(find.text('Monthly Expenses'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders Semantics wrapper for FI number', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      final semanticsFinder = find.bySemanticsLabel(
        RegExp('Financial Independence number:'),
      );
      expect(semanticsFinder, findsAtLeastNWidgets(1));
    });
  });
}
