import 'package:flutter/material.dart';
import '../../../core/sync/sync_orchestrator.dart';
import '../../../shared/theme/spacing.dart';

/// Displays sync engine status and manual sync controls.
class SyncStatusScreen extends StatelessWidget {
  final SyncStatus status;
  final VoidCallback onPushNow;
  final VoidCallback onPullNow;
  final VoidCallback onCreateBackup;

  const SyncStatusScreen({
    super.key,
    required this.status,
    required this.onPushNow,
    required this.onPullNow,
    required this.onCreateBackup,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Sync Status')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          _StatusCard(
            title: 'Device',
            value: status.deviceId,
            icon: Icons.devices,
          ),
          const SizedBox(height: Spacing.md),
          _StatusCard(
            title: 'Pending Changes',
            value: status.pendingChanges == 0
                ? 'Up to date'
                : '${status.pendingChanges} pending',
            icon: status.pendingChanges == 0 ? Icons.check_circle : Icons.sync,
            valueColor: status.pendingChanges == 0
                ? Colors.green
                : theme.colorScheme.primary,
          ),
          const SizedBox(height: Spacing.md),
          if (status.lastPushAt != null)
            _StatusCard(
              title: 'Last push',
              value: _formatTime(status.lastPushAt!),
              icon: Icons.cloud_upload,
            ),
          if (status.lastPullAt != null) ...[
            const SizedBox(height: Spacing.md),
            _StatusCard(
              title: 'Last pull',
              value: _formatTime(status.lastPullAt!),
              icon: Icons.cloud_download,
            ),
          ],
          const SizedBox(height: Spacing.xl),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: onPushNow,
                  child: const Text('Push Now'),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: onPullNow,
                  child: const Text('Pull Now'),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          OutlinedButton.icon(
            onPressed: onCreateBackup,
            icon: const Icon(Icons.backup),
            label: const Text('Create Backup'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final local = time.toLocal();
    return '${local.day}/${local.month}/${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _StatusCard({
    required this.title,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value, style: TextStyle(color: valueColor)),
      ),
    );
  }
}
