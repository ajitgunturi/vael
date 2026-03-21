import 'dart:typed_data';

import 'aes_gcm.dart';
import 'fek_manager.dart';
import 'key_derivation.dart';
import 'key_storage.dart';

/// Result of first-device setup or passphrase change.
/// Contains data to be uploaded to Drive manifest.
class CryptoSetupResult {
  final Uint8List wrappedFek;
  final Uint8List salt;

  CryptoSetupResult({required this.wrappedFek, required this.salt});
}

/// Coordinates crypto operations across key derivation, FEK management,
/// and secure storage.
class CryptoOrchestrator {
  final KeyDerivation keyDerivation;
  final FekManager fekManager;
  final KeyStorage keyStorage;
  final AesGcm aesGcm;

  CryptoOrchestrator({
    required this.keyDerivation,
    required this.fekManager,
    required this.keyStorage,
    required this.aesGcm,
  });

  /// First device setup: generates FEK, wraps it, stores locally.
  ///
  /// Returns [CryptoSetupResult] with wrapped FEK + salt for Drive manifest.
  Future<CryptoSetupResult> setupFirstDevice({
    required String familyId,
    required String passphrase,
  }) async {
    final salt = keyDerivation.generateSalt();
    final kek = keyDerivation.deriveKey(passphrase, salt);
    final fek = fekManager.generateFek();
    final wrappedFek = fekManager.wrapFek(fek, kek);

    await keyStorage.storeFek(familyId, fek);

    return CryptoSetupResult(wrappedFek: wrappedFek, salt: salt);
  }

  /// Join an existing family by unwrapping FEK from manifest data.
  ///
  /// Throws [DecryptionException] if passphrase is wrong.
  Future<void> joinFamily({
    required String familyId,
    required String passphrase,
    required Uint8List wrappedFek,
    required Uint8List salt,
  }) async {
    final kek = keyDerivation.deriveKey(passphrase, salt);
    final fek = fekManager.unwrapFek(wrappedFek, kek);
    await keyStorage.storeFek(familyId, fek);
  }

  /// Change passphrase: unwrap FEK with old KEK, re-wrap with new KEK.
  ///
  /// Returns new [CryptoSetupResult] to upload to Drive manifest.
  Future<CryptoSetupResult> changePassphrase({
    required String familyId,
    required String oldPassphrase,
    required Uint8List oldSalt,
    required Uint8List oldWrappedFek,
    required String newPassphrase,
  }) async {
    // Unwrap with old credentials
    final oldKek = keyDerivation.deriveKey(oldPassphrase, oldSalt);
    final fek = fekManager.unwrapFek(oldWrappedFek, oldKek);

    // Wrap with new credentials
    final newSalt = keyDerivation.generateSalt();
    final newKek = keyDerivation.deriveKey(newPassphrase, newSalt);
    final newWrappedFek = fekManager.wrapFek(fek, newKek);

    // Update local storage
    await keyStorage.storeFek(familyId, fek);

    return CryptoSetupResult(wrappedFek: newWrappedFek, salt: newSalt);
  }

  /// Encrypts data using the stored FEK for the given family.
  Future<Uint8List> encryptData(String familyId, Uint8List plaintext) async {
    final fek = await keyStorage.getFek(familyId);
    if (fek == null) throw StateError('No FEK stored for family $familyId');
    return aesGcm.encrypt(plaintext, fek);
  }

  /// Decrypts data using the stored FEK for the given family.
  Future<Uint8List> decryptData(String familyId, Uint8List ciphertext) async {
    final fek = await keyStorage.getFek(familyId);
    if (fek == null) throw StateError('No FEK stored for family $familyId');
    return aesGcm.decrypt(ciphertext, fek);
  }
}
