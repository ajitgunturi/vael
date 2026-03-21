import 'dart:typed_data';

import '../crypto/aes_gcm.dart';
import 'cloud_storage_interface.dart';

/// Manages full database snapshot upload/download with encryption.
class SnapshotManager {
  final CloudStorageInterface cloudStorage;
  final AesGcm aesGcm;
  final Uint8List fek;

  SnapshotManager({
    required this.cloudStorage,
    required this.aesGcm,
    required this.fek,
  });

  /// Encrypts and uploads a full database snapshot.
  Future<void> uploadSnapshot(Uint8List dbBytes) async {
    final encrypted = aesGcm.encrypt(dbBytes, fek);
    await cloudStorage.uploadSnapshot(encrypted);
  }

  /// Downloads and decrypts a snapshot. Returns null if none exists.
  Future<Uint8List?> downloadSnapshot() async {
    final encrypted = await cloudStorage.downloadSnapshot();
    if (encrypted == null) return null;
    return aesGcm.decrypt(encrypted, fek);
  }
}
