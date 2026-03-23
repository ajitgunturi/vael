import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/features/planning/widgets/ef_progress_ring.dart';
import 'package:vael/features/planning/widgets/liquidity_tier_chip.dart';

// Helper to pump a widget inside a MaterialApp scaffold.
Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
}

void main() {
  group('EfProgressRing', () {
    testWidgets('renders correct text for coverage/target', (tester) async {
      await _pump(
        tester,
        const EfProgressRing(coverageMonths: 3.5, targetMonths: 6),
      );

      expect(find.text('3.5/6mo'), findsOneWidget);
    });

    testWidgets('uses green color when coverage >= 90%', (tester) async {
      await _pump(
        tester,
        const EfProgressRing(coverageMonths: 5.5, targetMonths: 6),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      final animation = indicator.valueColor! as AlwaysStoppedAnimation<Color?>;
      expect(animation.value, Colors.green);
    });

    testWidgets('uses red color when coverage < 50%', (tester) async {
      await _pump(
        tester,
        const EfProgressRing(coverageMonths: 1.0, targetMonths: 6),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      final animation = indicator.valueColor! as AlwaysStoppedAnimation<Color?>;
      expect(animation.value, Colors.red);
    });

    testWidgets('uses amber color when coverage >= 50% and < 90%', (
      tester,
    ) async {
      await _pump(
        tester,
        const EfProgressRing(coverageMonths: 4.0, targetMonths: 6),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      final animation = indicator.valueColor! as AlwaysStoppedAnimation<Color?>;
      expect(animation.value, Colors.amber);
    });
  });

  group('LiquidityTierChip', () {
    testWidgets('renders correct display text for instant', (tester) async {
      await _pump(tester, const LiquidityTierChip(tier: 'instant'));
      expect(find.text('Instant'), findsOneWidget);
    });

    testWidgets('renders correct display text for shortTerm', (tester) async {
      await _pump(tester, const LiquidityTierChip(tier: 'shortTerm'));
      expect(find.text('Short-term'), findsOneWidget);
    });

    testWidgets('renders correct display text for longTerm', (tester) async {
      await _pump(tester, const LiquidityTierChip(tier: 'longTerm'));
      expect(find.text('Long-term'), findsOneWidget);
    });
  });
}
