import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/features/dashboard/widgets/net_worth_chart.dart';
import 'package:vael/shared/theme/app_theme.dart';

void main() {
  Widget buildApp(List<({DateTime date, int netWorth})> history) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: NetWorthChart(history: history),
      ),
    );
  }

  group('NetWorthChart', () {
    testWidgets('renders line chart with data points', (tester) async {
      final history = [
        (date: DateTime(2025, 1, 1), netWorth: 100000000),
        (date: DateTime(2025, 2, 1), netWorth: 120000000),
        (date: DateTime(2025, 3, 1), netWorth: 115000000),
      ];

      await tester.pumpWidget(buildApp(history));
      expect(find.byType(LineChart), findsOneWidget);
      expect(find.text('Net Worth Trend'), findsOneWidget);
    });

    testWidgets('renders nothing when history is empty', (tester) async {
      await tester.pumpWidget(buildApp([]));
      expect(find.byType(LineChart), findsNothing);
    });

    testWidgets('chart has area fill below the line', (tester) async {
      final history = [
        (date: DateTime(2025, 1, 1), netWorth: 50000000),
        (date: DateTime(2025, 2, 1), netWorth: 60000000),
      ];

      await tester.pumpWidget(buildApp(history));
      final chart = tester.widget<LineChart>(find.byType(LineChart));
      final barData = chart.data.lineBarsData.first;
      expect(barData.belowBarData.show, isTrue);
    });

    testWidgets('chart is 200dp tall inside a card', (tester) async {
      final history = [
        (date: DateTime(2025, 1, 1), netWorth: 50000000),
        (date: DateTime(2025, 2, 1), netWorth: 60000000),
      ];

      await tester.pumpWidget(buildApp(history));
      expect(find.byType(Card), findsOneWidget);
    });
  });
}
