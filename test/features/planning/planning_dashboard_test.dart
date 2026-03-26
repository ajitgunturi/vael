import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/financial/insights_engine.dart';
import 'package:vael/features/planning/providers/insights_provider.dart';
import 'package:vael/features/planning/providers/planning_health_providers.dart';
import 'package:vael/features/planning/screens/planning_dashboard_screen.dart';
import 'package:vael/features/planning/widgets/insight_alert_card.dart';
import 'package:vael/shared/theme/app_theme.dart';

PlanningHealthData _fullyConfigured() => const PlanningHealthData(
  netWorthPaise: 2500000000,
  savingsRatePercent: 25,
  efCoverageMonths: 4.5,
  efTargetMonths: 6,
  fiProgressPercent: 12,
  yearsToFi: 18,
  milestoneOnTrackCount: 3,
  milestoneTotalCount: 5,
  hasLifeProfile: true,
  hasEmergencyFund: true,
);

PlanningHealthData _unconfigured() => const PlanningHealthData(
  netWorthPaise: 500000000,
  savingsRatePercent: 15,
  hasLifeProfile: false,
  hasEmergencyFund: false,
);

Widget _buildApp(
  PlanningHealthData data, {
  List<PlanningInsight> insights = const [],
}) {
  return ProviderScope(
    overrides: [
      planningHealthProvider((
        familyId: 'fam_a',
        userId: 'user_a',
      )).overrideWith((_) async => data),
      insightsProvider((
        familyId: 'fam_a',
        userId: 'user_a',
      )).overrideWith((_) async => insights),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      home: const PlanningDashboardScreen(familyId: 'fam_a', userId: 'user_a'),
    ),
  );
}

void main() {
  group('PlanningDashboardScreen', () {
    testWidgets('shows all 5 metric cards when fully configured', (
      tester,
    ) async {
      await tester.pumpWidget(_buildApp(_fullyConfigured()));
      await tester.pumpAndSettle();

      expect(find.text('Net Worth'), findsOneWidget);
      expect(find.text('Savings Rate'), findsOneWidget);
      expect(find.text('Emergency Fund'), findsOneWidget);
      expect(find.text('FI Progress'), findsOneWidget);
      expect(find.text('Milestones'), findsOneWidget);

      // Verify metric values
      expect(find.text('25%'), findsOneWidget); // savings rate
      expect(find.text('4.5 mo'), findsOneWidget); // EF coverage
      expect(find.text('12%'), findsOneWidget); // FI progress
      expect(find.text('3/5'), findsOneWidget); // milestones
    });

    testWidgets('shows Set up CTAs for unconfigured features', (tester) async {
      await tester.pumpWidget(_buildApp(_unconfigured()));
      await tester.pumpAndSettle();

      // EF and FI/Milestones should show setup CTAs
      expect(find.text('Set up EF'), findsOneWidget);
      // FI Progress and Milestones both show "Set up Profile"
      expect(find.text('Set up Profile'), findsNWidgets(2));

      // Net Worth and Savings Rate should still show values
      expect(find.text('Net Worth'), findsOneWidget);
      expect(find.text('Savings Rate'), findsOneWidget);
      expect(find.text('15%'), findsOneWidget);
    });

    testWidgets('savings rate color uses green for rate >= 20', (tester) async {
      await tester.pumpWidget(_buildApp(_fullyConfigured()));
      await tester.pumpAndSettle();

      // Find the savings rate value Text widget and verify its style
      final valueFinder = find.text('25%');
      expect(valueFinder, findsOneWidget);

      final text = tester.widget<Text>(valueFinder);
      // Green income color from light theme: 0xFF2D7A2D
      expect(text.style?.color, const Color(0xFF2D7A2D));
    });

    testWidgets('shows alert cards when insights provider returns alerts', (
      tester,
    ) async {
      final alerts = [
        const PlanningInsight(
          type: InsightType.efBelowTarget,
          severity: InsightSeverity.critical,
          title: 'Emergency fund below target',
          description: '3.0 months short of 6-month target',
        ),
      ];

      await tester.pumpWidget(_buildApp(_fullyConfigured(), insights: alerts));
      await tester.pumpAndSettle();

      // Alert section header
      expect(find.text('Alerts'), findsOneWidget);
      // Alert card content
      expect(find.byType(InsightAlertCard), findsOneWidget);
      expect(find.text('Emergency fund below target'), findsOneWidget);
      expect(find.text('3.0 months short of 6-month target'), findsOneWidget);
    });

    testWidgets('shows loading indicator while data loads', (tester) async {
      final completer = Completer<PlanningHealthData>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            planningHealthProvider((
              familyId: 'fam_a',
              userId: 'user_a',
            )).overrideWith((_) => completer.future),
            insightsProvider((
              familyId: 'fam_a',
              userId: 'user_a',
            )).overrideWith((_) async => <PlanningInsight>[]),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const PlanningDashboardScreen(
              familyId: 'fam_a',
              userId: 'user_a',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete to avoid pending future warnings
      completer.complete(_fullyConfigured());
      await tester.pumpAndSettle();
    });
  });
}
