import 'package:flutter/material.dart';

import '../../../core/financial/allocation_engine.dart';

/// Placeholder for GlidePathTable widget. Full implementation in Task 2.
class GlidePathTable extends StatefulWidget {
  const GlidePathTable({
    super.key,
    required this.initialTargets,
    required this.currentUserAge,
    required this.onChanged,
  });

  final List<AllocationTargetOverride> initialTargets;
  final int currentUserAge;
  final ValueChanged<List<AllocationTargetOverride>> onChanged;

  @override
  State<GlidePathTable> createState() => _GlidePathTableState();
}

class _GlidePathTableState extends State<GlidePathTable> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
