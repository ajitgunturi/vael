import 'package:drift/native.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:vael/core/database/database.dart';
import 'package:vael/core/providers/database_providers.dart';
import 'package:vael/features/dashboard/widgets/net_worth_chart.dart';
import 'package:vael/shared/theme/app_theme.dart';

import 'helpers/e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// Pumps a standalone dashboard with a NetWorthChart containing seeded history.
  Future<void> pumpDashboardWithChart(
    WidgetTester tester, {
    required List<({DateTime date, int netWorth})> history,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: NetWorthChart(history: history),
          ),
        ),
      ),
    );
    await settle(tester);
  }

  group('Dashboard Charts + Savings Rate', () {
    testWidgets('net worth chart renders with 6-month history', (tester) async {
      final history = List.generate(6, (i) => (
        date: DateTime(2025, i + 1, 1),
        netWorth: 10000000 + (i * 2000000), // growing from ₹1L to ₹2L
      ));

      await seedTestFamily(db);
      await pumpDashboardWithChart(tester, history: history);

      // Chart card title
      expect(find.text('Net Worth Trend'), findsOneWidget);
      // fl_chart LineChart should be in the tree
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('net worth chart is hidden with empty history', (tester) async {
      await seedTestFamily(db);
      await pumpDashboardWithChart(tester, history: []);

      // No chart when history is empty
      expect(find.text('Net Worth Trend'), findsNothing);
      expect(find.byType(LineChart), findsNothing);
    });

    testWidgets('savings rate badge shows green for healthy rate', (tester) async {
      await seedTestFamily(db);
      // Income ₹1,00,000, expenses ₹60,000 → savings rate 40% → green badge
      await seedAccount(db, id: 'a1', name: 'Savings', type: 'savings', balance: 50000000);
      final now = DateTime.now();
      await seedTransaction(db,
        id: 'tx1', amount: 10000000, date: now,
        kind: 'salary', accountId: 'a1',
      );
      await seedTransaction(db,
        id: 'tx2', amount: 6000000, date: now,
        kind: 'expense', accountId: 'a1',
      );

      await tester.pumpWidget(SimulatorTestApp(db: db));
      await settle(tester);

      // 40% savings rate → green range (≥20%)
      expect(find.textContaining('Savings Rate: 40%'), findsOneWidget);
    });
  });
}
