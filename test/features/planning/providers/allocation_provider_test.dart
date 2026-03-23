import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vael/core/database/database.dart' as db;
import 'package:vael/core/financial/allocation_engine.dart';
import 'package:vael/core/models/enums.dart';
import 'package:vael/core/providers/database_providers.dart';
import 'package:vael/features/planning/providers/allocation_provider.dart';

const _familyId = 'fam_alloc';
const _userId = 'user_alloc';

void main() {
  late db.AppDatabase database;
  late ProviderContainer container;

  setUp(() async {
    database = db.AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );

    await database
        .into(database.families)
        .insert(
          db.FamiliesCompanion.insert(
            id: _familyId,
            name: 'Alloc Family',
            createdAt: DateTime(2025),
          ),
        );
    await database
        .into(database.users)
        .insert(
          db.UsersCompanion.insert(
            id: _userId,
            email: 'alloc@family.local',
            displayName: 'Alloc User',
            role: 'admin',
            familyId: _familyId,
          ),
        );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  group('currentAllocationProvider', () {
    test('emits allocation map from investment holdings', () async {
      // Insert holdings: 100L in stocks, 50L in ppf
      final now = DateTime.now();
      await database
          .into(database.investmentHoldings)
          .insert(
            db.InvestmentHoldingsCompanion.insert(
              id: 'h1',
              name: 'Equity MF',
              bucketType: 'mutualFunds',
              investedAmount: 8000000,
              currentValue: 10000000,
              familyId: _familyId,
              userId: _userId,
              createdAt: now,
            ),
          );
      await database
          .into(database.investmentHoldings)
          .insert(
            db.InvestmentHoldingsCompanion.insert(
              id: 'h2',
              name: 'PPF',
              bucketType: 'ppf',
              investedAmount: 4000000,
              currentValue: 5000000,
              familyId: _familyId,
              userId: _userId,
              createdAt: now,
            ),
          );

      final sub = container.listen(
        currentAllocationProvider((familyId: _familyId, userAge: 30)),
        (_, __) {},
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final result = sub.read();
      expect(result.value, isNotNull);
      final alloc = result.value!;

      // mutualFunds -> equity (10L), ppf -> debt (5L)
      expect(alloc[AssetClass.equity], 10000000);
      expect(alloc[AssetClass.debt], 5000000);
    });
  });

  group('targetAllocationProvider', () {
    test('returns correct target for age and risk profile', () {
      final target = container.read(
        targetAllocationProvider((
          age: 30,
          riskProfile: 'moderate',
          customTargets: null,
        )),
      );

      // Moderate profile for age 30-40 band
      expect(target.equityBp, 6500);
      expect(target.debtBp, 2000);
      expect(target.goldBp, 1000);
      expect(target.cashBp, 500);
    });
  });

  group('rebalancingDeltasProvider', () {
    test('computes deltas from current vs target', () {
      final current = <AssetClass, int>{
        AssetClass.equity: 7000000, // 70% of 10M
        AssetClass.debt: 2000000, // 20%
        AssetClass.gold: 500000, // 5%
        AssetClass.cash: 500000, // 5%
      };

      const target = AllocationTarget(
        equityBp: 6000,
        debtBp: 3000,
        goldBp: 500,
        cashBp: 500,
      );

      final deltas = container.read(
        rebalancingDeltasProvider((currentValuePaise: current, target: target)),
      );

      expect(deltas, hasLength(4));

      final equityDelta = deltas.firstWhere(
        (d) => d.assetClass == AssetClass.equity,
      );
      // Actual 70% vs target 60% -> overweight
      expect(equityDelta.deltaDescription, 'overweight');
      expect(equityDelta.deltaPaise, greaterThan(0));

      final debtDelta = deltas.firstWhere(
        (d) => d.assetClass == AssetClass.debt,
      );
      // Actual 20% vs target 30% -> underweight
      expect(debtDelta.deltaDescription, 'underweight');
      expect(debtDelta.deltaPaise, lessThan(0));
    });
  });
}
