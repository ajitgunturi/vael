import 'package:flutter/material.dart';

/// Circular progress widget showing emergency fund coverage.
///
/// Displays `X.X/Ymo` text in the center with color-coded ring:
/// green (>= 90%), amber (>= 50%), red (< 50%).
class EfProgressRing extends StatelessWidget {
  const EfProgressRing({
    super.key,
    required this.coverageMonths,
    required this.targetMonths,
  });

  final double coverageMonths;
  final int targetMonths;

  @override
  Widget build(BuildContext context) {
    final ratio = targetMonths > 0
        ? (coverageMonths / targetMonths).clamp(0.0, 1.0)
        : 0.0;
    final color = ratio >= 0.9
        ? Colors.green
        : ratio >= 0.5
        ? Colors.amber
        : Colors.red;

    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: ratio,
              strokeWidth: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          Text(
            '${coverageMonths.toStringAsFixed(1)}/${targetMonths}mo',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
