import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/financial/savings_allocation_engine.dart';

void main() {
  group('SavingsAllocationEngine', () {
    group('distribute', () {
      test(
        '3 rules in priority order allocates surplus to highest priority first',
        () {
          final rules = [
            AllocationRule(
              priority: 1,
              targetType: 'emergencyFund',
              allocationType: 'fixed',
              amountPaise: 5000,
            ),
            AllocationRule(
              priority: 2,
              targetType: 'sinkingFund',
              targetId: 'sf1',
              allocationType: 'fixed',
              amountPaise: 3000,
            ),
            AllocationRule(
              priority: 3,
              targetType: 'investmentGoal',
              targetId: 'ig1',
              allocationType: 'fixed',
              amountPaise: 2000,
            ),
          ];
          final targets = {
            'emergencyFund:null': AllocationTarget(
              targetType: 'emergencyFund',
              targetName: 'EF',
              currentPaise: 0,
              targetPaise: 100000,
            ),
            'sinkingFund:sf1': AllocationTarget(
              targetType: 'sinkingFund',
              targetId: 'sf1',
              targetName: 'Vacation',
              currentPaise: 0,
              targetPaise: 50000,
            ),
            'investmentGoal:ig1': AllocationTarget(
              targetType: 'investmentGoal',
              targetId: 'ig1',
              targetName: 'Retirement',
              currentPaise: 0,
              targetPaise: 200000,
            ),
          };

          final advice = SavingsAllocationEngine.distribute(
            surplusPaise: 10000,
            rules: rules,
            targets: targets,
          );

          expect(advice.length, 3);
          expect(advice[0].allocatedPaise, 5000); // EF gets full 5000
          expect(advice[1].allocatedPaise, 3000); // SF gets full 3000
          expect(advice[2].allocatedPaise, 2000); // IG gets remaining 2000
        },
      );

      test(
        'fixed allocation: min(amountPaise, remainingSurplus, remainingToTarget)',
        () {
          final rules = [
            AllocationRule(
              priority: 1,
              targetType: 'emergencyFund',
              allocationType: 'fixed',
              amountPaise: 8000,
            ),
          ];
          final targets = {
            'emergencyFund:null': AllocationTarget(
              targetType: 'emergencyFund',
              targetName: 'EF',
              currentPaise: 95000,
              targetPaise: 100000,
            ),
          };

          final advice = SavingsAllocationEngine.distribute(
            surplusPaise: 20000,
            rules: rules,
            targets: targets,
          );

          // gap = 100000 - 95000 = 5000; min(8000, 20000, 5000) = 5000
          expect(advice[0].allocatedPaise, 5000);
          expect(advice[0].remainingToTarget, 0);
        },
      );

      test('percentage allocation: surplusPaise * percentageBp / 10000', () {
        final rules = [
          AllocationRule(
            priority: 1,
            targetType: 'sinkingFund',
            targetId: 'sf1',
            allocationType: 'percentage',
            percentageBp: 5000,
          ), // 50%
        ];
        final targets = {
          'sinkingFund:sf1': AllocationTarget(
            targetType: 'sinkingFund',
            targetId: 'sf1',
            targetName: 'Car',
            currentPaise: 0,
            targetPaise: 500000,
          ),
        };

        final advice = SavingsAllocationEngine.distribute(
          surplusPaise: 10000,
          rules: rules,
          targets: targets,
        );

        // 10000 * 5000 / 10000 = 5000
        expect(advice[0].allocatedPaise, 5000);
      });

      test('skips rule when target is already met', () {
        final rules = [
          AllocationRule(
            priority: 1,
            targetType: 'emergencyFund',
            allocationType: 'fixed',
            amountPaise: 5000,
          ),
          AllocationRule(
            priority: 2,
            targetType: 'sinkingFund',
            targetId: 'sf1',
            allocationType: 'fixed',
            amountPaise: 3000,
          ),
        ];
        final targets = {
          'emergencyFund:null': AllocationTarget(
            targetType: 'emergencyFund',
            targetName: 'EF',
            currentPaise: 100000,
            targetPaise: 100000,
          ),
          'sinkingFund:sf1': AllocationTarget(
            targetType: 'sinkingFund',
            targetId: 'sf1',
            targetName: 'Vacation',
            currentPaise: 0,
            targetPaise: 50000,
          ),
        };

        final advice = SavingsAllocationEngine.distribute(
          surplusPaise: 10000,
          rules: rules,
          targets: targets,
        );

        // EF is skipped (met), SF gets 3000
        expect(advice.length, 1);
        expect(advice[0].targetType, 'sinkingFund');
        expect(advice[0].allocatedPaise, 3000);
      });

      test('stops allocating when surplus is exhausted', () {
        final rules = [
          AllocationRule(
            priority: 1,
            targetType: 'emergencyFund',
            allocationType: 'fixed',
            amountPaise: 8000,
          ),
          AllocationRule(
            priority: 2,
            targetType: 'sinkingFund',
            targetId: 'sf1',
            allocationType: 'fixed',
            amountPaise: 5000,
          ),
        ];
        final targets = {
          'emergencyFund:null': AllocationTarget(
            targetType: 'emergencyFund',
            targetName: 'EF',
            currentPaise: 0,
            targetPaise: 100000,
          ),
          'sinkingFund:sf1': AllocationTarget(
            targetType: 'sinkingFund',
            targetId: 'sf1',
            targetName: 'Vacation',
            currentPaise: 0,
            targetPaise: 50000,
          ),
        };

        final advice = SavingsAllocationEngine.distribute(
          surplusPaise: 10000,
          rules: rules,
          targets: targets,
        );

        expect(advice[0].allocatedPaise, 8000); // EF gets 8000
        expect(advice[1].allocatedPaise, 2000); // SF gets remaining 2000
      });

      test(
        'opportunity fund with targetPaise=0 absorbs all remaining surplus',
        () {
          final rules = [
            AllocationRule(
              priority: 1,
              targetType: 'emergencyFund',
              allocationType: 'fixed',
              amountPaise: 3000,
            ),
            AllocationRule(
              priority: 2,
              targetType: 'opportunityFund',
              allocationType: 'fixed',
              amountPaise: 999999999,
            ),
          ];
          final targets = {
            'emergencyFund:null': AllocationTarget(
              targetType: 'emergencyFund',
              targetName: 'EF',
              currentPaise: 0,
              targetPaise: 100000,
            ),
            'opportunityFund:null': AllocationTarget(
              targetType: 'opportunityFund',
              targetName: 'Opp Fund',
              currentPaise: 0,
              targetPaise: 0,
            ),
          };

          final advice = SavingsAllocationEngine.distribute(
            surplusPaise: 10000,
            rules: rules,
            targets: targets,
          );

          expect(advice[0].allocatedPaise, 3000);
          expect(advice[1].allocatedPaise, 7000); // all remaining
          expect(advice[1].remainingToTarget, 0); // unlimited target -> 0
        },
      );

      test(
        'returns AllocationAdvice list with allocatedPaise and remainingToTarget',
        () {
          final rules = [
            AllocationRule(
              priority: 1,
              targetType: 'emergencyFund',
              allocationType: 'fixed',
              amountPaise: 3000,
            ),
          ];
          final targets = {
            'emergencyFund:null': AllocationTarget(
              targetType: 'emergencyFund',
              targetName: 'EF',
              currentPaise: 90000,
              targetPaise: 100000,
            ),
          };

          final advice = SavingsAllocationEngine.distribute(
            surplusPaise: 5000,
            rules: rules,
            targets: targets,
          );

          expect(advice[0].targetType, 'emergencyFund');
          expect(advice[0].targetName, 'EF');
          expect(advice[0].allocatedPaise, 3000);
          expect(
            advice[0].remainingToTarget,
            7000,
          ); // 10000 gap - 3000 allocated
        },
      );

      test('empty rules list returns empty advice list', () {
        final advice = SavingsAllocationEngine.distribute(
          surplusPaise: 10000,
          rules: [],
          targets: {},
        );

        expect(advice, isEmpty);
      });

      test(
        'all surplus consumed: sum of allocatedPaise equals original surplus',
        () {
          final rules = [
            AllocationRule(
              priority: 1,
              targetType: 'emergencyFund',
              allocationType: 'fixed',
              amountPaise: 6000,
            ),
            AllocationRule(
              priority: 2,
              targetType: 'sinkingFund',
              targetId: 'sf1',
              allocationType: 'fixed',
              amountPaise: 4000,
            ),
          ];
          final targets = {
            'emergencyFund:null': AllocationTarget(
              targetType: 'emergencyFund',
              targetName: 'EF',
              currentPaise: 0,
              targetPaise: 100000,
            ),
            'sinkingFund:sf1': AllocationTarget(
              targetType: 'sinkingFund',
              targetId: 'sf1',
              targetName: 'Trip',
              currentPaise: 0,
              targetPaise: 50000,
            ),
          };

          final advice = SavingsAllocationEngine.distribute(
            surplusPaise: 10000,
            rules: rules,
            targets: targets,
          );

          final totalAllocated = advice.fold<int>(
            0,
            (sum, a) => sum + a.allocatedPaise,
          );
          expect(totalAllocated, 10000);
        },
      );
    });
  });
}
