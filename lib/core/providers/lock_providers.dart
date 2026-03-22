import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage key for the passphrase hash.
///
/// When this key is present, the app has a passphrase set and should
/// lock on startup. The stored value is a salted hash used for
/// verification during unlock.
const _passphraseHashKey = 'vael_passphrase_hash';

/// Whether the app should start locked (passphrase has been set).
///
/// Reads from flutter_secure_storage once; returns true if a
/// passphrase hash is stored, false otherwise.
final hasPassphraseProvider = FutureProvider<bool>((ref) async {
  const storage = FlutterSecureStorage();
  final hash = await storage.read(key: _passphraseHashKey);
  return hash != null;
});

/// Tracks whether the app is currently locked.
///
/// Starts as `true`; set to `false` after successful passphrase
/// verification on the lock screen.
class LockStateNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void unlock() => state = false;

  void lock() => state = true;
}

/// Provider for the app lock state.
///
/// When `true`, the lock screen should be shown over the home shell.
final lockStateProvider = NotifierProvider<LockStateNotifier, bool>(
  LockStateNotifier.new,
);
