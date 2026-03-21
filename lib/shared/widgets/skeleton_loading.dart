import 'package:flutter/material.dart';

import '../theme/color_tokens.dart';
import '../theme/spacing.dart';

/// A shimmer placeholder box for skeleton loading states.
///
/// Per `UI_DESIGN.md` §1.5: 1500ms linear loop shimmer animation.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 4,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = ColorTokens.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                tokens.surfaceContainerHigh,
                tokens.surfaceContainerHighest,
                tokens.surfaceContainerHigh,
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A card-shaped skeleton placeholder.
///
/// Uses standard card dimensions with shimmer animation.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.height = 100});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: SkeletonBox(
        width: double.infinity,
        height: height,
        borderRadius: Spacing.cardRadius,
      ),
    );
  }
}
