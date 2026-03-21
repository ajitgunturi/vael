import 'package:flutter/material.dart';
import '../../../core/sync/manifest.dart';
import '../../../shared/theme/spacing.dart';

/// Confirmation dialog for removing a family member.
///
/// Returns true if the user confirms, null/false on cancel.
class RemoveMemberDialog extends StatelessWidget {
  final MemberEntry member;

  const RemoveMemberDialog({super.key, required this.member});

  static Future<bool?> show(BuildContext context, MemberEntry member) {
    return showDialog<bool>(
      context: context,
      builder: (_) => RemoveMemberDialog(member: member),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Remove Member'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Remove ${member.email} from the family backup?'),
          const SizedBox(height: Spacing.md),
          Card(
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This will:',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  _BulletPoint(
                    text: 'Revoke their access to the backup folder',
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  _BulletPoint(
                    text: 'Generate a new encryption key (FEK rotation)',
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  _BulletPoint(
                    text: 'Their local data remains on their device',
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Remove'),
        ),
      ],
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  final Color color;

  const _BulletPoint({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('  \u2022  ', style: TextStyle(color: color)),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
