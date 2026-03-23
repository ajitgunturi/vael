import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/financial/allocation_engine.dart';
import 'package:vael/core/models/enums.dart';

void main() {
  group('AllocationEngine.targetForAge', () {
    // ── Conservative profile ──────────────────────────────────────────
    test('age 25, conservative -> 6000/3000/500/500', () {
      final t = AllocationEngine.targetForAge(
        age: 25,
        riskProfile: 'conservative',
      );
      expect(t.equityBp, 6000);
      expect(t.debtBp, 3000);
      expect(t.goldBp, 500);
      expect(t.cashBp, 500);
    });

    test('age 35, conservative -> 5000/3500/1000/500', () {
      final t = AllocationEngine.targetForAge(
        age: 35,
        riskProfile: 'conservative',
      );
      expect(t.equityBp, 5000);
      expect(t.debtBp, 3500);
      expect(t.goldBp, 1000);
      expect(t.cashBp, 500);
    });

    test('age 45, conservative -> 4000/4000/1000/1000', () {
      final t = AllocationEngine.targetForAge(
        age: 45,
        riskProfile: 'conservative',
      );
      expect(t.equityBp, 4000);
      expect(t.debtBp, 4000);
      expect(t.goldBp, 1000);
      expect(t.cashBp, 1000);
    });

    test('age 55, conservative -> 3000/4500/1000/1500', () {
      final t = AllocationEngine.targetForAge(
        age: 55,
        riskProfile: 'conservative',
      );
      expect(t.equityBp, 3000);
      expect(t.debtBp, 4500);
      expect(t.goldBp, 1000);
      expect(t.cashBp, 1500);
    });

    test('age 65, conservative -> 2000/5000/1000/2000', () {
      final t = AllocationEngine.targetForAge(
        age: 65,
        riskProfile: 'conservative',
      );
      expect(t.equityBp, 2000);
      expect(t.debtBp, 5000);
      expect(t.goldBp, 1000);
      expect(t.cashBp, 2000);
    });

    test('age 75, conservative -> 1500/5000/1000/2500', () {
      final t = AllocationEngine.targetForAge(
        age: 75,
        riskProfile: 'conservative',
      );
      expect(t.equityBp, 1500);
      expect(t.debtBp, 5000);
      expect(t.goldBp, 1000);
      expect(t.cashBp, 2500);
    });

    // ── Moderate profile ──────────────────────────────────────────────
    test('age 25, moderate -> 7500/1500/500/500', () {
      final t = AllocationEngine.targetForAge(age: 25, riskProfile: 'moderate');
      expect(t.equityBp, 7500);
      expect(t.debtBp, 1500);
      expect(t.goldBp, 500);
      expect(t.cashBp, 500);
    });

    test('age 35, moderate -> 6500/2000/1000/500', () {
      final t = AllocationEngine.targetForAge(age: 35, riskProfile: 'moderate');
      expect(t.equityBp, 6500);
      expect(t.debtBp, 2000);
      expect(t.goldBp, 1000);
      expect(t.cashBp, 500);
    });

    test('age 45, moderate -> 5500/2500/1000/1000', () {
      final t = AllocationEngine.targetForAge(age: 45, riskProfile: 'moderate');
      expect(t.equityBp, 5500);
      expect(t.debtBp, 2500);
      expect(t.goldBp, 1000);
      expect(t.cashBp, 1000);
    });

    test('age 55, moderate -> 4500/3000/1000/1500', () {
      final t = AllocationEngine.targetForAge(age: 55, riskProfile: 'moderate');
      expect(t.equityBp, 4500);
      expect(t.debtBp, 3000);
      expect(t.goldBp, 1000);
      expect(t.cashBp, 1500);
    });

    test('age 65, moderate -> 3500/3500/1000/2000', () {
      final t = AllocationEngine.targetForAge(age: 65, riskProfile: 'moderate');
      expect(t.equityBp, 3500);
      expect(t.debtBp, 3500);
      expect(t.goldBp, 1000);
      expect(t.cashBp, 2000);
    });

    test('age 75, moderate -> 2500/4000/1000/2500', () {
      final t = AllocationEngine.targetForAge(age: 75, riskProfile: 'moderate');
      expect(t.equityBp, 2500);
      expect(t.debtBp, 4000);
      expect(t.goldBp, 1000);
      expect(t.cashBp, 2500);
    });

    // ── Aggressive profile ────────────────────────────────────────────
    test('age 25, aggressive -> 8500/1000/0/500', () {
      final t = AllocationEngine.targetForAge(
        age: 25,
        riskProfile: 'aggressive',
      );
      expect(t.equityBp, 8500);
      expect(t.debtBp, 1000);
      expect(t.goldBp, 0);
      expect(t.cashBp, 500);
    });

    test('age 35, aggressive -> 7500/1500/500/500', () {
      final t = AllocationEngine.targetForAge(
        age: 35,
        riskProfile: 'aggressive',
      );
      expect(t.equityBp, 7500);
      expect(t.debtBp, 1500);
      expect(t.goldBp, 500);
      expect(t.cashBp, 500);
    });

    test('age 45, aggressive -> 6500/2000/1000/500', () {
      final t = AllocationEngine.targetForAge(
        age: 45,
        riskProfile: 'aggressive',
      );
      expect(t.equityBp, 6500);
      expect(t.debtBp, 2000);
      expect(t.goldBp, 1000);
      expect(t.cashBp, 500);
    });

    test('age 55, aggressive -> 5500/2500/1000/1000', () {
      final t = AllocationEngine.targetForAge(
        age: 55,
        riskProfile: 'aggressive',
      );
      expect(t.equityBp, 5500);
      expect(t.debtBp, 2500);
      expect(t.goldBp, 1000);
      expect(t.cashBp, 1000);
    });

    test('age 65, aggressive -> 4500/3000/1000/1500', () {
      final t = AllocationEngine.targetForAge(
        age: 65,
        riskProfile: 'aggressive',
      );
      expect(t.equityBp, 4500);
      expect(t.debtBp, 3000);
      expect(t.goldBp, 1000);
      expect(t.cashBp, 1500);
    });

    test('age 75, aggressive -> 3500/3500/1000/2000', () {
      final t = AllocationEngine.targetForAge(
        age: 75,
        riskProfile: 'aggressive',
      );
      expect(t.equityBp, 3500);
      expect(t.debtBp, 3500);
      expect(t.goldBp, 1000);
      expect(t.cashBp, 2000);
    });

    // ── Custom overrides ──────────────────────────────────────────────
    test('custom targets override defaults when provided', () {
      final custom = [
        AllocationTargetOverride(
          ageBandStart: 20,
          ageBandEnd: 30,
          equityBp: 9000,
          debtBp: 500,
          goldBp: 250,
          cashBp: 250,
        ),
      ];
      final t = AllocationEngine.targetForAge(
        age: 25,
        riskProfile: 'moderate',
        customTargets: custom,
      );
      expect(t.equityBp, 9000);
      expect(t.debtBp, 500);
      expect(t.goldBp, 250);
      expect(t.cashBp, 250);
    });

    test('custom targets fall back to defaults for uncovered age bands', () {
      final custom = [
        AllocationTargetOverride(
          ageBandStart: 20,
          ageBandEnd: 30,
          equityBp: 9000,
          debtBp: 500,
          goldBp: 250,
          cashBp: 250,
        ),
      ];
      // Age 45 is NOT covered by custom, should use default moderate
      final t = AllocationEngine.targetForAge(
        age: 45,
        riskProfile: 'moderate',
        customTargets: custom,
      );
      expect(t.equityBp, 5500);
      expect(t.debtBp, 2500);
      expect(t.goldBp, 1000);
      expect(t.cashBp, 1000);
    });

    // ── All defaults sum to 10000 ─────────────────────────────────────
    test(
      'all default targets sum to 10000 bp for every profile and age band',
      () {
        const profiles = ['conservative', 'moderate', 'aggressive'];
        const ages = [25, 35, 45, 55, 65, 75];
        for (final profile in profiles) {
          for (final age in ages) {
            final t = AllocationEngine.targetForAge(
              age: age,
              riskProfile: profile,
            );
            expect(
              t.equityBp + t.debtBp + t.goldBp + t.cashBp,
              10000,
              reason: 'profile=$profile age=$age',
            );
          }
        }
      },
    );
  });

  group('AllocationEngine.assetClassForBucket', () {
    test('mutualFunds -> equity', () {
      expect(
        AllocationEngine.assetClassForBucket('mutualFunds'),
        AssetClass.equity,
      );
    });

    test('stocks -> equity', () {
      expect(AllocationEngine.assetClassForBucket('stocks'), AssetClass.equity);
    });

    test('ppf -> debt', () {
      expect(AllocationEngine.assetClassForBucket('ppf'), AssetClass.debt);
    });

    test('epf -> debt', () {
      expect(AllocationEngine.assetClassForBucket('epf'), AssetClass.debt);
    });

    test('fixedDeposit -> debt', () {
      expect(
        AllocationEngine.assetClassForBucket('fixedDeposit'),
        AssetClass.debt,
      );
    });

    test('bonds -> debt', () {
      expect(AllocationEngine.assetClassForBucket('bonds'), AssetClass.debt);
    });

    test('policy -> debt', () {
      expect(AllocationEngine.assetClassForBucket('policy'), AssetClass.debt);
    });
  });

  group('AllocationEngine.npsAllocation', () {
    test('age 30 -> 75% equity / 25% debt', () {
      final result = AllocationEngine.npsAllocation(10000000, 30); // 1L paise
      expect(result[AssetClass.equity], 7500000);
      expect(result[AssetClass.debt], 2500000);
    });

    test('age 40 -> 50% equity / 50% debt', () {
      final result = AllocationEngine.npsAllocation(10000000, 40);
      expect(result[AssetClass.equity], 5000000);
      expect(result[AssetClass.debt], 5000000);
    });

    test('age 50 -> 25% equity / 75% debt', () {
      final result = AllocationEngine.npsAllocation(10000000, 50);
      expect(result[AssetClass.equity], 2500000);
      expect(result[AssetClass.debt], 7500000);
    });
  });

  group('AllocationEngine.currentAllocation', () {
    test('sums values by asset class correctly', () {
      final holdings = [
        HoldingInput(bucketType: 'mutualFunds', currentValuePaise: 5000000),
        HoldingInput(bucketType: 'stocks', currentValuePaise: 3000000),
        HoldingInput(bucketType: 'ppf', currentValuePaise: 2000000),
        HoldingInput(bucketType: 'fixedDeposit', currentValuePaise: 1000000),
      ];
      final result = AllocationEngine.currentAllocation(holdings, 30);
      expect(result[AssetClass.equity], 8000000);
      expect(result[AssetClass.debt], 3000000);
      expect(result[AssetClass.gold] ?? 0, 0);
      expect(result[AssetClass.cash] ?? 0, 0);
    });

    test('handles NPS split by age', () {
      final holdings = [
        HoldingInput(bucketType: 'nps', currentValuePaise: 10000000),
      ];
      // age 30 -> 75/25 split
      final result = AllocationEngine.currentAllocation(holdings, 30);
      expect(result[AssetClass.equity], 7500000);
      expect(result[AssetClass.debt], 2500000);
    });
  });

  group('AllocationEngine.rebalancingDeltas', () {
    test('computes overweight/underweight amounts and percentages', () {
      final current = {
        AssetClass.equity: 8000000,
        AssetClass.debt: 2000000,
        AssetClass.gold: 0,
        AssetClass.cash: 0,
      };
      final target = AllocationTarget(
        equityBp: 7500,
        debtBp: 1500,
        goldBp: 500,
        cashBp: 500,
      );
      final deltas = AllocationEngine.rebalancingDeltas(
        currentValuePaise: current,
        target: target,
      );
      // Total = 10M. Target equity = 75% = 7.5M. Actual = 8M -> overweight by 500k
      final equityDelta = deltas.firstWhere(
        (d) => d.assetClass == AssetClass.equity,
      );
      expect(equityDelta.actualBp, 8000);
      expect(equityDelta.targetBp, 7500);
      expect(equityDelta.deltaPaise, 500000); // overweight
      expect(equityDelta.deltaDescription, 'overweight');

      final goldDelta = deltas.firstWhere(
        (d) => d.assetClass == AssetClass.gold,
      );
      expect(goldDelta.actualBp, 0);
      expect(goldDelta.targetBp, 500);
      expect(goldDelta.deltaPaise, -500000); // underweight
      expect(goldDelta.deltaDescription, 'underweight');
    });

    test('handles empty portfolio (all zeros)', () {
      final current = {
        AssetClass.equity: 0,
        AssetClass.debt: 0,
        AssetClass.gold: 0,
        AssetClass.cash: 0,
      };
      final target = AllocationTarget(
        equityBp: 7500,
        debtBp: 1500,
        goldBp: 500,
        cashBp: 500,
      );
      final deltas = AllocationEngine.rebalancingDeltas(
        currentValuePaise: current,
        target: target,
      );
      for (final d in deltas) {
        expect(d.actualBp, 0);
        expect(d.deltaPaise, 0);
      }
    });
  });
}
