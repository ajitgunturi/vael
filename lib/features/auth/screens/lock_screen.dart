import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/crypto/key_derivation.dart';
import '../../../shared/theme/spacing.dart';

/// Storage keys matching the passphrase setup flow.
const _passphraseHashKey = 'vael_passphrase_hash';
const _passphraseSaltKey = 'vael_passphrase_salt';

/// Lock screen shown when the app resumes with an active session.
///
/// Prompts for the family passphrase and verifies it against the
/// stored PBKDF2 hash. Calls [onUnlocked] on success.
class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;

  const LockScreen({super.key, required this.onUnlocked});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _controller = TextEditingController();
  bool _obscure = true;
  bool _verifying = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    final passphrase = _controller.text;
    if (passphrase.isEmpty) {
      setState(() => _error = 'Enter your passphrase');
      return;
    }

    setState(() {
      _verifying = true;
      _error = null;
    });

    try {
      final verified = await _verifyPassphrase(passphrase);
      if (!mounted) return;

      if (verified) {
        widget.onUnlocked();
      } else {
        setState(() {
          _error = 'Incorrect passphrase';
          _verifying = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Verification failed. Try again.';
        _verifying = false;
      });
    }
  }

  /// Verifies [passphrase] against the stored PBKDF2 hash + salt.
  Future<bool> _verifyPassphrase(String passphrase) async {
    const storage = FlutterSecureStorage();
    final storedHash = await storage.read(key: _passphraseHashKey);
    final storedSalt = await storage.read(key: _passphraseSaltKey);

    if (storedHash == null || storedSalt == null) {
      // No passphrase was set — shouldn't reach here, but allow through.
      return true;
    }

    final salt = base64Decode(storedSalt);
    final derivation = KeyDerivation();
    final derived = derivation.deriveKey(passphrase, salt);
    final derivedHash = base64Encode(derived);

    return derivedHash == storedHash;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: Spacing.lg),
              Text(
                'Vael is locked',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                'Enter your family passphrase to unlock.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.xl),
              TextField(
                controller: _controller,
                obscureText: _obscure,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _unlock(),
                decoration: InputDecoration(
                  labelText: 'Passphrase',
                  border: const OutlineInputBorder(),
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
                  style: TextStyle(color: theme.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: Spacing.lg),
              FilledButton(
                onPressed: _verifying ? null : _unlock,
                child: _verifying
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Unlock'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
