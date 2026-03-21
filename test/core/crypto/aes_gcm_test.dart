import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/crypto/aes_gcm.dart';

void main() {
  group('AesGcm', () {
    late AesGcm aesGcm;
    late Uint8List key;

    setUp(() {
      aesGcm = AesGcm();
      // Fixed 256-bit key for testing
      key = Uint8List.fromList(List.generate(32, (i) => i));
    });

    test('round-trip encrypt/decrypt produces original plaintext', () {
      final plaintext = utf8.encode('Hello, Vael family!');
      final plaintextBytes = Uint8List.fromList(plaintext);

      final ciphertext = aesGcm.encrypt(plaintextBytes, key);
      final decrypted = aesGcm.decrypt(ciphertext, key);

      expect(decrypted, equals(plaintextBytes));
    });

    test('ciphertext differs on each encryption (random IV)', () {
      final plaintext = Uint8List.fromList(utf8.encode('same data'));

      final ct1 = aesGcm.encrypt(plaintext, key);
      final ct2 = aesGcm.encrypt(plaintext, key);

      expect(ct1, isNot(equals(ct2))); // Random IV → different ciphertext
    });

    test('ciphertext format is IV(12) || ciphertext || tag(16)', () {
      final plaintext = Uint8List.fromList(utf8.encode('test'));

      final ciphertext = aesGcm.encrypt(plaintext, key);

      // IV (12 bytes) + encrypted data (same length as plaintext) + tag (16 bytes)
      expect(ciphertext.length, 12 + plaintext.length + 16);
    });

    test('wrong key fails to decrypt', () {
      final plaintext = Uint8List.fromList(utf8.encode('secret data'));
      final ciphertext = aesGcm.encrypt(plaintext, key);

      final wrongKey = Uint8List.fromList(List.generate(32, (i) => i + 50));

      expect(
        () => aesGcm.decrypt(ciphertext, wrongKey),
        throwsA(isA<DecryptionException>()),
      );
    });

    test('tampered ciphertext fails to decrypt', () {
      final plaintext = Uint8List.fromList(utf8.encode('integrity test'));
      final ciphertext = aesGcm.encrypt(plaintext, key);

      // Flip a byte in the ciphertext body (after IV, before tag)
      final tampered = Uint8List.fromList(ciphertext);
      tampered[15] ^= 0xFF;

      expect(
        () => aesGcm.decrypt(tampered, key),
        throwsA(isA<DecryptionException>()),
      );
    });

    test('encrypts empty plaintext', () {
      final plaintext = Uint8List(0);

      final ciphertext = aesGcm.encrypt(plaintext, key);
      final decrypted = aesGcm.decrypt(ciphertext, key);

      expect(decrypted, equals(plaintext));
      expect(ciphertext.length, 12 + 0 + 16); // IV + empty + tag
    });

    test('encrypts large plaintext (1 MB)', () {
      final plaintext = Uint8List.fromList(
        List.generate(1024 * 1024, (i) => i % 256),
      );

      final ciphertext = aesGcm.encrypt(plaintext, key);
      final decrypted = aesGcm.decrypt(ciphertext, key);

      expect(decrypted, equals(plaintext));
    });

    test('rejects key that is not 32 bytes', () {
      final plaintext = Uint8List.fromList(utf8.encode('test'));
      final shortKey = Uint8List(16);

      expect(
        () => aesGcm.encrypt(plaintext, shortKey),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects ciphertext shorter than IV + tag (28 bytes)', () {
      final tooShort = Uint8List(27);

      expect(
        () => aesGcm.decrypt(tooShort, key),
        throwsA(isA<DecryptionException>()),
      );
    });
  });
}
