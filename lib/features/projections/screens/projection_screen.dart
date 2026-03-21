import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/financial/projection_engine.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/utils/formatters.dart';

/// 60-month financial projection with 3 scenarios.
class ProjectionScreen extends ConsumerStatefulWidget {
  const ProjectionScreen({super.key, required this.familyId});

  final String familyId;

  @override
  ConsumerState<ProjectionScreen> createState() => _ProjectionScreenState();
}

class _ProjectionScreenState extends ConsumerState<ProjectionScreen> {
  ThreeScenarioResult? _scenarios;

  // Editable parameters
  int _monthlyIncome = 15000000; // ₹1.5L default
  int _monthlyExpenses = 10000000; // ₹1L default
  int _startingNetWorth = 0;
  double _returnRate = 0.10;

  @override
  void initState() {
    super.initState();
    _recompute();
  }

  void _recompute() {
    setState(() {
      _scenarios = ProjectionEngine.threeScenarios(
        startingNetWorth: _startingNetWorth,
        monthlyIncome: _monthlyIncome,
        monthlyExpenses: _monthlyExpenses,
        baseReturnRate: _returnRate,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('60-Month Projection')),
      body: _scenarios == null
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final s = _scenarios!;
    final baseEnd = s.base.months.last;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SummaryCard(
          optimisticEnd: s.optimistic.months.last.netWorth,
          baseEnd: baseEnd.netWorth,
          pessimisticEnd: s.pessimistic.months.last.netWorth,
        ),
        const SizedBox(height: 16),
        SizedBox(height: 250, child: _ProjectionChart(scenarios: s)),
        const SizedBox(height: 24),
        Text('Assumptions', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        _ParameterSlider(
          label: 'Monthly Income',
          value: _monthlyIncome,
          min: 0,
          max: 50000000,
          formatValue: (v) => '₹${formatIndianNumber(v ~/ 100)}',
          onChanged: (v) {
            _monthlyIncome = v;
            _recompute();
          },
        ),
        _ParameterSlider(
          label: 'Monthly Expenses',
          value: _monthlyExpenses,
          min: 0,
          max: 50000000,
          formatValue: (v) => '₹${formatIndianNumber(v ~/ 100)}',
          onChanged: (v) {
            _monthlyExpenses = v;
            _recompute();
          },
        ),
        _ParameterSlider(
          label: 'Expected Return',
          value: (_returnRate * 100).round(),
          min: 0,
          max: 20,
          formatValue: (v) => '$v%',
          onChanged: (v) {
            _returnRate = v / 100;
            _recompute();
          },
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.optimisticEnd,
    required this.baseEnd,
    required this.pessimisticEnd,
  });

  final int optimisticEnd;
  final int baseEnd;
  final int pessimisticEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Net Worth in 5 Years', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Builder(
              builder: (ctx) {
                final colors = ColorTokens.of(ctx);
                return Column(
                  children: [
                    _ScenarioRow(
                      label: 'Optimistic',
                      value: optimisticEnd,
                      color: colors.income,
                    ),
                    const SizedBox(height: 8),
                    _ScenarioRow(
                      label: 'Base',
                      value: baseEnd,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    _ScenarioRow(
                      label: 'Pessimistic',
                      value: pessimisticEnd,
                      color: colors.expense,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ScenarioRow extends StatelessWidget {
  const _ScenarioRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
        Text(
          '₹${formatIndianNumber(value ~/ 100)}',
          style: TextStyle(fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}

class _ProjectionChart extends StatelessWidget {
  const _ProjectionChart({required this.scenarios});

  final ThreeScenarioResult scenarios;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    List<FlSpot> toSpots(ProjectionResult r) {
      return r.months
          .map((m) => FlSpot(m.month.toDouble(), m.netWorth / 100))
          .toList();
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 12,
              getTitlesWidget: (v, _) {
                final year = (v / 12).ceil();
                return Text('Y$year', style: theme.textTheme.labelSmall);
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: toSpots(scenarios.optimistic),
            color: ColorTokens.of(context).income.withValues(alpha: 0.5),
            dotData: const FlDotData(show: false),
            barWidth: 1.5,
          ),
          LineChartBarData(
            spots: toSpots(scenarios.base),
            color: theme.colorScheme.primary,
            dotData: const FlDotData(show: false),
            barWidth: 2.5,
          ),
          LineChartBarData(
            spots: toSpots(scenarios.pessimistic),
            color: ColorTokens.of(context).expense.withValues(alpha: 0.5),
            dotData: const FlDotData(show: false),
            barWidth: 1.5,
          ),
        ],
      ),
    );
  }
}

class _ParameterSlider extends StatelessWidget {
  const _ParameterSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.formatValue,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final String Function(int) formatValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: 100,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              formatValue(value),
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
