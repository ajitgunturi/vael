import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vael/core/database/database.dart';
import 'package:vael/features/planning/providers/emergency_fund_provider.dart';
import 'package:vael/features/planning/providers/life_profile_provider.dart';
import 'package:vael/features/planning/screens/emergency_fund_screen.dart';
import 'package:vael/features/planning/widgets/ef_progress_ring.dart';
import 'package:vael/features/planning/widgets/liquidity_tier_chip.dart';
import 'package:vael/shared/theme/app_theme.dart';
import 'package:vael/shared/widgets/empty_state.dart';

const _familyId = 'fam_ef_screen';
const _userId = 'user_ef_screen';

const _defaultState = EmergencyFundState(
  suggestedTargetMonths: 6,
  targetMonths: 6,
  monthlyEssentialPaise: 50000_00,
  totalEfBalancePaise: 200000_00,
  coverageMonths: 4.0,
  targetAmountPaise: 300000_00,
  monthsOfData: 6,
  hasOverride: false,
);

const _shortHistoryState = EmergencyFundState(
  suggestedTargetMonths: 6,
  targetMonths: 6,
  monthlyEssentialPaise: 50000_00,
  totalEfBalancePaise: 200000_00,
  coverageMonths: 4.0,
  targetAmountPaise: 300000_00,
  monthsOfData: 3,
  hasOverride: false,
);

Account _account({
  required String id,
  int balance = 0,
  String? liquidityTier,
  bool isEmergencyFund = false,
}) {
  return Account(
    id: id,
    name: 'Acct $id',
    type: 'savings',
    balance: balance,
    currency: 'INR',
    visibility: 'shared',
    sharedWithFamily: true,
    familyId: _familyId,
    userId: _userId,
    liquidityTier: liquidityTier,
    isEmergencyFund: isEmergencyFund,
  );
}

Widget _buildApp({
  EmergencyFundState state = _defaultState,
  List<Account> efAccounts = const [],
  List<Account> tierAccounts = const [],
}) {
  final params = (userId: _userId, familyId: _familyId);
  return ProviderScope(
    overrides: [
      emergencyFundStateProvider(params).overrideWith((ref) async => state),
      efAccountsProvider(
        _familyId,
      ).overrideWith((ref) => Stream.value(efAccounts)),
      tierAccountsProvider(
        _familyId,
      ).overrideWith((ref) => Stream.value(tierAccounts)),
      lifeProfileProvider(params).overrideWith((ref) => Stream.value(null)),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      home: const EmergencyFundScreen(familyId: _familyId, userId: _userId),
    ),
  );
}

void main() {
  group('EfProgressRing', () {
    testWidgets('renders correct text for coverage/target', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EfProgressRing(coverageMonths: 3.5, targetMonths: 6),
          ),
        ),
      );

      expect(find.text('3.5/6mo'), findsOneWidget);
    });

    testWidgets('uses green color when coverage >= 90%', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EfProgressRing(coverageMonths: 5.5, targetMonths: 6),
          ),
        ),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      final animation = indicator.valueColor! as AlwaysStoppedAnimation<Color?>;
      expect(animation.value, Colors.green);
    });

    testWidgets('uses red color when coverage < 50%', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EfProgressRing(coverageMonths: 1.0, targetMonths: 6),
          ),
        ),
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
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EfProgressRing(coverageMonths: 4.0, targetMonths: 6),
          ),
        ),
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
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LiquidityTierChip(tier: 'instant')),
        ),
      );
      expect(find.text('Instant'), findsOneWidget);
    });

    testWidgets('renders correct display text for shortTerm', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LiquidityTierChip(tier: 'shortTerm')),
        ),
      );
      expect(find.text('Short-term'), findsOneWidget);
    });

    testWidgets('renders correct display text for longTerm', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LiquidityTierChip(tier: 'longTerm')),
        ),
      );
      expect(find.text('Long-term'), findsOneWidget);
    });
  });

  group('EmergencyFundScreen', () {
    testWidgets('shows EmptyState when no EF accounts linked', (tester) async {
      await tester.pumpWidget(_buildApp(efAccounts: []));
      await tester.pump();

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No accounts linked yet'), findsOneWidget);
    });

    testWidgets('shows disclaimer when monthsOfData < 6', (tester) async {
      await tester.pumpWidget(_buildApp(state: _shortHistoryState));
      await tester.pump();

      expect(
        find.text('Based on 3 months of data - accuracy improves over time'),
        findsOneWidget,
      );
    });

    testWidgets('shows progress ring with coverage data', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();

      expect(find.byType(EfProgressRing), findsOneWidget);
      expect(find.text('4.0/6mo'), findsOneWidget);
    });

    testWidgets('shows linked accounts when EF accounts exist', (tester) async {
      final accounts = [
        _account(id: 'a1', balance: 100000_00, isEmergencyFund: true),
        _account(id: 'a2', balance: 50000_00, isEmergencyFund: true),
      ];
      await tester.pumpWidget(_buildApp(efAccounts: accounts));
      await tester.pump();

      expect(find.byType(EmptyState), findsNothing);
      expect(find.text('Acct a1'), findsOneWidget);
      expect(find.text('Acct a2'), findsOneWidget);
    });
  });
}
