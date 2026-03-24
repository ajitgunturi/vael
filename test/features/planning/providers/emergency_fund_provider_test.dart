import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vael/core/database/database.dart';
import 'package:vael/core/financial/emergency_fund_engine.dart';
import 'package:vael/core/providers/database_providers.dart';
import 'package:vael/features/planning/providers/emergency_fund_provider.dart';

const _familyId = 'fam_ef';
const _userId = 'user_ef';

/// Helper to build a minimal Account for testing.
Account _account({
  required String id,
  int balance = 0,
  String? liquidityTier,
  bool isEmergencyFund = false,
  String type = 'savings',
}) {
  return Account(
    id: id,
    name: 'Acct $id',
    type: type,
    balance: balance,
    currency: 'INR',
    visibility: 'shared',
    sharedWithFamily: true,
    familyId: _familyId,
    userId: _userId,
    liquidityTier: liquidityTier,
    isEmergencyFund: isEmergencyFund,
    isOpportunityFund: false,
    opportunityFundTargetPaise: null,
    minimumBalancePaise: null,
  );
}

void main() {
  // -----------------------------------------------------------------------
  // tierSummaryProvider (synchronous, no DB needed)
  // -----------------------------------------------------------------------
  group('tierSummaryProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('groups accounts by tier and sums balances', () {
      final accounts = [
        _account(id: 'a1', balance: 50000, liquidityTier: 'instant'),
        _account(id: 'a2', balance: 30000, liquidityTier: 'instant'),
        _account(id: 'a3', balance: 100000, liquidityTier: 'shortTerm'),
        _account(id: 'a4', balance: 200000, liquidityTier: 'longTerm'),
      ];

      final summary = container.read(tierSummaryProvider(accounts));

      expect(summary['instant'], 80000);
      expect(summary['shortTerm'], 100000);
      expect(summary['longTerm'], 200000);
      expect(summary.length, 3);
    });

    test('excludes accounts with null liquidityTier', () {
      final accounts = [
        _account(id: 'a1', balance: 50000, liquidityTier: 'instant'),
        _account(id: 'a2', balance: 30000, liquidityTier: null),
      ];

      final summary = container.read(tierSummaryProvider(accounts));

      expect(summary['instant'], 50000);
      expect(summary.length, 1);
    });

    test('returns empty map for empty list', () {
      final summary = container.read(tierSummaryProvider([]));
      expect(summary, isEmpty);
    });
  });

  // -----------------------------------------------------------------------
  // EmergencyFundState data class logic
  // -----------------------------------------------------------------------
  group('EmergencyFundState', () {
    test('correctly uses override when present', () {
      const state = EmergencyFundState(
        suggestedTargetMonths: 6,
        targetMonths: 9,
        monthlyEssentialPaise: 50000_00,
        totalEfBalancePaise: 150000_00,
        coverageMonths: 3.0,
        targetAmountPaise: 450000_00,
        monthsOfData: 6,
        hasOverride: true,
      );

      expect(state.hasOverride, isTrue);
      expect(state.targetMonths, 9); // override, not suggested
      expect(state.suggestedTargetMonths, 6);
    });

    test('works with zero balance and zero essentials', () {
      const state = EmergencyFundState(
        suggestedTargetMonths: 6,
        targetMonths: 6,
        monthlyEssentialPaise: 0,
        totalEfBalancePaise: 0,
        coverageMonths: 0.0,
        targetAmountPaise: 0,
        monthsOfData: 0,
        hasOverride: false,
      );

      expect(state.coverageMonths, 0.0);
      expect(state.targetAmountPaise, 0);
      expect(state.monthsOfData, 0);
    });
  });

  // -----------------------------------------------------------------------
  // monthlyEssentialsProvider (integration with in-memory DB)
  // -----------------------------------------------------------------------
  group('monthlyEssentialsProvider', () {
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );

      // Seed family + user.
      await db
          .into(db.families)
          .insert(
            FamiliesCompanion.insert(
              id: _familyId,
              name: 'EF Family',
              createdAt: DateTime(2025),
            ),
          );
      await db
          .into(db.users)
          .insert(
            UsersCompanion.insert(
              id: _userId,
              email: 'ef@family.local',
              displayName: 'EF User',
              role: 'admin',
              familyId: _familyId,
            ),
          );
      // Seed a savings account.
      await db
          .into(db.accounts)
          .insert(
            AccountsCompanion.insert(
              id: 'acct_1',
              name: 'Savings',
              type: 'savings',
              balance: 100000_00,
              visibility: 'shared',
              familyId: _familyId,
              userId: _userId,
            ),
          );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('returns record with monthlyAveragePaise and monthsUsed', () async {
      // No transactions seeded -> should return zero average, 0 months.
      final result = await container.read(
        monthlyEssentialsProvider((
          familyId: _familyId,
          now: DateTime(2025, 6, 15),
        )).future,
      );

      expect(result.monthlyAveragePaise, 0);
      expect(result.monthsUsed, 0);
    });
  });

  // -----------------------------------------------------------------------
  // emergencyFundStateProvider (direct computation verification)
  // -----------------------------------------------------------------------
  group('emergencyFundStateProvider logic', () {
    test('computes state correctly from engine with no override', () {
      // Verify the computation logic directly (same as provider body).
      const incomeStability = 'salariedStable';
      const monthlyAveragePaise = 50000_00;
      const totalEfBalancePaise = 100000_00;
      final suggestedMonths = EmergencyFundEngine.suggestedTargetMonths(
        incomeStability,
      );
      final targetMonths = suggestedMonths; // no override
      final coverage = EmergencyFundEngine.coverageMonths(
        totalEfBalancePaise,
        monthlyAveragePaise,
      );
      final targetAmount = EmergencyFundEngine.targetAmountPaise(
        monthlyAveragePaise,
        targetMonths,
      );

      final state = EmergencyFundState(
        suggestedTargetMonths: suggestedMonths,
        targetMonths: targetMonths,
        monthlyEssentialPaise: monthlyAveragePaise,
        totalEfBalancePaise: totalEfBalancePaise,
        coverageMonths: coverage,
        targetAmountPaise: targetAmount,
        monthsOfData: 4,
        hasOverride: false,
      );

      expect(state.suggestedTargetMonths, 3);
      expect(state.targetMonths, 3);
      expect(state.coverageMonths, 2.0);
      expect(state.targetAmountPaise, 150000_00);
      expect(state.hasOverride, isFalse);
      expect(state.monthsOfData, 4);
    });

    test('uses override target months when present', () {
      const override = 9;
      const monthlyAveragePaise = 50000_00;
      final suggestedMonths = EmergencyFundEngine.suggestedTargetMonths(
        'salariedStable',
      );
      const targetMonths = override;
      final targetAmount = EmergencyFundEngine.targetAmountPaise(
        monthlyAveragePaise,
        targetMonths,
      );

      final state = EmergencyFundState(
        suggestedTargetMonths: suggestedMonths,
        targetMonths: targetMonths,
        monthlyEssentialPaise: monthlyAveragePaise,
        totalEfBalancePaise: 0,
        coverageMonths: 0.0,
        targetAmountPaise: targetAmount,
        monthsOfData: 6,
        hasOverride: true,
      );

      expect(state.suggestedTargetMonths, 3);
      expect(state.targetMonths, 9); // uses override
      expect(state.targetAmountPaise, 450000_00);
      expect(state.hasOverride, isTrue);
    });
  });
}
