import 'dart:convert';
import 'dart:typed_data';

/// Abstraction over platform secure storage for FEK persistence.
///
/// In production, wraps flutter_secure_storage (iOS Keychain / Android KeyStore).
/// In tests, uses [InMemorySecureStorage].
class KeyStorage {
  final SecureStorageAdapter storage;

  KeyStorage({required this.storage});

  String _fekKey(String familyId) => 'vael_fek_$familyId';

  Future<void> storeFek(String familyId, Uint8List fek) async {
    await storage.write(_fekKey(familyId), base64Encode(fek));
  }

  Future<Uint8List?> getFek(String familyId) async {
    final encoded = await storage.read(_fekKey(familyId));
    if (encoded == null) return null;
    return base64Decode(encoded);
  }

  Future<void> deleteFek(String familyId) async {
    await storage.delete(_fekKey(familyId));
  }

  Future<bool> hasFek(String familyId) async {
    return await storage.read(_fekKey(familyId)) != null;
  }
}

/// Abstract adapter for secure storage — allows mocking in tests.
abstract class SecureStorageAdapter {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
}

/// In-memory implementation for unit tests.
class InMemorySecureStorage implements SecureStorageAdapter {
  final _store = <String, String>{};

  @override
  Future<void> write(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<String?> read(String key) async {
    return _store[key];
  }

  @override
  Future<void> delete(String key) async {
    _store.remove(key);
  }
}
