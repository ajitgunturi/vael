import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vael/core/database/database.dart';
import 'package:vael/core/financial/savings_allocation_engine.dart';
import 'package:vael/features/planning/providers/savings_allocation_providers.dart';
import 'package:vael/features/planning/screens/savings_allocation_screen.dart';
import 'package:vael/shared/theme/app_theme.dart';

const _familyId = 'fam_alloc';

SavingsAllocationRule _fakeRule({
  required String id,
  required int priority,
  String targetType = 'emergencyFund',
  String allocationType = 'fixed',
  int? amountPaise,
  int? percentageBp,
}) {
  return SavingsAllocationRule(
    id: id,
    familyId: _familyId,
    priority: priority,
    targetType: targetType,
    targetId: null,
    allocationType: allocationType,
    amountPaise: amountPaise,
    percentageBp: percentageBp,
    isActive: true,
    createdAt: DateTime(2025),
  );
}

Widget _buildApp({
  List<SavingsAllocationRule> rules = const [],
  List<AllocationAdvice> advices = const [],
  int surplus = 0,
}) {
  return ProviderScope(
    overrides: [
      allocationRulesProvider(
        _familyId,
      ).overrideWith((_) => Stream.value(rules)),
      allocationAdvisoryProvider(_familyId).overrideWith((_) async => advices),
      monthlySurplusProvider(_familyId).overrideWith((_) async => surplus),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      home: const SavingsAllocationScreen(familyId: _familyId),
    ),
  );
}

void main() {
  group('SavingsAllocationScreen', () {
    testWidgets('renders advisory output with allocated amounts', (
      tester,
    ) async {
      final advices = [
        const AllocationAdvice(
          targetType: 'emergencyFund',
          targetName: 'Emergency Fund',
          allocatedPaise: 500000,
          remainingToTarget: 1000000,
        ),
        const AllocationAdvice(
          targetType: 'sinkingFund',
          targetId: 'goal_1',
          targetName: 'Vacation',
          allocatedPaise: 300000,
          remainingToTarget: 200000,
        ),
        const AllocationAdvice(
          targetType: 'opportunityFund',
          targetName: 'Opportunity Fund',
          allocatedPaise: 200000,
          remainingToTarget: 0,
        ),
      ];

      await tester.pumpWidget(_buildApp(advices: advices, surplus: 1000000));
      await tester.pumpAndSettle();

      // Verify advisory output renders target names
      expect(find.text('Emergency Fund'), findsWidgets);
      expect(find.text('Vacation'), findsOneWidget);
      expect(find.text('Opportunity Fund'), findsWidgets);
    });

    testWidgets('shows advisory-only disclaimer', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          advices: [
            const AllocationAdvice(
              targetType: 'emergencyFund',
              targetName: 'Emergency Fund',
              allocatedPaise: 100000,
              remainingToTarget: 500000,
            ),
          ],
          surplus: 100000,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Advisory only'), findsOneWidget);
    });

    testWidgets('renders rule list with priority numbers', (tester) async {
      final rules = [
        _fakeRule(id: 'r1', priority: 1, amountPaise: 500000),
        _fakeRule(
          id: 'r2',
          priority: 2,
          targetType: 'sinkingFund',
          amountPaise: 300000,
        ),
        _fakeRule(
          id: 'r3',
          priority: 3,
          targetType: 'opportunityFund',
          allocationType: 'percentage',
          percentageBp: 5000,
        ),
      ];

      await tester.pumpWidget(_buildApp(rules: rules));
      await tester.pumpAndSettle();

      // Priority numbers in CircleAvatar
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('does not contain Create Transaction or Apply button', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildApp(
          advices: [
            const AllocationAdvice(
              targetType: 'emergencyFund',
              targetName: 'Emergency Fund',
              allocatedPaise: 100000,
              remainingToTarget: 0,
            ),
          ],
          surplus: 100000,
        ),
      );
      await tester.pumpAndSettle();

      // SAVE-04 compliance: no auto-transaction buttons
      expect(find.text('Create Transaction'), findsNothing);
      expect(find.text('Apply'), findsNothing);
    });
  });
}
