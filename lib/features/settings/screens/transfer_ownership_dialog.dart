import 'package:flutter/material.dart';
import '../../../core/sync/manifest.dart';
import '../../../shared/theme/spacing.dart';

/// Dialog for selecting a member to transfer ownership to.
///
/// Returns the selected member's userId on confirm, null on cancel.
class TransferOwnershipDialog extends StatefulWidget {
  final List<MemberEntry> eligibleMembers;

  const TransferOwnershipDialog({super.key, required this.eligibleMembers});

  static Future<String?> show(
    BuildContext context,
    List<MemberEntry> eligibleMembers,
  ) {
    return showDialog<String>(
      context: context,
      builder: (_) => TransferOwnershipDialog(eligibleMembers: eligibleMembers),
    );
  }

  @override
  State<TransferOwnershipDialog> createState() =>
      _TransferOwnershipDialogState();
}

class _TransferOwnershipDialogState extends State<TransferOwnershipDialog> {
  String? _selectedUserId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Transfer Ownership'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select the member who will become the new family admin '
            'and take ownership of the backup folder.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: Spacing.md),
          ...widget.eligibleMembers.map(
            (m) => RadioListTile<String>(
              value: m.userId,
              groupValue: _selectedUserId,
              title: Text(m.email),
              subtitle: Text(m.role == 'admin' ? 'Admin' : 'Member'),
              onChanged: (v) => setState(() => _selectedUserId = v),
            ),
          ),
          const SizedBox(height: Spacing.md),
          Card(
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(Spacing.sm),
              child: Text(
                'This cannot be undone without the new admin\'s cooperation. '
                'The backup folder will move to their Google account.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selectedUserId != null
              ? () => Navigator.pop(context, _selectedUserId)
              : null,
          child: const Text('Transfer'),
        ),
      ],
    );
  }
}
