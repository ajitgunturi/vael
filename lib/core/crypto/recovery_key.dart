import 'dart:math';
import 'dart:typed_data';

import 'aes_gcm.dart';
import 'key_derivation.dart';

/// Service for generating and using recovery keys to protect the FEK.
///
/// A recovery key is a human-readable string of 6 groups of 4 uppercase
/// letters separated by hyphens (e.g. `ABCD-EFGH-IJKL-MNOP-QRST-UVWX`).
/// It serves as an emergency passphrase to decrypt the FEK when the
/// family passphrase is forgotten.
class RecoveryKeyService {
  /// Generates a 24-character recovery key: 6 groups of 4 random
  /// uppercase letters separated by hyphens.
  ///
  /// Uses [Random.secure] for cryptographic randomness.
  static String generate() {
    final random = Random.secure();
    final groups = List.generate(6, (_) {
      return String.fromCharCodes(
        List.generate(4, (_) => random.nextInt(26) + 65), // A-Z
      );
    });
    return groups.join('-');
  }

  /// Encrypts [fek] using [recoveryKey] as the passphrase.
  ///
  /// Derives a 256-bit key from the recovery key via PBKDF2, then
  /// encrypts the FEK with AES-256-GCM. The returned blob contains
  /// the salt (32 bytes) prepended to the AES-GCM ciphertext
  /// (IV + ciphertext + tag).
  ///
  /// Format: salt (32 bytes) || IV (12 bytes) || ciphertext || tag (16 bytes)
  static Uint8List encryptFekWithRecoveryKey(
    Uint8List fek,
    String recoveryKey,
  ) {
    final derivation = KeyDerivation();
    final salt = derivation.generateSalt();
    final key = derivation.deriveKey(recoveryKey, salt);

    final aes = AesGcm();
    final encrypted = aes.encrypt(fek, key);

    // Prepend salt so decryption can re-derive the key.
    final result = Uint8List(salt.length + encrypted.length);
    result.setRange(0, salt.length, salt);
    result.setRange(salt.length, result.length, encrypted);
    return result;
  }

  /// Decrypts [encryptedFek] using [recoveryKey] as the passphrase.
  ///
  /// Expects the format produced by [encryptFekWithRecoveryKey]:
  /// salt (32 bytes) || IV (12 bytes) || ciphertext || tag (16 bytes).
  ///
  /// Throws [DecryptionException] if the recovery key is wrong or
  /// the data is tampered.
  static Uint8List decryptFekWithRecoveryKey(
    Uint8List encryptedFek,
    String recoveryKey,
  ) {
    const saltLength = 32;
    if (encryptedFek.length < saltLength + 12 + 16) {
      throw DecryptionException(
        'Encrypted FEK too short: ${encryptedFek.length} bytes',
      );
    }

    final salt = encryptedFek.sublist(0, saltLength);
    final ciphertext = encryptedFek.sublist(saltLength);

    final derivation = KeyDerivation();
    final key = derivation.deriveKey(recoveryKey, salt);

    final aes = AesGcm();
    return aes.decrypt(ciphertext, key);
  }
}
