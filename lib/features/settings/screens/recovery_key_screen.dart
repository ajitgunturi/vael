import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/crypto/recovery_key.dart';
import '../../../shared/theme/spacing.dart';

/// Displays a newly generated recovery key and asks the user to save it.
///
/// The recovery key can decrypt the FEK if the family passphrase is
/// forgotten. This screen is shown once during setup; the key is not
/// stored in the app after the user confirms.
class RecoveryKeyScreen extends StatefulWidget {
  /// Called when the user confirms they have saved the recovery key.
  /// Receives the generated recovery key string so the caller can
  /// encrypt the FEK with it before discarding.
  final void Function(String recoveryKey) onConfirmed;

  const RecoveryKeyScreen({super.key, required this.onConfirmed});

  @override
  State<RecoveryKeyScreen> createState() => _RecoveryKeyScreenState();
}

class _RecoveryKeyScreenState extends State<RecoveryKeyScreen> {
  late final String _recoveryKey;

  @override
  void initState() {
    super.initState();
    _recoveryKey = RecoveryKeyService.generate();
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _recoveryKey));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recovery key copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Recovery Key')),
      body: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.key_outlined,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              'Save your recovery key',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              'If you forget your family passphrase, this key is the only '
              'way to recover your encrypted data. Write it down and store '
              'it somewhere safe.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.xl),
            Container(
              padding: const EdgeInsets.all(Spacing.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(Spacing.cardRadius),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: SelectableText(
                _recoveryKey,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontFamily: 'monospace',
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: Spacing.md),
            OutlinedButton.icon(
              onPressed: _copyToClipboard,
              icon: const Icon(Icons.copy),
              label: const Text('Copy to clipboard'),
            ),
            const SizedBox(height: Spacing.xl),
            Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(Spacing.md),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Text(
                        'This key will not be shown again. If you lose it '
                        'and forget your passphrase, your data cannot be '
                        'recovered.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => widget.onConfirmed(_recoveryKey),
              child: const Text("I've saved this key"),
            ),
          ],
        ),
      ),
    );
  }
}
