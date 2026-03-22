import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/crypto/aes_gcm.dart';
import 'package:vael/core/crypto/recovery_key.dart';

void main() {
  group('RecoveryKeyService', () {
    group('generate', () {
      test(
        'returns a string of correct format (6 groups of 4 letters separated by hyphens)',
        () {
          final key = RecoveryKeyService.generate();

          final groups = key.split('-');
          expect(groups, hasLength(6));

          for (final group in groups) {
            expect(group.length, 4);
            // Each character should be uppercase A-Z
            expect(group, matches(RegExp(r'^[A-Z]{4}$')));
          }
        },
      );

      test('returns different keys on successive calls', () {
        final key1 = RecoveryKeyService.generate();
        final key2 = RecoveryKeyService.generate();

        expect(key1, isNot(equals(key2)));
      });
    });

    group('encrypt/decrypt round-trip', () {
      test(
        'encryptFekWithRecoveryKey + decryptFekWithRecoveryKey round-trips correctly',
        () {
          final fek = Uint8List.fromList(
            List.generate(32, (i) => i), // 32-byte FEK
          );
          final recoveryKey = RecoveryKeyService.generate();

          final encrypted = RecoveryKeyService.encryptFekWithRecoveryKey(
            fek,
            recoveryKey,
          );
          final decrypted = RecoveryKeyService.decryptFekWithRecoveryKey(
            encrypted,
            recoveryKey,
          );

          expect(decrypted, equals(fek));
        },
      );

      test('wrong recovery key fails to decrypt', () {
        final fek = Uint8List.fromList(List.generate(32, (i) => i + 100));
        final correctKey = RecoveryKeyService.generate();
        final wrongKey = RecoveryKeyService.generate();

        final encrypted = RecoveryKeyService.encryptFekWithRecoveryKey(
          fek,
          correctKey,
        );

        expect(
          () =>
              RecoveryKeyService.decryptFekWithRecoveryKey(encrypted, wrongKey),
          throwsA(isA<DecryptionException>()),
        );
      });
    });
  });
}
