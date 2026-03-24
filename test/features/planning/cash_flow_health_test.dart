import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/financial/cash_flow_engine.dart';
import 'package:vael/core/financial/dashboard_aggregation.dart';
import 'package:vael/core/financial/savings_allocation_engine.dart';
import 'package:vael/features/cashflow/providers/cash_flow_providers.dart';
import 'package:vael/features/dashboard/providers/dashboard_providers.dart';
import 'package:vael/features/planning/providers/savings_allocation_providers.dart';
import 'package:vael/features/planning/screens/cash_flow_health_screen.dart';
import 'package:vael/shared/theme/app_theme.dart';

const _familyId = 'fam_a';
const _userId = 'u1';

Widget _buildApp({
  int incomePaise = 15000000,
  int expensesPaise = 8000000,
  List<AllocationAdvice> allocations = const [],
  List<DayProjection> projections = const [],
}) {
  final summary = MonthlySummary(
    totalIncome: incomePaise,
    totalExpenses: expensesPaise,
  );
  final dashData = DashboardData(
    grouped: const AccountGroups(
      banking: [],
      investments: [],
      loans: [],
      creditCards: [],
    ),
    netWorth: 0,
    monthlySummary: summary,
  );

  final now = DateTime.now();
  final month = DateTime(now.year, now.month);

  return ProviderScope(
    overrides: [
      dashboardDataProvider(
        _familyId,
      ).overrideWith((ref) => Stream.value(dashData)),
      allocationAdvisoryProvider(
        _familyId,
      ).overrideWith((_) async => allocations),
      cashFlowProjectionProvider((
        familyId: _familyId,
        month: month,
      )).overrideWith((_) async => projections),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      home: const CashFlowHealthScreen(familyId: _familyId, userId: _userId),
    ),
  );
}

void main() {
  group('CashFlowHealthScreen', () {
    testWidgets('shows Cash Flow Health title', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Cash Flow Health'), findsOneWidget);
    });

    testWidgets('shows income and expenses bars', (tester) async {
      await tester.pumpWidget(
        _buildApp(incomePaise: 15000000, expensesPaise: 8000000),
      );
      await tester.pumpAndSettle();

      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
    });

    testWidgets('shows savings waterfall when allocation rules exist', (
      tester,
    ) async {
      final allocations = [
        const AllocationAdvice(
          targetType: 'emergencyFund',
          targetName: 'Emergency Fund',
          allocatedPaise: 2000000,
          remainingToTarget: 500000,
        ),
        const AllocationAdvice(
          targetType: 'sinkingFund',
          targetId: 'g1',
          targetName: 'Vacation',
          allocatedPaise: 1000000,
          remainingToTarget: 0,
        ),
      ];

      await tester.pumpWidget(
        _buildApp(
          incomePaise: 15000000,
          expensesPaise: 8000000,
          allocations: allocations,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Savings Waterfall'), findsOneWidget);
    });

    testWidgets('shows 7-day mini-view', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Next 7 Days'), findsOneWidget);
    });
  });
}
