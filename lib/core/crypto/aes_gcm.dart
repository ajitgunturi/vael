import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

/// AES-256-GCM encryption/decryption.
///
/// Ciphertext format: IV (12 bytes) || ciphertext || tag (16 bytes)
///
/// Each encryption uses a random 12-byte IV for semantic security —
/// the same plaintext produces different ciphertext on each call.
class AesGcm {
  static const int _ivLength = 12;
  static const int _tagLength = 16;

  /// Encrypts [plaintext] with [key] using AES-256-GCM.
  ///
  /// Returns IV || ciphertext || tag.
  /// [key] must be exactly 32 bytes (256 bits).
  Uint8List encrypt(Uint8List plaintext, Uint8List key) {
    if (key.length != 32) {
      throw ArgumentError('Key must be 32 bytes (256 bits), got ${key.length}');
    }

    final iv = _randomIv();
    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        true,
        AEADParameters(
          KeyParameter(key),
          _tagLength * 8,
          iv,
          Uint8List(0),
        ),
      );

    final output = Uint8List(cipher.getOutputSize(plaintext.length));
    final len = cipher.processBytes(plaintext, 0, plaintext.length, output, 0);
    final finalLen = cipher.doFinal(output, len);
    final actualOutput = output.sublist(0, len + finalLen);

    // Format: IV || ciphertext+tag
    final result = Uint8List(_ivLength + actualOutput.length);
    result.setRange(0, _ivLength, iv);
    result.setRange(_ivLength, result.length, actualOutput);
    return result;
  }

  /// Decrypts [ciphertext] with [key] using AES-256-GCM.
  ///
  /// Expects format: IV (12 bytes) || ciphertext || tag (16 bytes).
  /// Throws [DecryptionException] on authentication failure or invalid input.
  Uint8List decrypt(Uint8List ciphertext, Uint8List key) {
    if (key.length != 32) {
      throw ArgumentError('Key must be 32 bytes (256 bits), got ${key.length}');
    }
    if (ciphertext.length < _ivLength + _tagLength) {
      throw DecryptionException(
        'Ciphertext too short: ${ciphertext.length} bytes '
        '(minimum ${_ivLength + _tagLength})',
      );
    }

    final iv = ciphertext.sublist(0, _ivLength);
    final encryptedWithTag = ciphertext.sublist(_ivLength);

    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        false,
        AEADParameters(
          KeyParameter(key),
          _tagLength * 8,
          iv,
          Uint8List(0),
        ),
      );

    try {
      final output = Uint8List(cipher.getOutputSize(encryptedWithTag.length));
      final len = cipher.processBytes(
          encryptedWithTag, 0, encryptedWithTag.length, output, 0);
      final finalLen = cipher.doFinal(output, len);
      return output.sublist(0, len + finalLen);
    } on InvalidCipherTextException catch (e) {
      throw DecryptionException('Authentication failed: $e');
    }
  }

  Uint8List _randomIv() {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(_ivLength, (_) => random.nextInt(256)),
    );
  }
}

/// Thrown when decryption fails due to wrong key, tampering, or invalid format.
class DecryptionException implements Exception {
  final String message;
  DecryptionException(this.message);

  @override
  String toString() => 'DecryptionException: $message';
}
