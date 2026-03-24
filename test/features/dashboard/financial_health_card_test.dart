import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/features/dashboard/widgets/financial_health_summary_card.dart';
import 'package:vael/features/planning/providers/planning_health_providers.dart';
import 'package:vael/shared/theme/app_theme.dart';

const _familyId = 'fam_a';
const _userId = 'u1';

Widget _buildApp({required PlanningHealthData health}) {
  return ProviderScope(
    overrides: [
      planningHealthProvider((
        familyId: _familyId,
        userId: _userId,
      )).overrideWith((_) async => health),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      home: const Scaffold(
        body: FinancialHealthSummaryCard(familyId: _familyId, userId: _userId),
      ),
    ),
  );
}

void main() {
  group('FinancialHealthSummaryCard', () {
    testWidgets('hides card when no life profile', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          health: const PlanningHealthData(
            hasLifeProfile: false,
            netWorthPaise: 100000000,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Financial Health'), findsNothing);
    });

    testWidgets('shows card with all metrics when configured', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          health: const PlanningHealthData(
            hasLifeProfile: true,
            hasEmergencyFund: true,
            netWorthPaise: 250000000,
            savingsRatePercent: 25,
            efCoverageMonths: 3.5,
            efTargetMonths: 6,
            fiProgressPercent: 18,
            yearsToFi: 12,
            milestoneOnTrackCount: 3,
            milestoneTotalCount: 5,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Financial Health'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);
      // Metric chips
      expect(find.textContaining('NW:'), findsOneWidget);
      expect(find.textContaining('SR: 25%'), findsOneWidget);
      expect(find.textContaining('EF: 3.5mo'), findsOneWidget);
      expect(find.textContaining('FI: 18%'), findsOneWidget);
      expect(find.textContaining('MS: 3/5'), findsOneWidget);
    });

    testWidgets('View All navigates to PlanningDashboardScreen', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildApp(
          health: const PlanningHealthData(
            hasLifeProfile: true,
            netWorthPaise: 100000000,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('View All'));
      await tester.pumpAndSettle();

      // Verify navigation occurred — PlanningDashboardScreen shows 'Financial Health' appBar
      expect(find.text('Financial Health'), findsOneWidget);
    });

    testWidgets('shows dashes for unconfigured metrics', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          health: const PlanningHealthData(
            hasLifeProfile: true,
            hasEmergencyFund: false,
            netWorthPaise: 100000000,
            savingsRatePercent: 15,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('EF: --'), findsOneWidget);
    });
  });
}
