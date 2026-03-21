import 'package:flutter/material.dart';
import '../../../core/sync/manifest.dart';
import '../../../core/sync/sync_orchestrator.dart';
import '../../../shared/theme/spacing.dart';

/// Admin dashboard for family backup management.
///
/// Displays storage info, member list with sync status, backup controls.
/// Non-admin users see a read-only view with their own status.
class FamilyBackupScreen extends StatelessWidget {
  final ManifestStatus manifestStatus;
  final SyncStatus syncStatus;
  final String currentUserId;
  final VoidCallback onAddMember;
  final VoidCallback onTransferOwnership;
  final VoidCallback onCreateBackup;
  final void Function(MemberEntry member) onRemoveMember;

  const FamilyBackupScreen({
    super.key,
    required this.manifestStatus,
    required this.syncStatus,
    required this.currentUserId,
    required this.onAddMember,
    required this.onTransferOwnership,
    required this.onCreateBackup,
    required this.onRemoveMember,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family Backup')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          _StorageInfoCard(
            ownerEmail: manifestStatus.ownerEmail,
            fekGeneration: manifestStatus.fekGeneration,
          ),
          const SizedBox(height: Spacing.lg),
          _SectionHeader(title: 'Members (${manifestStatus.memberCount})'),
          const SizedBox(height: Spacing.sm),
          ...manifestStatus.members.map(
            (m) => _MemberTile(
              member: m,
              isCurrentUser: m.userId == currentUserId,
              isAdmin: manifestStatus.isAdmin,
              onRemove: manifestStatus.isAdmin && m.userId != currentUserId
                  ? () => onRemoveMember(m)
                  : null,
            ),
          ),
          if (manifestStatus.isAdmin) ...[
            const SizedBox(height: Spacing.lg),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onAddMember,
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add Member'),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onTransferOwnership,
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Transfer'),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: Spacing.xl),
          _SyncSummaryCard(syncStatus: syncStatus),
          const SizedBox(height: Spacing.md),
          OutlinedButton.icon(
            onPressed: onCreateBackup,
            icon: const Icon(Icons.backup),
            label: const Text('Create Backup Now'),
          ),
        ],
      ),
    );
  }
}

class _StorageInfoCard extends StatelessWidget {
  final String ownerEmail;
  final int fekGeneration;

  const _StorageInfoCard({
    required this.ownerEmail,
    required this.fekGeneration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.folder_shared, color: theme.colorScheme.primary),
                const SizedBox(width: Spacing.sm),
                Text('Storage', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            _InfoRow(label: 'Owner', value: ownerEmail),
            _InfoRow(
              label: 'Encryption',
              value: 'AES-256-GCM (gen $fekGeneration)',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final MemberEntry member;
  final bool isCurrentUser;
  final bool isAdmin;
  final VoidCallback? onRemove;

  const _MemberTile({
    required this.member,
    required this.isCurrentUser,
    required this.isAdmin,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRevoked = member.status == MemberStatus.revoked;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isRevoked
              ? theme.colorScheme.errorContainer
              : theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.person,
            color: isRevoked
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
          ),
        ),
        title: Row(
          children: [
            Flexible(child: Text(member.email)),
            if (isCurrentUser) ...[
              const SizedBox(width: Spacing.xs),
              Text(
                '(you)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          _subtitle,
          style: TextStyle(color: isRevoked ? theme.colorScheme.error : null),
        ),
        trailing: onRemove != null
            ? IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                color: theme.colorScheme.error,
                onPressed: onRemove,
              )
            : null,
      ),
    );
  }

  String get _subtitle {
    final rolePart = member.role == 'admin' ? 'Admin' : 'Member';
    final statusPart = member.status == MemberStatus.revoked
        ? 'Revoked'
        : member.status == MemberStatus.pendingSetup
        ? 'Pending'
        : member.lastSyncAt != null
        ? 'Last sync: ${_formatRelative(member.lastSyncAt!)}'
        : 'Never synced';
    return '$rolePart · $statusPart';
  }

  String _formatRelative(DateTime time) {
    final diff = DateTime.now().toUtc().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _SyncSummaryCard extends StatelessWidget {
  final SyncStatus syncStatus;

  const _SyncSummaryCard({required this.syncStatus});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sync, color: theme.colorScheme.primary),
                const SizedBox(width: Spacing.sm),
                Text('Sync Status', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            _InfoRow(
              label: 'Pending',
              value: syncStatus.pendingChanges == 0
                  ? 'Up to date'
                  : '${syncStatus.pendingChanges} changes',
            ),
            if (syncStatus.lastPushAt != null)
              _InfoRow(
                label: 'Last push',
                value: _format(syncStatus.lastPushAt!),
              ),
            if (syncStatus.lastPullAt != null)
              _InfoRow(
                label: 'Last pull',
                value: _format(syncStatus.lastPullAt!),
              ),
          ],
        ),
      ),
    );
  }

  String _format(DateTime time) {
    final local = time.toLocal();
    return '${local.day}/${local.month}/${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}
