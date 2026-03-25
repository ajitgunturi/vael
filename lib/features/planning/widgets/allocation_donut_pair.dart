import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/financial/allocation_engine.dart';
import '../../../core/models/enums.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/theme/spacing.dart';

/// Side-by-side donut charts showing current vs target allocation.
///
/// Each chart is 140x140dp with 28dp ring width, 48dp center space radius.
/// Center text shows a label ("Current" / "Target") and the dominant
/// asset class percentage in headlineMedium.
class AllocationDonutPair extends StatefulWidget {
  const AllocationDonutPair({
    super.key,
    required this.currentAllocation,
    required this.targetAllocation,
  });

  /// Current allocation in paise per asset class.
  final Map<AssetClass, int> currentAllocation;

  /// Target allocation from glide path.
  final AllocationTarget targetAllocation;

  @override
  State<AllocationDonutPair> createState() => _AllocationDonutPairState();
}

class _AllocationDonutPairState extends State<AllocationDonutPair> {
  int _touchedCurrentIndex = -1;
  int _touchedTargetIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 600;
    final currentBpMap = _currentToBpMap();
    final targetBpMap = _targetToBpMap();

    final currentChart = _DonutChart(
      label: 'Current',
      bpMap: currentBpMap,
      touchedIndex: _touchedCurrentIndex,
      onTouched: (i) => setState(() => _touchedCurrentIndex = i),
      valuePaiseMap: widget.currentAllocation,
    );
    final targetChart = _DonutChart(
      label: 'Target',
      bpMap: targetBpMap,
      touchedIndex: _touchedTargetIndex,
      onTouched: (i) => setState(() => _touchedTargetIndex = i),
    );

    if (isCompact) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          currentChart,
          const SizedBox(height: Spacing.md),
          targetChart,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: currentChart),
        const SizedBox(width: Spacing.md),
        Expanded(child: targetChart),
      ],
    );
  }

  Map<AssetClass, int> _currentToBpMap() {
    final total = widget.currentAllocation.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) return {};
    return {
      for (final ac in AssetClass.values)
        ac: ((widget.currentAllocation[ac] ?? 0) * 10000 / total).round(),
    };
  }

  Map<AssetClass, int> _targetToBpMap() {
    return {
      AssetClass.equity: widget.targetAllocation.equityBp,
      AssetClass.debt: widget.targetAllocation.debtBp,
      AssetClass.gold: widget.targetAllocation.goldBp,
      AssetClass.cash: widget.targetAllocation.cashBp,
    };
  }
}

class _DonutChart extends StatelessWidget {
  const _DonutChart({
    required this.label,
    required this.bpMap,
    required this.touchedIndex,
    required this.onTouched,
    this.valuePaiseMap,
  });

  final String label;
  final Map<AssetClass, int> bpMap;
  final int touchedIndex;
  final ValueChanged<int> onTouched;
  final Map<AssetClass, int>? valuePaiseMap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = ColorTokens.of(context);

    // Find dominant asset class for center display.
    final dominantEntry = bpMap.entries.isEmpty
        ? null
        : bpMap.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final dominantPct = dominantEntry != null
        ? '${(dominantEntry.value / 100).toStringAsFixed(0)}%'
        : '0%';

    final acColors = _assetClassColors(colors);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  if (!event.isInterestedForInteractions ||
                      response == null ||
                      response.touchedSection == null) {
                    onTouched(-1);
                    return;
                  }
                  onTouched(response.touchedSection!.touchedSectionIndex);
                },
              ),
              sectionsSpace: 2,
              centerSpaceRadius: 48,
              sections: _buildSections(acColors, theme),
              startDegreeOffset: -90,
            ),
            duration: const Duration(milliseconds: 300),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        // Center-style label below the chart
        Text(label, style: theme.textTheme.bodyMedium),
        Text(
          dominantPct,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: Spacing.sm),
        // Legend
        ...AssetClass.values.map((ac) => _legendRow(ac, acColors[ac]!, theme)),
      ],
    );
  }

  List<PieChartSectionData> _buildSections(
    Map<AssetClass, Color> acColors,
    ThemeData theme,
  ) {
    final entries = AssetClass.values.toList();
    return List.generate(entries.length, (i) {
      final ac = entries[i];
      final bp = bpMap[ac] ?? 0;
      if (bp == 0) {
        return PieChartSectionData(
          value: 0,
          showTitle: false,
          radius: 0,
          color: Colors.transparent,
        );
      }
      final isTouched = i == touchedIndex;
      final pct = (bp / 100).toStringAsFixed(0);

      // Build semantics text
      final amount = valuePaiseMap != null
          ? ', Rs ${_formatCompact(valuePaiseMap![ac] ?? 0)}'
          : '';

      return PieChartSectionData(
        value: bp.toDouble(),
        color: acColors[ac],
        radius: isTouched ? 32 : 28,
        showTitle: false,
        badgeWidget: Semantics(
          label: '${ac.name}: $pct% of portfolio$amount',
          child: const SizedBox.shrink(),
        ),
      );
    });
  }

  Widget _legendRow(AssetClass ac, Color color, ThemeData theme) {
    final bp = bpMap[ac] ?? 0;
    final pct = '${(bp / 100).toStringAsFixed(0)}%';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: Spacing.sm),
          Text(_displayName(ac), style: theme.textTheme.bodyMedium),
          const SizedBox(width: Spacing.xs),
          Text(pct, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  static Map<AssetClass, Color> _assetClassColors(ColorTokens colors) => {
    AssetClass.equity: colors.chartLine1,
    AssetClass.debt: colors.chartLine3,
    AssetClass.gold: colors.warning,
    AssetClass.cash: colors.neutral,
  };

  static String _displayName(AssetClass ac) => switch (ac) {
    AssetClass.equity => 'Equity',
    AssetClass.debt => 'Debt',
    AssetClass.gold => 'Gold',
    AssetClass.cash => 'Cash',
  };

  static String _formatCompact(int paise) {
    final rupees = paise / 100;
    if (rupees >= 10000000) {
      return '${(rupees / 10000000).toStringAsFixed(1)} Cr';
    } else if (rupees >= 100000) {
      return '${(rupees / 100000).toStringAsFixed(1)} L';
    }
    return rupees.toStringAsFixed(0);
  }
}
