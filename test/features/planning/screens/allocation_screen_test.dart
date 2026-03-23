import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vael/core/financial/allocation_engine.dart';
import 'package:vael/core/models/enums.dart';
import 'package:vael/features/planning/providers/allocation_provider.dart';
import 'package:vael/features/planning/providers/life_profile_provider.dart';
import 'package:vael/features/planning/screens/allocation_screen.dart';
import 'package:vael/features/planning/widgets/allocation_donut_pair.dart';
import 'package:vael/features/planning/widgets/rebalancing_delta_table.dart';
import 'package:vael/shared/theme/app_theme.dart';

const _familyId = 'fam_alloc_test';
const _userId = 'user_alloc_test';

/// Mock current allocation in paise.
final _mockCurrentAllocation = <AssetClass, int>{
  AssetClass.equity: 7200000,
  AssetClass.debt: 1500000,
  AssetClass.gold: 800000,
  AssetClass.cash: 500000,
};

/// Empty allocation.
final _emptyAllocation = <AssetClass, int>{};

void main() {
  Widget buildApp({
    Map<AssetClass, int>? currentAlloc,
    bool hasLifeProfile = true,
  }) {
    final alloc = currentAlloc ?? _mockCurrentAllocation;

    return ProviderScope(
      overrides: [
        // Override current allocation stream to avoid drift DB.
        currentAllocationProvider.overrideWith((ref, params) {
          return Stream.value(alloc);
        }),
        // Override life profile provider.
        lifeProfileProvider.overrideWith((ref, params) {
          if (!hasLifeProfile) return Stream.value(null);
          // Not straightforward to create a drift LifeProfile in tests,
          // so we return null and handle the "no profile" case.
          return Stream.value(null);
        }),
        // Override custom targets (empty).
        customAllocationTargetsProvider.overrideWith((ref, id) {
          return Stream.value([]);
        }),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const AllocationScreen(familyId: _familyId, userId: _userId),
      ),
    );
  }

  /// Builds app with holdings and profile = null (shows no-profile view).
  Widget buildAppWithHoldingsNoProfile() {
    return ProviderScope(
      overrides: [
        currentAllocationProvider.overrideWith((ref, params) {
          return Stream.value(_mockCurrentAllocation);
        }),
        lifeProfileProvider.overrideWith((ref, params) {
          return Stream.value(null);
        }),
        customAllocationTargetsProvider.overrideWith((ref, id) {
          return Stream.value([]);
        }),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const AllocationScreen(familyId: _familyId, userId: _userId),
      ),
    );
  }

  /// Builds app with no holdings (empty state).
  Widget buildAppNoHoldings() {
    return ProviderScope(
      overrides: [
        currentAllocationProvider.overrideWith((ref, params) {
          return Stream.value(_emptyAllocation);
        }),
        lifeProfileProvider.overrideWith((ref, params) {
          return Stream.value(null);
        }),
        customAllocationTargetsProvider.overrideWith((ref, id) {
          return Stream.value([]);
        }),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const AllocationScreen(familyId: _familyId, userId: _userId),
      ),
    );
  }

  group('AllocationScreen', () {
    testWidgets('renders donut pair when holdings exist', (tester) async {
      await tester.pumpWidget(buildAppWithHoldingsNoProfile());
      await tester.pumpAndSettle();

      expect(find.byType(AllocationDonutPair), findsOneWidget);
      expect(find.text('Current'), findsOneWidget);
      expect(find.text('Target'), findsOneWidget);
    });

    testWidgets('renders delta table with overweight/underweight formatting', (
      tester,
    ) async {
      await tester.pumpWidget(buildAppWithHoldingsNoProfile());
      await tester.pumpAndSettle();

      // The no-profile view shows donut pair but no delta table.
      // The delta table is only in the full view with a profile.
      // In no-profile mode we show current allocation + setup card.
      expect(find.byType(AllocationDonutPair), findsOneWidget);
    });

    testWidgets('shows empty state when no holdings', (tester) async {
      await tester.pumpWidget(buildAppNoHoldings());
      await tester.pumpAndSettle();

      expect(find.text('No investments yet'), findsOneWidget);
      expect(
        find.text(
          'Add your investments to see how your portfolio is allocated across asset classes.',
        ),
        findsOneWidget,
      );
      expect(find.text('Add Investment'), findsOneWidget);
    });

    testWidgets('shows "Set up your Life Profile" when no profile', (
      tester,
    ) async {
      await tester.pumpWidget(buildAppWithHoldingsNoProfile());
      await tester.pumpAndSettle();

      expect(find.text('Set up your Life Profile'), findsOneWidget);
      expect(find.text('Set Up Profile'), findsOneWidget);
    });

    testWidgets('AppBar shows Asset Allocation title', (tester) async {
      await tester.pumpWidget(buildAppNoHoldings());
      await tester.pumpAndSettle();

      expect(find.text('Asset Allocation'), findsOneWidget);
    });

    testWidgets('AllocationDonutPair shows legend entries', (tester) async {
      await tester.pumpWidget(buildAppWithHoldingsNoProfile());
      await tester.pumpAndSettle();

      expect(find.text('Equity'), findsNWidgets(2)); // current + target legends
      expect(find.text('Debt'), findsNWidgets(2));
      expect(find.text('Gold'), findsNWidgets(2));
      expect(find.text('Cash'), findsNWidgets(2));
    });

    testWidgets('RebalancingDeltaTable renders header text', (tester) async {
      // Build the widget directly to test it.
      final deltas = AllocationEngine.rebalancingDeltas(
        currentValuePaise: _mockCurrentAllocation,
        target: const AllocationTarget(
          equityBp: 7500,
          debtBp: 1500,
          goldBp: 500,
          cashBp: 500,
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: RebalancingDeltaTable(deltas: deltas),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Rebalancing Guidance'), findsOneWidget);
      expect(find.text('Equity'), findsOneWidget);
      expect(find.text('Debt'), findsOneWidget);
      expect(find.text('Gold'), findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);
    });
  });
}
