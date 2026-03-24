import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/financial/cash_flow_engine.dart';
import 'package:vael/core/providers/session_providers.dart';
import 'package:vael/features/cashflow/providers/cash_flow_providers.dart';
import 'package:vael/features/cashflow/screens/cash_flow_screen.dart';
import 'package:vael/features/cashflow/widgets/cash_flow_alert_row.dart';
import 'package:vael/features/cashflow/widgets/cash_flow_day_row.dart';
import 'package:vael/shared/theme/app_theme.dart';

/// Mock DayProjection data with 3 days, 5 items, and 1 alert.
List<DayProjection> _mockProjections() {
  return [
    DayProjection(
      date: DateTime(2026, 3, 1),
      items: [
        CashFlowItem(
          date: DateTime(2026, 3, 1),
          ruleId: 'r1',
          ruleName: 'Salary',
          accountId: 'acc1',
          kind: 'income',
          amountPaise: 10000000,
        ),
        CashFlowItem(
          date: DateTime(2026, 3, 1),
          ruleId: 'r2',
          ruleName: 'Rent',
          accountId: 'acc1',
          kind: 'expense',
          amountPaise: 2500000,
        ),
      ],
      runningBalancesByAccount: {'acc1': 7500000},
      alerts: [],
    ),
    DayProjection(
      date: DateTime(2026, 3, 5),
      items: [
        CashFlowItem(
          date: DateTime(2026, 3, 5),
          ruleId: 'r3',
          ruleName: 'Groceries',
          accountId: 'acc1',
          kind: 'expense',
          amountPaise: 500000,
        ),
      ],
      runningBalancesByAccount: {'acc1': 7000000},
      alerts: [],
    ),
    DayProjection(
      date: DateTime(2026, 3, 15),
      items: [
        CashFlowItem(
          date: DateTime(2026, 3, 15),
          ruleId: 'r4',
          ruleName: 'Insurance',
          accountId: 'acc1',
          kind: 'expense',
          amountPaise: 5000000,
        ),
        CashFlowItem(
          date: DateTime(2026, 3, 15),
          ruleId: 'r5',
          ruleName: 'SIP Transfer',
          accountId: 'acc1',
          toAccountId: 'acc2',
          kind: 'transfer',
          amountPaise: 1000000,
        ),
      ],
      runningBalancesByAccount: {'acc1': 1000000, 'acc2': 1000000},
      alerts: [
        ThresholdAlert(
          accountId: 'acc1',
          date: DateTime(2026, 3, 15),
          balancePaise: 1000000,
          thresholdPaise: 2000000,
        ),
      ],
    ),
  ];
}

/// Test session notifier for overriding in tests.
class _TestSessionFamilyIdNotifier extends SessionFamilyIdNotifier {
  @override
  String? build() => 'fam_test';
}

class _TestSelectedMonthNotifier extends SelectedCashFlowMonthNotifier {
  @override
  DateTime build() => DateTime(2026, 3);
}

Widget _buildApp({
  required List<DayProjection> projections,
  Map<String, String> accountNames = const {'acc1': 'Savings', 'acc2': 'MF'},
}) {
  return ProviderScope(
    overrides: [
      sessionFamilyIdProvider.overrideWith(_TestSessionFamilyIdNotifier.new),
      selectedCashFlowMonthProvider.overrideWith(
        _TestSelectedMonthNotifier.new,
      ),
      cashFlowProjectionProvider((
        familyId: 'fam_test',
        month: DateTime(2026, 3),
      )).overrideWith((_) async => projections),
      accountNamesProvider('fam_test').overrideWith((_) async => accountNames),
    ],
    child: MaterialApp(theme: AppTheme.light(), home: const CashFlowScreen()),
  );
}

void main() {
  group('CashFlowScreen', () {
    testWidgets('renders day headers for each DayProjection', (tester) async {
      await tester.pumpWidget(_buildApp(projections: _mockProjections()));
      await tester.pumpAndSettle();

      // 3 day headers
      expect(find.byType(CashFlowDayRow), findsNWidgets(3));
      expect(find.text('Sun, 1 Mar'), findsOneWidget);
      expect(find.text('Thu, 5 Mar'), findsOneWidget);
      expect(find.text('Sun, 15 Mar'), findsOneWidget);
    });

    testWidgets('renders income items with green up arrow', (tester) async {
      await tester.pumpWidget(_buildApp(projections: _mockProjections()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
      expect(find.text('Salary'), findsOneWidget);
    });

    testWidgets('renders expense items with red down arrow', (tester) async {
      await tester.pumpWidget(_buildApp(projections: _mockProjections()));
      await tester.pumpAndSettle();

      // 3 expense items: Rent, Groceries, Insurance
      expect(find.byIcon(Icons.arrow_downward), findsNWidgets(3));
      expect(find.text('Rent'), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Insurance'), findsOneWidget);
    });

    testWidgets('renders threshold alert row with locked format text', (
      tester,
    ) async {
      await tester.pumpWidget(_buildApp(projections: _mockProjections()));
      await tester.pumpAndSettle();

      expect(find.byType(CashFlowAlertRow), findsOneWidget);
      // Locked format: "Balance drops to Rs X on [date] -- below Rs Y minimum"
      expect(
        find.textContaining('Balance drops to Rs 10000 on 15 Mar'),
        findsOneWidget,
      );
      expect(find.textContaining('below Rs 20000 minimum'), findsOneWidget);
    });

    testWidgets('renders transfer items with swap icon', (tester) async {
      await tester.pumpWidget(_buildApp(projections: _mockProjections()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
      expect(find.text('SIP Transfer'), findsOneWidget);
    });

    testWidgets('renders empty state when no projections', (tester) async {
      await tester.pumpWidget(_buildApp(projections: []));
      await tester.pumpAndSettle();

      expect(find.text('No recurring rules configured'), findsOneWidget);
    });

    testWidgets('tune icon is present in app bar', (tester) async {
      await tester.pumpWidget(_buildApp(projections: _mockProjections()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.tune), findsOneWidget);
    });

    testWidgets('month navigation arrows present', (tester) async {
      await tester.pumpWidget(_buildApp(projections: _mockProjections()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('shows month/year in app bar', (tester) async {
      await tester.pumpWidget(_buildApp(projections: _mockProjections()));
      await tester.pumpAndSettle();

      expect(find.text('Cash Flow'), findsOneWidget);
      expect(find.text('March 2026'), findsOneWidget);
    });
  });
}
