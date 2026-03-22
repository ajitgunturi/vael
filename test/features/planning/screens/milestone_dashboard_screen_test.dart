import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vael/core/financial/milestone_engine.dart';
import 'package:vael/features/planning/providers/milestone_provider.dart';
import 'package:vael/features/planning/screens/milestone_dashboard_screen.dart';
import 'package:vael/features/planning/widgets/milestone_card.dart';
import 'package:vael/features/planning/widgets/milestone_edit_sheet.dart';
import 'package:vael/shared/theme/app_theme.dart';
import 'package:vael/shared/widgets/empty_state.dart';

const _familyId = 'fam_ms_screen';
const _userId = 'user_ms_screen';

/// Sample milestone items for testing.
List<MilestoneDisplayItem> _sampleItems({int currentAge = 25}) => [
  MilestoneDisplayItem(
    age: 30,
    targetAmountPaise: 100000000,
    projectedAmountPaise: 95000000,
    status: MilestoneStatus.onTrack,
    isCustomTarget: false,
    isPast: currentAge >= 30,
  ),
  MilestoneDisplayItem(
    age: 40,
    targetAmountPaise: 500000000,
    projectedAmountPaise: 550000000,
    status: MilestoneStatus.ahead,
    isCustomTarget: false,
    isPast: currentAge >= 40,
  ),
  MilestoneDisplayItem(
    age: 50,
    targetAmountPaise: 1500000000,
    projectedAmountPaise: 1200000000,
    status: MilestoneStatus.behind,
    isCustomTarget: true,
    isPast: currentAge >= 50,
  ),
  MilestoneDisplayItem(
    age: 60,
    targetAmountPaise: 3000000000,
    projectedAmountPaise: 3100000000,
    status: MilestoneStatus.ahead,
    isCustomTarget: false,
    isPast: currentAge >= 60,
  ),
  MilestoneDisplayItem(
    age: 70,
    targetAmountPaise: 5000000000,
    projectedAmountPaise: 4000000000,
    status: MilestoneStatus.behind,
    isCustomTarget: false,
    isPast: currentAge >= 70,
  ),
];

/// Items with some past milestones (current age = 45).
List<MilestoneDisplayItem> _itemsWithPast() => [
  MilestoneDisplayItem(
    age: 30,
    targetAmountPaise: 100000000,
    projectedAmountPaise: 120000000,
    status: MilestoneStatus.reached,
    isCustomTarget: false,
    isPast: true,
  ),
  MilestoneDisplayItem(
    age: 40,
    targetAmountPaise: 500000000,
    projectedAmountPaise: 400000000,
    status: MilestoneStatus.missed,
    isCustomTarget: false,
    isPast: true,
  ),
  MilestoneDisplayItem(
    age: 50,
    targetAmountPaise: 1500000000,
    projectedAmountPaise: 1400000000,
    status: MilestoneStatus.onTrack,
    isCustomTarget: false,
    isPast: false,
  ),
  MilestoneDisplayItem(
    age: 60,
    targetAmountPaise: 3000000000,
    projectedAmountPaise: 3200000000,
    status: MilestoneStatus.ahead,
    isCustomTarget: false,
    isPast: false,
  ),
  MilestoneDisplayItem(
    age: 70,
    targetAmountPaise: 5000000000,
    projectedAmountPaise: 4500000000,
    status: MilestoneStatus.behind,
    isCustomTarget: false,
    isPast: false,
  ),
];

void main() {
  Widget buildApp({List<MilestoneDisplayItem>? items}) {
    return ProviderScope(
      overrides: [
        milestoneListProvider.overrideWith(
          (ref, params) => items != null
              ? Stream.value(items)
              : Stream.value(<MilestoneDisplayItem>[]),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const MilestoneDashboardScreen(
          familyId: _familyId,
          userId: _userId,
        ),
      ),
    );
  }

  group('MilestoneDashboardScreen', () {
    testWidgets('renders 5 milestone cards with age badges', (tester) async {
      await tester.pumpWidget(buildApp(items: _sampleItems()));
      await tester.pump();

      expect(find.byType(MilestoneCard), findsNWidgets(5));
      expect(find.text('30'), findsOneWidget);
      expect(find.text('40'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);
      expect(find.text('60'), findsOneWidget);
      expect(find.text('70'), findsOneWidget);
    });

    testWidgets('shows EmptyState when no life profile (empty items)', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No life profile yet'), findsOneWidget);
      expect(find.text('Set Up Profile'), findsOneWidget);
    });

    testWidgets('status chip shows correct text for each status', (
      tester,
    ) async {
      final items = _itemsWithPast();
      await tester.pumpWidget(buildApp(items: items));
      await tester.pump();

      expect(find.text('Reached'), findsOneWidget);
      expect(find.text('Missed'), findsOneWidget);
      expect(find.text('On Track'), findsOneWidget);
      expect(find.text('Ahead'), findsOneWidget);
      expect(find.text('Behind'), findsOneWidget);
    });

    testWidgets('past milestone card has no edit icon', (tester) async {
      final items = _itemsWithPast();
      await tester.pumpWidget(buildApp(items: items));
      await tester.pump();

      // There are 5 cards total; 2 past, 3 future.
      // Only future milestones should have edit icons.
      // edit_outlined icons should appear exactly 3 times (ages 50, 60, 70).
      final editIcons = find.byIcon(Icons.edit_outlined);
      expect(editIcons, findsNWidgets(3));
    });

    testWidgets('summary header text is displayed', (tester) async {
      await tester.pumpWidget(buildApp(items: _sampleItems()));
      await tester.pump();

      expect(find.text('Track your wealth at every decade'), findsOneWidget);
    });
  });
}
