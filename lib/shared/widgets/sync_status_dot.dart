import 'package:flutter/material.dart';

/// Visual states for the sync status indicator.
enum SyncDotState { synced, pending, error }

/// A small colored dot indicating sync status.
///
/// - [SyncDotState.synced] — green
/// - [SyncDotState.pending] — amber
/// - [SyncDotState.error] — red
///
/// Wiring to real sync state is handled separately; this widget
/// only renders the visual indicator.
class SyncStatusDot extends StatelessWidget {
  const SyncStatusDot({super.key, required this.state});

  final SyncDotState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _colorFor(state),
      ),
    );
  }

  static Color _colorFor(SyncDotState state) {
    switch (state) {
      case SyncDotState.synced:
        return const Color(0xFF4CAF50);
      case SyncDotState.pending:
        return const Color(0xFFFFC107);
      case SyncDotState.error:
        return const Color(0xFFF44336);
    }
  }
}
