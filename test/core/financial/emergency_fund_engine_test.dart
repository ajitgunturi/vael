import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/financial/emergency_fund_engine.dart';
import 'package:vael/core/models/enums.dart';

void main() {
  group('EmergencyFundEngine', () {
    group('monthlyEssentialAverage', () {
      test('6 identical months returns that monthly total', () {
        final months = List.generate(
          6,
          (_) => {
            'ESSENTIAL': 3000000,
            'HOME_EXPENSES': 1000000,
            'LIVING_EXPENSE': 500000,
          },
        );
        expect(EmergencyFundEngine.monthlyEssentialAverage(months), 4500000);
      });

      test('empty list returns 0', () {
        expect(EmergencyFundEngine.monthlyEssentialAverage([]), 0);
      });

      test('3 months of varied data returns correct average', () {
        final months = [
          {
            'ESSENTIAL': 3000000,
            'HOME_EXPENSES': 1000000,
            'LIVING_EXPENSE': 500000,
          },
          {
            'ESSENTIAL': 4000000,
            'HOME_EXPENSES': 1200000,
            'LIVING_EXPENSE': 600000,
          },
          {
            'ESSENTIAL': 2000000,
            'HOME_EXPENSES': 800000,
            'LIVING_EXPENSE': 400000,
          },
        ];
        // Totals: 4500000, 5800000, 3200000 => avg = 13500000 / 3 = 4500000
        expect(EmergencyFundEngine.monthlyEssentialAverage(months), 4500000);
      });

      test('ignores non-essential groups in input maps', () {
        final months = [
          {
            'ESSENTIAL': 3000000,
            'HOME_EXPENSES': 1000000,
            'LIVING_EXPENSE': 500000,
            'LUXURY_ESSENTIAL': 9999,
          },
        ];
        expect(EmergencyFundEngine.monthlyEssentialAverage(months), 4500000);
      });

      test('handles maps with all DB groupName keys and filters correctly', () {
        // Map with all groupName values as stored in DB (uppercase slug format)
        final allGroups = <String, int>{
          'ASSETS': 100,
          'LIABILITIES': 200,
          'HOME_EXPENSES': 200,
          'LIVING_EXPENSE': 300,
          'ESSENTIAL': 100,
          'LUXURY_ESSENTIAL': 999,
          'LUXURY_NON_ESSENTIAL': 888,
          'PHILANTHROPY': 777,
          'SELF_IMPROVEMENT': 666,
          'INVESTMENTS': 555,
          'NON_ESSENTIAL': 444,
          'MISSING': 333,
        };
        // Only ESSENTIAL(100) + HOME_EXPENSES(200) + LIVING_EXPENSE(300) = 600
        expect(EmergencyFundEngine.monthlyEssentialAverage([allGroups]), 600);
      });
    });

    group('suggestedTargetMonths', () {
      test('salariedStable returns 3', () {
        expect(EmergencyFundEngine.suggestedTargetMonths('salariedStable'), 3);
      });

      test('salariedVariable returns 6', () {
        expect(
          EmergencyFundEngine.suggestedTargetMonths('salariedVariable'),
          6,
        );
      });

      test('freelance returns 9', () {
        expect(EmergencyFundEngine.suggestedTargetMonths('freelance'), 9);
      });

      test('selfEmployed returns 12', () {
        expect(EmergencyFundEngine.suggestedTargetMonths('selfEmployed'), 12);
      });

      test('unknown string returns 6 as safe default', () {
        expect(EmergencyFundEngine.suggestedTargetMonths('unknown'), 6);
      });
    });

    group('coverageMonths', () {
      test('computes correct ratio', () {
        expect(EmergencyFundEngine.coverageMonths(27000000, 4500000), 6.0);
      });

      test('returns 0 when monthlyEssentialPaise is 0 (division guard)', () {
        expect(EmergencyFundEngine.coverageMonths(10000000, 0), 0.0);
      });

      test('returns 0 when totalEfBalance is 0', () {
        expect(EmergencyFundEngine.coverageMonths(0, 4500000), 0.0);
      });
    });

    group('targetAmountPaise', () {
      test('computes correct product', () {
        expect(EmergencyFundEngine.targetAmountPaise(4500000, 6), 27000000);
      });

      test('returns 0 when monthlyEssentialPaise is 0', () {
        expect(EmergencyFundEngine.targetAmountPaise(0, 6), 0);
      });
    });

    group('suggestTierDistribution', () {
      test('6 months returns {instant: 1, shortTerm: 2, longTerm: 3}', () {
        expect(EmergencyFundEngine.suggestTierDistribution(targetMonths: 6), {
          'instant': 1,
          'shortTerm': 2,
          'longTerm': 3,
        });
      });

      test('3 months returns {instant: 1, shortTerm: 2, longTerm: 0}', () {
        expect(EmergencyFundEngine.suggestTierDistribution(targetMonths: 3), {
          'instant': 1,
          'shortTerm': 2,
          'longTerm': 0,
        });
      });

      test('1 month returns {instant: 1, shortTerm: 0, longTerm: 0}', () {
        expect(EmergencyFundEngine.suggestTierDistribution(targetMonths: 1), {
          'instant': 1,
          'shortTerm': 0,
          'longTerm': 0,
        });
      });
    });

    group('suggestTier', () {
      test('savings returns instant', () {
        expect(EmergencyFundEngine.suggestTier('savings'), 'instant');
      });

      test('current returns instant', () {
        expect(EmergencyFundEngine.suggestTier('current'), 'instant');
      });

      test('wallet returns instant', () {
        expect(EmergencyFundEngine.suggestTier('wallet'), 'instant');
      });

      test('investment returns longTerm', () {
        expect(EmergencyFundEngine.suggestTier('investment'), 'longTerm');
      });

      test('creditCard returns null', () {
        expect(EmergencyFundEngine.suggestTier('creditCard'), isNull);
      });

      test('loan returns null', () {
        expect(EmergencyFundEngine.suggestTier('loan'), isNull);
      });
    });

    group('string key contract with BudgetSummary', () {
      test('essentialGroups matches DB groupName format for essential types', () {
        // Verify the essentialGroups set contains exactly the right DB slug keys
        expect(
          EmergencyFundEngine.essentialGroups,
          containsAll(['ESSENTIAL', 'HOME_EXPENSES', 'LIVING_EXPENSE']),
        );
        expect(EmergencyFundEngine.essentialGroups.length, 3);
      });

      test(
        'filtering a map with all DB groupName keys returns only essential totals',
        () {
          // Build a map matching actual BudgetSummary.computeActualsByGroup output
          // (DB stores uppercase slug format, not Dart enum .name)
          final allGroupMap = <String, int>{
            'ASSETS': 1000,
            'LIABILITIES': 1000,
            'HOME_EXPENSES': 1000,
            'LIVING_EXPENSE': 1000,
            'ESSENTIAL': 1000,
            'LUXURY_ESSENTIAL': 1000,
            'LUXURY_NON_ESSENTIAL': 1000,
            'PHILANTHROPY': 1000,
            'SELF_IMPROVEMENT': 1000,
            'INVESTMENTS': 1000,
            'NON_ESSENTIAL': 1000,
            'MISSING': 1000,
          };
          expect(allGroupMap.length, CategoryGroup.values.length);

          final result = EmergencyFundEngine.monthlyEssentialAverage([
            allGroupMap,
          ]);
          // 3 essential groups * 1000 each = 3000
          expect(result, 3000);
        },
      );
    });
  });
}
