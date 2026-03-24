import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/financial/allocation_engine.dart';
import 'package:vael/core/financial/insights_engine.dart';
import 'package:vael/core/models/enums.dart';

void main() {
  group('InsightsEngine', () {
    // ── efBelowTarget ─────────────────────────────────────────────────

    group('efBelowTarget', () {
      test('returns null when coverage >= target', () {
        final result = InsightsEngine.efBelowTarget(
          coverageMonths: 6.0,
          targetMonths: 6,
        );
        expect(result, isNull);
      });

      test('returns null when coverage exceeds target', () {
        final result = InsightsEngine.efBelowTarget(
          coverageMonths: 8.0,
          targetMonths: 6,
        );
        expect(result, isNull);
      });

      test('returns critical when coverage < 50% of target', () {
        final result = InsightsEngine.efBelowTarget(
          coverageMonths: 1.0,
          targetMonths: 6,
        );
        expect(result, isNotNull);
        expect(result!.type, InsightType.efBelowTarget);
        expect(result.severity, InsightSeverity.critical);
        expect(result.title, 'Emergency fund below target');
        expect(result.description, contains('5.0 months short'));
      });

      test('returns warning when coverage >= 50% but < target', () {
        final result = InsightsEngine.efBelowTarget(
          coverageMonths: 4.0,
          targetMonths: 6,
        );
        expect(result, isNotNull);
        expect(result!.severity, InsightSeverity.warning);
        expect(result.description, contains('2.0 months short'));
      });
    });

    // ── allocationOffTarget ───────────────────────────────────────────

    group('allocationOffTarget', () {
      test('returns null when all classes within 500bp', () {
        final deltas = [
          const RebalancingDelta(
            assetClass: AssetClass.equity,
            actualBp: 7200,
            targetBp: 7500,
            deltaPaise: -300000,
            deltaDescription: 'underweight',
          ),
          const RebalancingDelta(
            assetClass: AssetClass.debt,
            actualBp: 2800,
            targetBp: 2500,
            deltaPaise: 300000,
            deltaDescription: 'overweight',
          ),
        ];
        final result = InsightsEngine.allocationOffTarget(deltas: deltas);
        expect(result, isNull);
      });

      test('returns warning when deviation > 500bp but <= 1500bp', () {
        final deltas = [
          const RebalancingDelta(
            assetClass: AssetClass.equity,
            actualBp: 8500,
            targetBp: 7500,
            deltaPaise: 1000000,
            deltaDescription: 'overweight',
          ),
        ];
        final result = InsightsEngine.allocationOffTarget(deltas: deltas);
        expect(result, isNotNull);
        expect(result!.severity, InsightSeverity.warning);
        expect(result.type, InsightType.allocationOffTarget);
        expect(result.title, 'Asset allocation off-target');
        expect(result.description, contains('equity'));
        expect(result.description, contains('10.0%'));
      });

      test('returns critical when deviation > 1500bp', () {
        final deltas = [
          const RebalancingDelta(
            assetClass: AssetClass.gold,
            actualBp: 3000,
            targetBp: 500,
            deltaPaise: 2500000,
            deltaDescription: 'overweight',
          ),
        ];
        final result = InsightsEngine.allocationOffTarget(deltas: deltas);
        expect(result, isNotNull);
        expect(result!.severity, InsightSeverity.critical);
        expect(result.description, contains('gold'));
      });

      test('returns null for empty deltas', () {
        final result = InsightsEngine.allocationOffTarget(deltas: []);
        expect(result, isNull);
      });
    });

    // ── fiDateSlipping ────────────────────────────────────────────────

    group('fiDateSlipping', () {
      test('returns null when current is null', () {
        final result = InsightsEngine.fiDateSlipping(
          currentYearsToFi: null,
          previousYearsToFi: 20,
        );
        expect(result, isNull);
      });

      test('returns null when previous is null', () {
        final result = InsightsEngine.fiDateSlipping(
          currentYearsToFi: 20,
          previousYearsToFi: null,
        );
        expect(result, isNull);
      });

      test('returns null when current <= previous', () {
        final result = InsightsEngine.fiDateSlipping(
          currentYearsToFi: 18,
          previousYearsToFi: 20,
        );
        expect(result, isNull);
      });

      test('returns null when current == previous', () {
        final result = InsightsEngine.fiDateSlipping(
          currentYearsToFi: 20,
          previousYearsToFi: 20,
        );
        expect(result, isNull);
      });

      test('returns warning when current > previous (1 year)', () {
        final result = InsightsEngine.fiDateSlipping(
          currentYearsToFi: 21,
          previousYearsToFi: 20,
        );
        expect(result, isNotNull);
        expect(result!.type, InsightType.fiDateSlipping);
        expect(result.severity, InsightSeverity.warning);
        expect(result.title, 'FI date slipping');
        expect(result.description, 'FI timeline extended by 1 year');
      });

      test('returns warning when current > previous (multiple years)', () {
        final result = InsightsEngine.fiDateSlipping(
          currentYearsToFi: 25,
          previousYearsToFi: 20,
        );
        expect(result, isNotNull);
        expect(result!.description, 'FI timeline extended by 5 years');
      });
    });

    // ── sinkingFundUnderfunded ────────────────────────────────────────

    group('sinkingFundUnderfunded', () {
      test('returns null when onTrack', () {
        final result = InsightsEngine.sinkingFundUnderfunded(
          paceStatus: 'onTrack',
          fundName: 'Vacation',
          monthlyNeededPaise: 500000,
          monthlyActualPaise: 600000,
        );
        expect(result, isNull);
      });

      test('returns warning when behind', () {
        final result = InsightsEngine.sinkingFundUnderfunded(
          paceStatus: 'behind',
          fundName: 'Vacation',
          monthlyNeededPaise: 500000,
          monthlyActualPaise: 300000,
        );
        expect(result, isNotNull);
        expect(result!.type, InsightType.sinkingFundUnderfunded);
        expect(result.severity, InsightSeverity.warning);
        expect(result.title, 'Vacation underfunded');
        expect(result.description, contains('5000'));
        expect(result.description, contains('3000'));
      });

      test('returns critical when atRisk', () {
        final result = InsightsEngine.sinkingFundUnderfunded(
          paceStatus: 'atRisk',
          fundName: 'Car Down Payment',
          monthlyNeededPaise: 1000000,
          monthlyActualPaise: 100000,
        );
        expect(result, isNotNull);
        expect(result!.severity, InsightSeverity.critical);
        expect(result.title, 'Car Down Payment underfunded');
      });
    });
  });
}
