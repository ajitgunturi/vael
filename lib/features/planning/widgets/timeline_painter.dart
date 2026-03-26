import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../providers/timeline_provider.dart';

/// Position of a painted timeline node for hit-testing.
class NodePosition {
  final Offset center;
  final TimelineNode node;
  const NodePosition({required this.center, required this.node});
}

/// CustomPainter that renders a horizontal decade-based lifetime timeline.
///
/// Draws decade columns, a horizontal axis, colored nodes (circles for
/// milestones/purchases, diamond for FI date), and a "Now" marker.
class TimelinePainter extends CustomPainter {
  TimelinePainter({
    required this.nodes,
    required this.currentAge,
    required this.brightness,
    required this.textColor,
  });

  final List<TimelineNode> nodes;
  final int? currentAge;
  final Brightness brightness;
  final Color textColor;

  /// Stored node positions for external hit-testing.
  final List<NodePosition> nodePositions = [];

  static const _topPad = 24.0;
  static const _bottomPad = 40.0;
  static const _leftPad = 16.0;
  static const _rightPad = 16.0;
  static const _nodeRadius = 10.0;

  /// Compute the age range for the timeline.
  static ({int minDecade, int maxDecade}) decadeRange(
    List<TimelineNode> nodes,
    int? currentAge,
  ) {
    int minAge = currentAge ?? 20;
    int maxAge = currentAge ?? 60;
    for (final n in nodes) {
      if (n.age < minAge) minAge = n.age;
      if (n.age > maxAge) maxAge = n.age;
    }
    final minDecade = (minAge ~/ 10) * 10;
    final maxDecade = ((maxAge ~/ 10) + 1) * 10;
    return (minDecade: math.max(minDecade, 10), maxDecade: maxDecade);
  }

  @override
  void paint(Canvas canvas, Size size) {
    nodePositions.clear();

    const chartLeft = _leftPad;
    final chartRight = size.width - _rightPad;
    final chartWidth = chartRight - chartLeft;
    final axisY = size.height / 2;

    final range = decadeRange(nodes, currentAge);
    final totalYears = (range.maxDecade - range.minDecade).toDouble();
    if (totalYears <= 0) return;

    double xForAge(int age) {
      return chartLeft + ((age - range.minDecade) / totalYears) * chartWidth;
    }

    // -- Decade separator lines and labels --
    final gridPaint = Paint()
      ..color = textColor.withValues(alpha: 0.15)
      ..strokeWidth = 1;

    for (
      var decade = range.minDecade;
      decade <= range.maxDecade;
      decade += 10
    ) {
      final x = xForAge(decade);
      canvas.drawLine(
        Offset(x, _topPad),
        Offset(x, size.height - _bottomPad),
        gridPaint,
      );
      _drawText(
        canvas,
        '${decade}s',
        Offset(x, _topPad - 4),
        TextStyle(fontSize: 10, color: textColor.withValues(alpha: 0.6)),
        align: TextAlign.center,
      );
    }

    // -- Horizontal axis line --
    final axisPaint = Paint()
      ..color = textColor.withValues(alpha: 0.3)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(chartLeft, axisY),
      Offset(chartRight, axisY),
      axisPaint,
    );

    // -- Current age "Now" marker --
    if (currentAge != null) {
      final nowX = xForAge(currentAge!);
      final dashPaint = Paint()
        ..color = textColor.withValues(alpha: 0.5)
        ..strokeWidth = 1;
      _drawDashedLine(
        canvas,
        Offset(nowX, _topPad),
        Offset(nowX, size.height - _bottomPad),
        dashPaint,
      );
      _drawText(
        canvas,
        'Now ($currentAge)',
        Offset(nowX, size.height - _bottomPad + 8),
        TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
        align: TextAlign.center,
      );
    }

    // -- Nodes --
    for (final node in nodes) {
      final x = xForAge(node.age);
      final center = Offset(x, axisY);
      final color = _colorForStatus(node.statusColor);

      if (node.type == TimelineNodeType.fiDate) {
        // Diamond shape for FI date
        _drawDiamond(canvas, center, _nodeRadius, color);
      } else {
        // Circle for milestones and purchases
        canvas.drawCircle(center, _nodeRadius, Paint()..color = color);
      }

      // Label below node
      _drawText(
        canvas,
        node.label,
        Offset(x, axisY + _nodeRadius + 6),
        TextStyle(fontSize: 9, color: textColor),
        align: TextAlign.center,
      );

      nodePositions.add(NodePosition(center: center, node: node));
    }
  }

  void _drawDiamond(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx + radius, center.dy)
      ..lineTo(center.dx, center.dy + radius)
      ..lineTo(center.dx - radius, center.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  Color _colorForStatus(TimelineNodeStatus status) {
    switch (status) {
      case TimelineNodeStatus.onTrack:
        return const Color(0xFF4CAF50);
      case TimelineNodeStatus.atRisk:
        return const Color(0xFFFFC107);
      case TimelineNodeStatus.behind:
        return const Color(0xFFF44336);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLen = 4.0;
    const gapLen = 3.0;
    final dy = end.dy - start.dy;
    final totalLen = dy.abs();
    var drawn = 0.0;
    var y = start.dy;
    while (drawn < totalLen) {
      final segEnd = math.min(y + dashLen, end.dy);
      canvas.drawLine(Offset(start.dx, y), Offset(start.dx, segEnd), paint);
      y = segEnd + gapLen;
      drawn += dashLen + gapLen;
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position,
    TextStyle style, {
    TextAlign align = TextAlign.left,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 60);

    final dx = align == TextAlign.center
        ? position.dx - tp.width / 2
        : align == TextAlign.right
        ? position.dx - tp.width
        : position.dx;

    tp.paint(canvas, Offset(dx, position.dy));
  }

  @override
  bool shouldRepaint(TimelinePainter oldDelegate) {
    return oldDelegate.nodes != nodes ||
        oldDelegate.currentAge != currentAge ||
        oldDelegate.brightness != brightness;
  }

  /// Find the node at [position] within [hitRadius] pixels.
  TimelineNode? hitTestNode(Offset position, {double hitRadius = 20.0}) {
    for (final np in nodePositions) {
      if ((np.center - position).distance <= hitRadius) {
        return np.node;
      }
    }
    return null;
  }
}
