import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/database/database.dart';

/// Displays a 12-month savings rate trend line chart with health band backgrounds.
///
/// Background bands: red (0-10%), amber (10-20%), green (20%+).
/// Each data point is color-coded by its health band.
/// Tap a month to get its [MonthlyMetric] via [onMonthTap].
class SavingsRateTrendChart extends StatefulWidget {
  const SavingsRateTrendChart({
    super.key,
    required this.metrics,
    this.onMonthTap,
  });

  /// Up to 12 monthly metrics, sorted by month ascending.
  final List<MonthlyMetric> metrics;

  /// Called when user taps near a data point.
  final ValueChanged<MonthlyMetric>? onMonthTap;

  @override
  State<SavingsRateTrendChart> createState() => _SavingsRateTrendChartState();
}

class _SavingsRateTrendChartState extends State<SavingsRateTrendChart> {
  @override
  Widget build(BuildContext context) {
    if (widget.metrics.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No data available')),
      );
    }

    return GestureDetector(
      onTapDown: (details) => _handleTap(details.localPosition),
      child: CustomPaint(
        size: const Size(double.infinity, 200),
        painter: SavingsRateTrendPainter(
          metrics: widget.metrics,
          brightness: Theme.of(context).brightness,
        ),
      ),
    );
  }

  void _handleTap(Offset position) {
    if (widget.metrics.isEmpty || widget.onMonthTap == null) return;

    const leftPad = 40.0;
    const rightPad = 16.0;

    // Estimate chart width from context
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final totalWidth = renderBox.size.width;
    final chartWidth = totalWidth - leftPad - rightPad;

    if (widget.metrics.length == 1) {
      widget.onMonthTap!(widget.metrics.first);
      return;
    }

    final stepX = chartWidth / (widget.metrics.length - 1);
    final tapX = position.dx - leftPad;

    // Find nearest data point
    var nearestIndex = 0;
    var nearestDist = double.infinity;
    for (var i = 0; i < widget.metrics.length; i++) {
      final pointX = i * stepX;
      final dist = (tapX - pointX).abs();
      if (dist < nearestDist) {
        nearestDist = dist;
        nearestIndex = i;
      }
    }

    widget.onMonthTap!(widget.metrics[nearestIndex]);
  }
}

/// Custom painter for the savings rate trend line chart.
///
/// Draws horizontal health bands, threshold lines, data points, and axis labels.
class SavingsRateTrendPainter extends CustomPainter {
  SavingsRateTrendPainter({required this.metrics, required this.brightness});

  final List<MonthlyMetric> metrics;
  final Brightness brightness;

  static const _leftPad = 40.0;
  static const _rightPad = 16.0;
  static const _topPad = 8.0;
  static const _bottomPad = 24.0;

  static const _monthAbbr = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (metrics.isEmpty) return;

    const chartLeft = _leftPad;
    final chartRight = size.width - _rightPad;
    const chartTop = _topPad;
    final chartBottom = size.height - _bottomPad;
    final chartWidth = chartRight - chartLeft;
    final chartHeight = chartBottom - chartTop;

    // Compute Y range
    final maxRate = metrics.fold<double>(
      0,
      (max, m) => math.max(max, m.savingsRateBp / 100.0),
    );
    final yMax = math.max(40.0, maxRate + 5.0);

    double yForRate(double rate) {
      return chartBottom - (rate / yMax) * chartHeight;
    }

    // -- Background bands --
    final redBand = Rect.fromLTRB(
      chartLeft,
      yForRate(10),
      chartRight,
      yForRate(0),
    );
    final amberBand = Rect.fromLTRB(
      chartLeft,
      yForRate(20),
      chartRight,
      yForRate(10),
    );
    final greenBand = Rect.fromLTRB(
      chartLeft,
      yForRate(yMax),
      chartRight,
      yForRate(20),
    );

    canvas.drawRect(
      redBand,
      Paint()..color = Colors.red.withValues(alpha: 0.08),
    );
    canvas.drawRect(
      amberBand,
      Paint()..color = Colors.amber.withValues(alpha: 0.08),
    );
    canvas.drawRect(
      greenBand,
      Paint()..color = Colors.green.withValues(alpha: 0.08),
    );

    // -- Dashed threshold lines at 10% and 20% --
    final dashPaint = Paint()
      ..color = (brightness == Brightness.dark
          ? Colors.white38
          : Colors.black26)
      ..strokeWidth = 1;

    _drawDashedLine(
      canvas,
      Offset(chartLeft, yForRate(10)),
      Offset(chartRight, yForRate(10)),
      dashPaint,
    );
    _drawDashedLine(
      canvas,
      Offset(chartLeft, yForRate(20)),
      Offset(chartRight, yForRate(20)),
      dashPaint,
    );

    // -- Y-axis labels --
    final textColor = brightness == Brightness.dark
        ? Colors.white70
        : Colors.black54;
    final labelStyle = TextStyle(fontSize: 10, color: textColor);

    for (final pct in [0, 10, 20, 30, 40]) {
      if (pct > yMax) break;
      _drawText(
        canvas,
        '$pct%',
        Offset(chartLeft - 4, yForRate(pct.toDouble())),
        labelStyle,
        align: TextAlign.right,
        width: 34,
      );
    }

    // -- Data points and line --
    final points = <Offset>[];
    final stepX = metrics.length > 1 ? chartWidth / (metrics.length - 1) : 0.0;

    for (var i = 0; i < metrics.length; i++) {
      final rate = metrics[i].savingsRateBp / 100.0;
      final x = metrics.length == 1
          ? chartLeft + chartWidth / 2
          : chartLeft + i * stepX;
      final y = yForRate(rate);
      points.add(Offset(x, y));
    }

    // Line segments
    if (points.length > 1) {
      final linePaint = Paint()
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      for (var i = 0; i < points.length - 1; i++) {
        final rate = metrics[i].savingsRateBp / 100.0;
        linePaint.color = _colorForRate(rate);
        canvas.drawLine(points[i], points[i + 1], linePaint);
      }
    }

    // Data point circles
    for (var i = 0; i < points.length; i++) {
      final rate = metrics[i].savingsRateBp / 100.0;
      final color = _colorForRate(rate);
      canvas.drawCircle(points[i], 4, Paint()..color = color);
    }

    // -- X-axis labels (month abbreviations) --
    for (var i = 0; i < metrics.length; i++) {
      final month = metrics[i].month;
      final parts = month.split('-');
      final monIndex = int.parse(parts[1]) - 1;
      final label = _monthAbbr[monIndex.clamp(0, 11)];

      _drawText(
        canvas,
        label,
        Offset(points[i].dx, chartBottom + 4),
        labelStyle,
        align: TextAlign.center,
        width: 30,
      );
    }
  }

  Color _colorForRate(double rate) {
    if (rate >= 20) return Colors.green;
    if (rate >= 10) return Colors.amber.shade700;
    return Colors.red;
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLen = 4.0;
    const gapLen = 3.0;
    final dx = end.dx - start.dx;
    final totalLen = dx.abs();
    var drawn = 0.0;
    var x = start.dx;
    while (drawn < totalLen) {
      final segEnd = math.min(x + dashLen, end.dx);
      canvas.drawLine(Offset(x, start.dy), Offset(segEnd, start.dy), paint);
      x = segEnd + gapLen;
      drawn += dashLen + gapLen;
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position,
    TextStyle style, {
    TextAlign align = TextAlign.left,
    double width = 40,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width);

    final dx = align == TextAlign.right
        ? position.dx - tp.width
        : align == TextAlign.center
        ? position.dx - tp.width / 2
        : position.dx;

    tp.paint(canvas, Offset(dx, position.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(SavingsRateTrendPainter oldDelegate) {
    return oldDelegate.metrics != metrics ||
        oldDelegate.brightness != brightness;
  }
}
