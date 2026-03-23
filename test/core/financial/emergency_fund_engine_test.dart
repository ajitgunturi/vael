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
            'essential': 3000000,
            'homeExpenses': 1000000,
            'livingExpense': 500000,
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
            'essential': 3000000,
            'homeExpenses': 1000000,
            'livingExpense': 500000,
          },
          {
            'essential': 4000000,
            'homeExpenses': 1200000,
            'livingExpense': 600000,
          },
          {
            'essential': 2000000,
            'homeExpenses': 800000,
            'livingExpense': 400000,
          },
        ];
        // Totals: 4500000, 5800000, 3200000 => avg = 13500000 / 3 = 4500000
        expect(EmergencyFundEngine.monthlyEssentialAverage(months), 4500000);
      });

      test('ignores non-essential groups in input maps', () {
        final months = [
          {
            'essential': 3000000,
            'homeExpenses': 1000000,
            'livingExpense': 500000,
            'luxuryEssential': 9999,
          },
        ];
        expect(EmergencyFundEngine.monthlyEssentialAverage(months), 4500000);
      });

      test(
        'handles maps with all CategoryGroup keys and filters correctly',
        () {
          // Map with ALL CategoryGroup enum .name values
          final allGroups = <String, int>{
            'assets': 100,
            'liabilities': 200,
            'homeExpenses': 200,
            'livingExpense': 300,
            'essential': 100,
            'luxuryEssential': 999,
            'luxuryNonEssential': 888,
            'philanthropy': 777,
            'selfImprovement': 666,
            'investments': 555,
            'nonEssential': 444,
            'missing': 333,
          };
          // Only essential(100) + homeExpenses(200) + livingExpense(300) = 600
          expect(EmergencyFundEngine.monthlyEssentialAverage([allGroups]), 600);
        },
      );
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
      test(
        'essentialGroups matches CategoryGroup enum names for essential types',
        () {
          // Verify the essentialGroups set contains exactly the right CategoryGroup names
          expect(
            EmergencyFundEngine.essentialGroups,
            containsAll(['essential', 'homeExpenses', 'livingExpense']),
          );
          expect(EmergencyFundEngine.essentialGroups.length, 3);
        },
      );

      test(
        'filtering a map with all CategoryGroup names returns only essential totals',
        () {
          // Build a map using every CategoryGroup.values .name
          final allGroupMap = <String, int>{
            for (final g in CategoryGroup.values) g.name: 1000,
          };
          // There are 12 CategoryGroup values, only 3 are essential
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
