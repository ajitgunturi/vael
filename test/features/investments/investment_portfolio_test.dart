import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/financial/investment_valuation.dart';
import 'package:vael/features/investments/screens/investment_portfolio_screen.dart';

void main() {
  group('PortfolioSummaryCard', () {
    testWidgets('should display portfolio value and returns', (tester) async {
      const summary = PortfolioSummary(
        totalInvested: 70000000, // ₹7L
        totalCurrentValue: 85000000, // ₹8.5L
        totalGain: 15000000,
        overallReturnPercent: 21.43,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PortfolioSummaryCard(summary: summary)),
        ),
      );

      expect(find.text('Portfolio Value'), findsOneWidget);
      expect(find.textContaining('8,50,000'), findsOneWidget);
      expect(find.textContaining('21.4%'), findsOneWidget);
    });
  });

  group('BucketCard', () {
    testWidgets('should display bucket info with gain', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BucketCard(
              name: 'Retirement MFs',
              bucketType: 'mutualFunds',
              investedAmount: 50000000,
              currentValue: 60000000,
              returnRate: 0.12,
            ),
          ),
        ),
      );

      expect(find.text('Retirement MFs'), findsOneWidget);
      expect(find.textContaining('12%'), findsOneWidget);
      expect(find.textContaining('+20.0%'), findsOneWidget);
    });

    testWidgets('should show loss in red', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BucketCard(
              name: 'Stocks',
              bucketType: 'stocks',
              investedAmount: 50000000,
              currentValue: 40000000,
              returnRate: 0.14,
            ),
          ),
        ),
      );

      expect(find.textContaining('-20.0%'), findsOneWidget);
    });
  });
}
