import 'dart:math';
import 'dart:typed_data';

import 'aes_gcm.dart';
import 'key_derivation.dart';

/// Manages the Family Encryption Key (FEK) lifecycle.
///
/// The FEK is a random 256-bit key that encrypts all family data.
/// It is wrapped (encrypted) by the KEK derived from the family passphrase.
class FekManager {
  final KeyDerivation keyDerivation;
  final AesGcm aesGcm;

  FekManager({required this.keyDerivation, required this.aesGcm});

  /// Generates a cryptographically secure random 256-bit FEK.
  Uint8List generateFek() {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(32, (_) => random.nextInt(256)),
    );
  }

  /// Wraps (encrypts) the FEK with the KEK using AES-256-GCM.
  Uint8List wrapFek(Uint8List fek, Uint8List kek) {
    return aesGcm.encrypt(fek, kek);
  }

  /// Unwraps (decrypts) the FEK using the KEK.
  ///
  /// Throws [DecryptionException] if the KEK is wrong.
  Uint8List unwrapFek(Uint8List wrappedFek, Uint8List kek) {
    return aesGcm.decrypt(wrappedFek, kek);
  }
}
