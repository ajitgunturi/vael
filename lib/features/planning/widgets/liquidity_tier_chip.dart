import 'package:flutter/material.dart';

/// Color-coded tier badge chip for emergency fund liquidity tiers.
class LiquidityTierChip extends StatelessWidget {
  const LiquidityTierChip({super.key, required this.tier, this.onTap});

  final String tier;
  final VoidCallback? onTap;

  static const _displayNames = {
    'instant': 'Instant',
    'shortTerm': 'Short-term',
    'longTerm': 'Long-term',
  };

  static final _colors = {
    'instant': Colors.green.shade100,
    'shortTerm': Colors.blue.shade100,
    'longTerm': Colors.orange.shade100,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(_displayNames[tier] ?? tier),
        backgroundColor: _colors[tier] ?? Colors.grey.shade100,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
