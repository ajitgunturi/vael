import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Editor screen for customizing allocation targets per age band.
///
/// Shows a table of 6 age bands with editable equity/debt/gold/cash
/// percentages, row-sum validation, save and reset-to-defaults.
class GlidePathEditorScreen extends ConsumerStatefulWidget {
  const GlidePathEditorScreen({
    super.key,
    required this.lifeProfileId,
    required this.riskProfile,
    required this.userAge,
  });

  final String lifeProfileId;
  final String riskProfile;
  final int userAge;

  @override
  ConsumerState<GlidePathEditorScreen> createState() =>
      _GlidePathEditorScreenState();
}

class _GlidePathEditorScreenState extends ConsumerState<GlidePathEditorScreen> {
  // Placeholder -- full implementation in Task 2.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Allocation Targets'),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Reset to Defaults')),
        ],
      ),
      body: const Center(child: Text('Glide path editor')),
    );
  }
}
