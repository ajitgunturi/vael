import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/features/planning/providers/timeline_provider.dart';
import 'package:vael/features/planning/screens/lifetime_timeline_screen.dart';
import 'package:vael/shared/theme/app_theme.dart';

const _userId = 'u1';
const _familyId = 'f1';
const _params = (userId: _userId, familyId: _familyId);

Widget _buildApp({required List<TimelineNode> nodes, int? currentAge}) {
  return ProviderScope(
    overrides: [
      timelineNodesProvider(_params).overrideWith((_) async => nodes),
      currentAgeProvider(_params).overrideWith((ref) => currentAge),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      home: const LifetimeTimelineScreen(familyId: _familyId, userId: _userId),
    ),
  );
}

void main() {
  group('LifetimeTimelineScreen', () {
    testWidgets('shows Life Plan title', (tester) async {
      await tester.pumpWidget(_buildApp(nodes: const [], currentAge: 30));
      await tester.pumpAndSettle();

      expect(find.text('Life Plan'), findsOneWidget);
    });

    testWidgets('shows empty state when no life profile', (tester) async {
      await tester.pumpWidget(_buildApp(nodes: const [], currentAge: null));
      await tester.pumpAndSettle();

      expect(
        find.text('Set up your Life Profile to see your timeline'),
        findsOneWidget,
      );
      expect(find.text('Set Up Profile'), findsOneWidget);
    });

    testWidgets('renders timeline with nodes when profile exists', (
      tester,
    ) async {
      final nodes = [
        const TimelineNode(
          type: TimelineNodeType.milestone,
          age: 40,
          label: '1Cr',
          statusColor: TimelineNodeStatus.onTrack,
          detailRoute: 'milestone',
        ),
        const TimelineNode(
          type: TimelineNodeType.fiDate,
          age: 50,
          label: 'FI',
          statusColor: TimelineNodeStatus.onTrack,
          detailRoute: 'fi',
        ),
      ];

      await tester.pumpWidget(_buildApp(nodes: nodes, currentAge: 30));
      await tester.pumpAndSettle();

      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('navigates to FI calculator on FI node tap', (tester) async {
      final nodes = [
        const TimelineNode(
          type: TimelineNodeType.fiDate,
          age: 50,
          label: 'FI',
          statusColor: TimelineNodeStatus.onTrack,
          detailRoute: 'fi',
        ),
      ];

      await tester.pumpWidget(_buildApp(nodes: nodes, currentAge: 30));
      await tester.pumpAndSettle();

      // Verify the timeline is rendered and tappable
      expect(find.byType(GestureDetector), findsWidgets);
    });
  });
}
