import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vael/core/models/enums.dart';
import 'package:vael/features/planning/providers/allocation_provider.dart';
import 'package:vael/features/planning/widgets/allocation_banner.dart';
import 'package:vael/shared/theme/app_theme.dart';

const _familyId = 'fam_banner_test';
const _userId = 'user_banner_test';

/// Mock current allocation with equity as dominant class.
final _mockAllocation = <AssetClass, int>{
  AssetClass.equity: 7200000,
  AssetClass.debt: 1500000,
  AssetClass.gold: 800000,
  AssetClass.cash: 500000,
};

final _emptyAllocation = <AssetClass, int>{};

void main() {
  Widget buildApp({Map<AssetClass, int>? alloc}) {
    final allocation = alloc ?? _mockAllocation;
    return ProviderScope(
      overrides: [
        currentAllocationProvider.overrideWith((ref, params) {
          return Stream.value(allocation);
        }),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: AllocationBanner(
            familyId: _familyId,
            userId: _userId,
            userAge: 35,
          ),
        ),
      ),
    );
  }

  group('AllocationBanner', () {
    testWidgets('renders equity percentage and target', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Total = 10,000,000. Equity = 7,200,000 => 72%.
      // Target for age 35, moderate: 6500bp = 65%.
      expect(find.textContaining('Equity'), findsOneWidget);
      expect(find.textContaining('72%'), findsOneWidget);
      expect(find.textContaining('target'), findsOneWidget);
      expect(find.text('View Allocation'), findsOneWidget);
    });

    testWidgets('tap on banner triggers InkWell onTap', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Verify the banner is wrapped in an InkWell (tappable).
      expect(find.byType(InkWell), findsOneWidget);

      // Verify "View Allocation" text is present (CTA).
      expect(find.text('View Allocation'), findsOneWidget);

      // Verify chevron icon is present.
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('hidden when no holdings', (tester) async {
      await tester.pumpWidget(buildApp(alloc: _emptyAllocation));
      await tester.pumpAndSettle();

      expect(find.text('View Allocation'), findsNothing);
      expect(find.textContaining('Equity'), findsNothing);
    });

    testWidgets('semantics label is correct', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final semanticsFinder = find.bySemanticsLabel(
        RegExp('Equity allocation.*versus target.*Tap to view'),
      );
      expect(semanticsFinder, findsAtLeastNWidgets(1));
    });
  });
}
