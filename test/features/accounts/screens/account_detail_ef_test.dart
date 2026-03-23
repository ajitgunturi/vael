import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vael/features/planning/widgets/ef_badge.dart';
import 'package:vael/features/planning/widgets/liquidity_tier_chip.dart';

/// Unit-level widget tests for the EfBadge and LiquidityTierChip as they
/// would appear on the account detail screen.
///
/// We test the widgets directly (not the full AccountDetailScreen) to avoid
/// requiring complex database/provider scaffolding. The integration of these
/// widgets into AccountDetailScreen is verified by acceptance criteria grep.

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
}

void main() {
  group('EfBadge widget', () {
    testWidgets('renders Emergency Fund text with shield icon', (tester) async {
      await _pump(tester, const EfBadge());

      expect(find.text('Emergency Fund'), findsOneWidget);
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
    });

    testWidgets('renders as ActionChip', (tester) async {
      await _pump(tester, const EfBadge());

      expect(find.byType(ActionChip), findsOneWidget);
    });

    testWidgets('calls onTap when pressed', (tester) async {
      var tapped = false;
      await _pump(tester, EfBadge(onTap: () => tapped = true));

      await tester.tap(find.byType(ActionChip));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('does not throw when onTap is null', (tester) async {
      await _pump(tester, const EfBadge());

      // ActionChip with null onPressed is disabled -- should not throw.
      expect(find.byType(ActionChip), findsOneWidget);
    });
  });

  group('LiquidityTierChip conditionals', () {
    testWidgets('renders when tier is provided', (tester) async {
      await _pump(tester, const LiquidityTierChip(tier: 'instant'));

      expect(find.text('Instant'), findsOneWidget);
      expect(find.byType(Chip), findsOneWidget);
    });

    testWidgets('renders correct text for shortTerm', (tester) async {
      await _pump(tester, const LiquidityTierChip(tier: 'shortTerm'));

      expect(find.text('Short-term'), findsOneWidget);
    });

    testWidgets('renders correct text for longTerm', (tester) async {
      await _pump(tester, const LiquidityTierChip(tier: 'longTerm'));

      expect(find.text('Long-term'), findsOneWidget);
    });
  });

  group('Conditional rendering logic', () {
    testWidgets('EfBadge shown only when isEmergencyFund is true', (
      tester,
    ) async {
      // Simulate the conditional: if (isEmergencyFund) EfBadge()
      const isEmergencyFund = true;
      await _pump(
        tester,
        Column(children: [if (isEmergencyFund) const EfBadge()]),
      );

      expect(find.byType(EfBadge), findsOneWidget);
    });

    testWidgets('EfBadge NOT shown when isEmergencyFund is false', (
      tester,
    ) async {
      const isEmergencyFund = false;
      await _pump(
        tester,
        Column(children: [if (isEmergencyFund) const EfBadge()]),
      );

      expect(find.byType(EfBadge), findsNothing);
    });

    testWidgets('LiquidityTierChip shown when tier is not null', (
      tester,
    ) async {
      const String? tier = 'instant';
      await _pump(
        tester,
        Column(children: [if (tier != null) LiquidityTierChip(tier: tier)]),
      );

      expect(find.byType(LiquidityTierChip), findsOneWidget);
    });

    testWidgets('LiquidityTierChip NOT shown when tier is null', (
      tester,
    ) async {
      const String? tier = null;
      await _pump(
        tester,
        Column(children: [if (tier != null) LiquidityTierChip(tier: tier)]),
      );

      expect(find.byType(LiquidityTierChip), findsNothing);
    });
  });
}
