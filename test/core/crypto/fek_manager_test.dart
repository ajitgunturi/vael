import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/crypto/aes_gcm.dart';
import 'package:vael/core/crypto/fek_manager.dart';
import 'package:vael/core/crypto/key_derivation.dart';

void main() {
  group('FekManager', () {
    late FekManager fekManager;

    setUp(() {
      fekManager = FekManager(keyDerivation: KeyDerivation(), aesGcm: AesGcm());
    });

    test('generates a random 32-byte FEK', () {
      final fek1 = fekManager.generateFek();
      final fek2 = fekManager.generateFek();

      expect(fek1.length, 32);
      expect(fek2.length, 32);
      expect(fek1, isNot(equals(fek2))); // Random — must differ
    });

    test('wrap/unwrap round-trip recovers original FEK', () {
      final fek = fekManager.generateFek();
      final kek = Uint8List.fromList(List.generate(32, (i) => i * 3));

      final wrapped = fekManager.wrapFek(fek, kek);
      final unwrapped = fekManager.unwrapFek(wrapped, kek);

      expect(unwrapped, equals(fek));
    });

    test('wrapped FEK differs from raw FEK', () {
      final fek = fekManager.generateFek();
      final kek = Uint8List.fromList(List.generate(32, (i) => i));

      final wrapped = fekManager.wrapFek(fek, kek);

      // Wrapped contains IV + encrypted FEK + tag — longer and different
      expect(wrapped.length, greaterThan(fek.length));
      expect(wrapped, isNot(equals(fek)));
    });

    test('wrong KEK fails to unwrap', () {
      final fek = fekManager.generateFek();
      final kek = Uint8List.fromList(List.generate(32, (i) => i));
      final wrongKek = Uint8List.fromList(List.generate(32, (i) => i + 99));

      final wrapped = fekManager.wrapFek(fek, kek);

      expect(
        () => fekManager.unwrapFek(wrapped, wrongKek),
        throwsA(isA<DecryptionException>()),
      );
    });

    test(
      'wrapping same FEK twice produces different ciphertext (random IV)',
      () {
        final fek = fekManager.generateFek();
        final kek = Uint8List.fromList(List.generate(32, (i) => i));

        final wrapped1 = fekManager.wrapFek(fek, kek);
        final wrapped2 = fekManager.wrapFek(fek, kek);

        expect(wrapped1, isNot(equals(wrapped2)));
      },
    );

    test('full flow: passphrase → KEK → wrap FEK → unwrap FEK', () {
      final kd = KeyDerivation();
      final salt = kd.generateSalt();
      final kek = kd.deriveKey('my-family-passphrase', salt);

      final fek = fekManager.generateFek();
      final wrapped = fekManager.wrapFek(fek, kek);

      // Simulate another device: same passphrase + salt → same KEK → unwrap
      final kek2 = kd.deriveKey('my-family-passphrase', salt);
      final unwrapped = fekManager.unwrapFek(wrapped, kek2);

      expect(unwrapped, equals(fek));
    });
  });
}
