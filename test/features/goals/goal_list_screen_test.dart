import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vael/core/database/database.dart';
import 'package:vael/core/financial/milestone_engine.dart';
import 'package:vael/core/providers/session_providers.dart';
import 'package:vael/features/goals/providers/goal_providers.dart';
import 'package:vael/features/goals/screens/goal_list_screen.dart';
import 'package:vael/features/goals/widgets/sinking_fund_card.dart';
import 'package:vael/features/planning/providers/milestone_provider.dart';
import 'package:vael/features/planning/widgets/milestone_card.dart';
import 'package:vael/shared/theme/app_theme.dart';

const _familyId = 'fam_goals';

Goal _fakeGoal({
  required String id,
  required String name,
  required int targetAmount,
  int currentSavings = 0,
  String status = 'active',
  int priority = 1,
  String goalCategory = 'investmentGoal',
  String? sinkingFundSubType,
  DateTime? targetDate,
  DateTime? createdAt,
}) {
  return Goal(
    id: id,
    name: name,
    targetAmount: targetAmount,
    targetDate: targetDate ?? DateTime(2027, 6, 1),
    currentSavings: currentSavings,
    inflationRate: 0.06,
    priority: priority,
    status: status,
    linkedAccountId: null,
    familyId: _familyId,
    goalCategory: goalCategory,
    sinkingFundSubType: sinkingFundSubType,
    createdAt: createdAt ?? DateTime(2025),
  );
}

const _userId = 'user_goals';

class _TestSessionNotifier extends SessionUserIdNotifier {
  _TestSessionNotifier(this._initial);
  final String? _initial;

  @override
  String? build() => _initial;
}

Widget _buildApp({
  List<Goal> sinkingFunds = const [],
  List<Goal> investments = const [],
  List<Goal> purchases = const [],
  List<MilestoneDisplayItem> milestones = const [],
  String? userId = _userId,
}) {
  return ProviderScope(
    overrides: [
      sinkingFundGoalsProvider(
        _familyId,
      ).overrideWith((_) => Stream.value(sinkingFunds)),
      investmentGoalsProvider(
        _familyId,
      ).overrideWith((_) => Stream.value(investments)),
      purchaseGoalsProvider(
        _familyId,
      ).overrideWith((_) => Stream.value(purchases)),
      milestoneListProvider.overrideWith(
        (ref, params) => Stream.value(milestones),
      ),
      sessionUserIdProvider.overrideWith(() => _TestSessionNotifier(userId)),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      home: const GoalListScreen(familyId: _familyId),
    ),
  );
}

void main() {
  group('GoalListScreen', () {
    testWidgets(
      'renders 4 tabs: Sinking Funds, Investments, Purchases, Milestones',
      (tester) async {
        await tester.pumpWidget(_buildApp());
        await tester.pump();

        expect(find.byType(TabBar), findsOneWidget);
        expect(find.text('Sinking Funds'), findsOneWidget);
        expect(find.text('Investments'), findsOneWidget);
        expect(find.text('Purchases'), findsOneWidget);
        expect(find.text('Milestones'), findsOneWidget);
      },
    );

    testWidgets('Sinking Funds tab is selected by default (index 0)', (
      tester,
    ) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();

      // The first tab content (empty state for sinking funds) should be visible
      expect(find.text('No sinking funds yet'), findsOneWidget);
    });

    testWidgets('shows SinkingFundCard for sinking fund goals', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          sinkingFunds: [
            _fakeGoal(
              id: 'sf1',
              name: 'Tax Fund',
              targetAmount: 10000000,
              currentSavings: 3000000,
              goalCategory: 'sinkingFund',
              sinkingFundSubType: 'tax',
              createdAt: DateTime(2025, 1, 1),
              targetDate: DateTime(2026, 12, 31),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(SinkingFundCard), findsOneWidget);
      expect(find.text('Tax Fund'), findsOneWidget);
    });

    testWidgets('shows GoalCard for investment goals on Investments tab', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildApp(
          investments: [
            _fakeGoal(
              id: 'inv1',
              name: 'Retirement Corpus',
              targetAmount: 500000000,
              currentSavings: 100000000,
            ),
          ],
        ),
      );
      await tester.pump();

      // Tap Investments tab and wait for tab animation + stream resolution
      await tester.tap(find.text('Investments'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      expect(find.text('Retirement Corpus'), findsOneWidget);
    });

    testWidgets('shows empty state on Purchases tab when no goals', (
      tester,
    ) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();

      // Tap Purchases tab and wait for tab animation + stream resolution
      await tester.tap(find.text('Purchases'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      expect(find.text('No purchase goals yet'), findsOneWidget);
    });

    testWidgets('shows FAB for adding new goal', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('completed sinking funds show in collapsed section', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildApp(
          sinkingFunds: [
            _fakeGoal(
              id: 'sf1',
              name: 'Active Fund',
              targetAmount: 10000000,
              currentSavings: 3000000,
              goalCategory: 'sinkingFund',
              sinkingFundSubType: 'travel',
              createdAt: DateTime(2025, 1, 1),
              targetDate: DateTime(2026, 12, 31),
            ),
            _fakeGoal(
              id: 'sf2',
              name: 'Done Fund',
              targetAmount: 5000000,
              currentSavings: 5000000,
              status: 'completed',
              goalCategory: 'sinkingFund',
              sinkingFundSubType: 'gifts',
              createdAt: DateTime(2024, 1, 1),
              targetDate: DateTime(2025, 6, 1),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.text('Active Fund'), findsOneWidget);
      expect(find.text('Completed (1)'), findsOneWidget);
      // Completed fund should be hidden inside collapsed ExpansionTile
      expect(find.text('Done Fund'), findsNothing);
    });

    testWidgets('Milestones tab shows empty state when no milestones', (
      tester,
    ) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();

      await tester.tap(find.text('Milestones'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      expect(find.text('No milestones yet'), findsOneWidget);
    });

    testWidgets('Milestones tab shows MilestoneCard when milestones exist', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildApp(
          milestones: [
            MilestoneDisplayItem(
              age: 40,
              targetAmountPaise: 50000000,
              projectedAmountPaise: 45000000,
              status: MilestoneStatus.onTrack,
              isCustomTarget: false,
              isPast: false,
            ),
          ],
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Milestones'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      expect(find.byType(MilestoneCard), findsOneWidget);
    });
  });
}
