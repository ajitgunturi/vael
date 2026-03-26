import 'package:flutter/material.dart';

/// Tappable shield badge chip indicating an account is linked to the
/// Emergency Fund. Used on account detail headers and contextual surfaces.
class EfBadge extends StatelessWidget {
  const EfBadge({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(
        Icons.shield_outlined,
        size: 16,
        color: Colors.green.shade700,
      ),
      label: Text(
        'Emergency Fund',
        style: TextStyle(fontSize: 12, color: Colors.green.shade700),
      ),
      backgroundColor: Colors.green.shade50,
      side: BorderSide(color: Colors.green.shade200),
      onPressed: onTap,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
