import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/pointycastle.dart';

/// Derives a 256-bit key from a passphrase using PBKDF2-HMAC-SHA256.
///
/// Used to derive the Key Encryption Key (KEK) from the family passphrase.
class KeyDerivation {
  static const int _iterations = 100000;
  static const int _keyLengthBytes = 32; // 256 bits
  static const int _saltLengthBytes = 32;

  /// Derives a 256-bit key from [passphrase] and [salt].
  ///
  /// Uses PBKDF2 with HMAC-SHA256, 100k iterations.
  Uint8List deriveKey(String passphrase, Uint8List salt) {
    final params = Pbkdf2Parameters(salt, _iterations, _keyLengthBytes);
    final pbkdf2 = KeyDerivator('SHA-256/HMAC/PBKDF2')..init(params);

    return pbkdf2.process(Uint8List.fromList(utf8.encode(passphrase)));
  }

  /// Generates a cryptographically secure random 32-byte salt.
  Uint8List generateSalt() {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(_saltLengthBytes, (_) => random.nextInt(256)),
    );
  }
}
