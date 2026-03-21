import 'package:flutter/material.dart';
import '../../../shared/theme/spacing.dart';

/// First-device passphrase setup screen.
///
/// Collects and validates a family passphrase (≥8 chars, confirmed).
/// Calls [onSetup] with the validated passphrase.
class PassphraseSetupScreen extends StatefulWidget {
  final void Function(String passphrase) onSetup;

  const PassphraseSetupScreen({super.key, required this.onSetup});

  @override
  State<PassphraseSetupScreen> createState() => _PassphraseSetupScreenState();
}

class _PassphraseSetupScreenState extends State<PassphraseSetupScreen> {
  final _passphraseController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _passphraseController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    final passphrase = _passphraseController.text;
    final confirm = _confirmController.text;

    if (passphrase.length < 8) {
      setState(() => _error = 'Passphrase must be at least 8 characters');
      return;
    }
    if (passphrase != confirm) {
      setState(() => _error = 'Passphrases do not match');
      return;
    }

    setState(() => _error = null);
    widget.onSetup(passphrase);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Family Passphrase')),
      body: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'This passphrase encrypts all family data. '
              'Share it with family members verbally — it is never stored.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: Spacing.lg),
            TextField(
              controller: _passphraseController,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Passphrase',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: Spacing.md),
            TextField(
              controller: _confirmController,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Confirm passphrase',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: Spacing.sm),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: Spacing.xl),
            FilledButton(onPressed: _submit, child: const Text('Continue')),
          ],
        ),
      ),
    );
  }
}
