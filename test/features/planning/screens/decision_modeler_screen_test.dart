import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vael/core/database/daos/decision_dao.dart';
import 'package:vael/core/models/enums.dart';
import 'package:vael/features/planning/providers/decision_provider.dart';
import 'package:vael/features/planning/screens/decision_modeler_screen.dart';
import 'package:vael/features/planning/widgets/decision_impact_card.dart';
import 'package:vael/features/planning/widgets/decision_type_card.dart';
import 'package:vael/shared/theme/app_theme.dart';

const _familyId = 'fam_decision_test';
const _userId = 'user_decision_test';

/// Fake DecisionDao that records calls without touching a real database.
class FakeDecisionDao extends Fake implements DecisionDao {
  final insertedDecisions = <dynamic>[];

  @override
  Future<void> insertDecision(dynamic decision) async {
    insertedDecisions.add(decision);
  }

  @override
  Future<void> markImplemented(String id) async {}
}

/// Helper: tap a button even if off-screen by using ensureVisible first.
Future<void> tapButton(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  late FakeDecisionDao fakeDao;

  setUp(() {
    fakeDao = FakeDecisionDao();
  });

  Widget buildApp({DecisionType? prefilledType, Size? size}) {
    // Use large surface to avoid scrolling issues in tests
    return ProviderScope(
      overrides: [decisionDaoProvider.overrideWithValue(fakeDao)],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: DecisionModelerScreen(
          familyId: _familyId,
          userId: _userId,
          prefilledType: prefilledType,
        ),
      ),
    );
  }

  group('DecisionModelerScreen', () {
    testWidgets('step 1 renders 6 decision type cards', (tester) async {
      // Use a tall surface to fit all 6 cards
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildApp());
      await tester.pump();

      expect(find.byType(DecisionTypeCard), findsNWidgets(6));
      expect(find.text('Job Change'), findsOneWidget);
      expect(find.text('Salary Negotiation'), findsOneWidget);
      expect(find.text('Major Purchase'), findsOneWidget);
      expect(find.text('Withdrawal'), findsOneWidget);
      expect(find.text('Rental Change'), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);
    });

    testWidgets('selecting a type enables Next button', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildApp());
      await tester.pump();

      // Next button should be disabled initially
      final nextFinder = find.widgetWithText(FilledButton, 'Next');
      final nextButton = tester.widget<FilledButton>(nextFinder);
      expect(nextButton.onPressed, isNull);

      // Tap "Job Change"
      await tester.tap(find.text('Job Change'));
      await tester.pump();

      // Now enabled
      final enabledButton = tester.widget<FilledButton>(nextFinder);
      expect(enabledButton.onPressed, isNotNull);
    });

    testWidgets('step 2 renders fields for Major Purchase', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildApp(prefilledType: DecisionType.majorPurchase),
      );
      await tester.pump();

      // Tap Next to go to step 2
      await tapButton(tester, find.widgetWithText(FilledButton, 'Next'));

      // Should see purchase-type dropdown and form fields
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(find.byType(TextFormField), findsAtLeastNWidgets(1));
    });

    testWidgets('impact card renders for Custom decision', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildApp(prefilledType: DecisionType.custom));
      await tester.pump();

      // Step 1 -> Step 2
      await tapButton(tester, find.widgetWithText(FilledButton, 'Next'));
      // Step 2 -> Step 3
      await tapButton(tester, find.widgetWithText(FilledButton, 'Next'));

      expect(find.byType(DecisionImpactCard), findsOneWidget);
      expect(find.text('No impact on FI date'), findsOneWidget);
    });

    testWidgets('implement button creates decision record', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildApp(prefilledType: DecisionType.custom));
      await tester.pump();

      // Navigate through all 4 steps
      await tapButton(tester, find.widgetWithText(FilledButton, 'Next'));
      await tapButton(tester, find.widgetWithText(FilledButton, 'Next'));
      await tapButton(tester, find.widgetWithText(FilledButton, 'Next'));

      // Tap Implement Decision
      await tapButton(
        tester,
        find.widgetWithText(FilledButton, 'Implement Decision'),
      );

      expect(fakeDao.insertedDecisions, hasLength(1));
    });

    testWidgets('preview button creates decision with status preview', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildApp(prefilledType: DecisionType.custom));
      await tester.pump();

      // Navigate through all 4 steps
      await tapButton(tester, find.widgetWithText(FilledButton, 'Next'));
      await tapButton(tester, find.widgetWithText(FilledButton, 'Next'));
      await tapButton(tester, find.widgetWithText(FilledButton, 'Next'));

      // Tap Save as Preview
      await tapButton(
        tester,
        find.widgetWithText(OutlinedButton, 'Save as Preview'),
      );

      expect(fakeDao.insertedDecisions, hasLength(1));
    });

    testWidgets('step indicator shows Choose Type initially', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      expect(find.text('Choose Type'), findsOneWidget);
      expect(find.text('Model a Decision'), findsOneWidget);
    });
  });
}
