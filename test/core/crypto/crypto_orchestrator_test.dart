import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/crypto/aes_gcm.dart';
import 'package:vael/core/crypto/crypto_orchestrator.dart';
import 'package:vael/core/crypto/fek_manager.dart';
import 'package:vael/core/crypto/key_derivation.dart';
import 'package:vael/core/crypto/key_storage.dart';

void main() {
  group('CryptoOrchestrator — First Device Setup', () {
    late CryptoOrchestrator orchestrator;
    late KeyStorage keyStorage;
    late InMemorySecureStorage secureStorage;

    setUp(() {
      secureStorage = InMemorySecureStorage();
      keyStorage = KeyStorage(storage: secureStorage);
      orchestrator = CryptoOrchestrator(
        keyDerivation: KeyDerivation(),
        fekManager: FekManager(
          keyDerivation: KeyDerivation(),
          aesGcm: AesGcm(),
        ),
        keyStorage: keyStorage,
        aesGcm: AesGcm(),
      );
    });

    test('setupFirstDevice generates FEK and returns manifest data', () async {
      final result = await orchestrator.setupFirstDevice(
        familyId: 'family-001',
        passphrase: 'my-secure-passphrase',
      );

      // Returns data needed for Drive manifest
      expect(result.wrappedFek, isNotEmpty);
      expect(result.salt, isNotEmpty);
      expect(result.salt.length, 32);

      // FEK is stored locally
      expect(await keyStorage.hasFek('family-001'), true);
    });

    test('FEK can be recovered with same passphrase and salt', () async {
      final result = await orchestrator.setupFirstDevice(
        familyId: 'family-001',
        passphrase: 'my-passphrase',
      );

      // Simulate second device: derive KEK from passphrase + salt, unwrap FEK
      final kd = KeyDerivation();
      final kek = kd.deriveKey('my-passphrase', result.salt);
      final fekManager = FekManager(keyDerivation: kd, aesGcm: AesGcm());
      final recoveredFek = fekManager.unwrapFek(result.wrappedFek, kek);

      // Should match the locally stored FEK
      final storedFek = await keyStorage.getFek('family-001');
      expect(recoveredFek, equals(storedFek));
    });

    test('wrong passphrase cannot recover FEK', () {
      expect(() async {
        final result = await orchestrator.setupFirstDevice(
          familyId: 'family-001',
          passphrase: 'correct-passphrase',
        );

        final kd = KeyDerivation();
        final wrongKek = kd.deriveKey('wrong-passphrase', result.salt);
        final fekManager = FekManager(keyDerivation: kd, aesGcm: AesGcm());
        fekManager.unwrapFek(result.wrappedFek, wrongKek);
      }, throwsA(isA<DecryptionException>()));
    });

    test('each setup generates unique FEK and salt', () async {
      final r1 = await orchestrator.setupFirstDevice(
        familyId: 'family-A',
        passphrase: 'passphrase',
      );
      final r2 = await orchestrator.setupFirstDevice(
        familyId: 'family-B',
        passphrase: 'passphrase',
      );

      expect(r1.salt, isNot(equals(r2.salt)));
      expect(r1.wrappedFek, isNot(equals(r2.wrappedFek)));
    });
  });

  group('CryptoOrchestrator — Join Flow', () {
    late CryptoOrchestrator orchestrator;
    late KeyStorage keyStorage;

    setUp(() {
      keyStorage = KeyStorage(storage: InMemorySecureStorage());
      orchestrator = CryptoOrchestrator(
        keyDerivation: KeyDerivation(),
        fekManager: FekManager(
          keyDerivation: KeyDerivation(),
          aesGcm: AesGcm(),
        ),
        keyStorage: keyStorage,
        aesGcm: AesGcm(),
      );
    });

    test('joinFamily unwraps and stores FEK from manifest', () async {
      // First device sets up
      final setup = await orchestrator.setupFirstDevice(
        familyId: 'family-001',
        passphrase: 'shared-passphrase',
      );

      // Clear local storage (simulate new device)
      await keyStorage.deleteFek('family-001');

      // Join with same passphrase + manifest data
      await orchestrator.joinFamily(
        familyId: 'family-001',
        passphrase: 'shared-passphrase',
        wrappedFek: setup.wrappedFek,
        salt: setup.salt,
      );

      expect(await keyStorage.hasFek('family-001'), true);
    });

    test('joinFamily with wrong passphrase throws', () async {
      final setup = await orchestrator.setupFirstDevice(
        familyId: 'family-001',
        passphrase: 'correct-passphrase',
      );

      await keyStorage.deleteFek('family-001');

      expect(
        () => orchestrator.joinFamily(
          familyId: 'family-001',
          passphrase: 'wrong-passphrase',
          wrappedFek: setup.wrappedFek,
          salt: setup.salt,
        ),
        throwsA(isA<DecryptionException>()),
      );
    });
  });

  group('CryptoOrchestrator — Passphrase Change', () {
    late CryptoOrchestrator orchestrator;
    late KeyStorage keyStorage;

    setUp(() {
      keyStorage = KeyStorage(storage: InMemorySecureStorage());
      orchestrator = CryptoOrchestrator(
        keyDerivation: KeyDerivation(),
        fekManager: FekManager(
          keyDerivation: KeyDerivation(),
          aesGcm: AesGcm(),
        ),
        keyStorage: keyStorage,
        aesGcm: AesGcm(),
      );
    });

    test('changePassphrase re-wraps FEK with new KEK', () async {
      final setup = await orchestrator.setupFirstDevice(
        familyId: 'family-001',
        passphrase: 'old-passphrase',
      );

      final result = await orchestrator.changePassphrase(
        familyId: 'family-001',
        oldPassphrase: 'old-passphrase',
        oldSalt: setup.salt,
        oldWrappedFek: setup.wrappedFek,
        newPassphrase: 'new-passphrase',
      );

      // New salt and wrapped FEK
      expect(result.salt, isNot(equals(setup.salt)));
      expect(result.wrappedFek, isNot(equals(setup.wrappedFek)));

      // Can unwrap with new passphrase
      final kd = KeyDerivation();
      final newKek = kd.deriveKey('new-passphrase', result.salt);
      final fm = FekManager(keyDerivation: kd, aesGcm: AesGcm());
      final fek = fm.unwrapFek(result.wrappedFek, newKek);

      expect(fek, equals(await keyStorage.getFek('family-001')));
    });

    test('changePassphrase with wrong old passphrase throws', () async {
      final setup = await orchestrator.setupFirstDevice(
        familyId: 'family-001',
        passphrase: 'old-passphrase',
      );

      expect(
        () => orchestrator.changePassphrase(
          familyId: 'family-001',
          oldPassphrase: 'wrong-old',
          oldSalt: setup.salt,
          oldWrappedFek: setup.wrappedFek,
          newPassphrase: 'new-passphrase',
        ),
        throwsA(isA<DecryptionException>()),
      );
    });
  });

  group('CryptoOrchestrator — Data Encryption', () {
    late CryptoOrchestrator orchestrator;
    late KeyStorage keyStorage;

    setUp(() {
      keyStorage = KeyStorage(storage: InMemorySecureStorage());
      orchestrator = CryptoOrchestrator(
        keyDerivation: KeyDerivation(),
        fekManager: FekManager(
          keyDerivation: KeyDerivation(),
          aesGcm: AesGcm(),
        ),
        keyStorage: keyStorage,
        aesGcm: AesGcm(),
      );
    });

    test('encryptData/decryptData round-trip using stored FEK', () async {
      await orchestrator.setupFirstDevice(
        familyId: 'family-001',
        passphrase: 'passphrase',
      );

      final plaintext = Uint8List.fromList([1, 2, 3, 4, 5]);
      final encrypted = await orchestrator.encryptData('family-001', plaintext);
      final decrypted = await orchestrator.decryptData('family-001', encrypted);

      expect(decrypted, equals(plaintext));
    });

    test('encryptData throws when no FEK stored', () {
      expect(
        () => orchestrator.encryptData(
          'no-such-family',
          Uint8List.fromList([1, 2, 3]),
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
