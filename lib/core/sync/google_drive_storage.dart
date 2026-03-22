import 'dart:convert';
import 'dart:typed_data';

import 'cloud_storage_interface.dart';

/// Abstraction over the raw Google Drive API for testability.
abstract class DriveApiAdapter {
  Future<String?> findFolder(String name, {String? parentId});
  Future<String> createFolder(String name, {String? parentId});
  Future<void> uploadFile(String name, Uint8List data, {String? parentId});
  Future<void> updateFile(String fileId, Uint8List data);
  Future<Uint8List> downloadFile(String fileId);
  Future<List<CloudFileEntry>> listFiles(
    String parentId, {
    DateTime? modifiedAfter,
  });
  Future<String?> findFile(String name, {String? parentId});
}

/// Google Drive [CloudStorageInterface] implementation.
///
/// Folder layout:
/// ```
/// 6d11beccfd0f0ab4/
/// ├── .meta/manifest.json
/// ├── changesets/*.enc
/// └── snapshots/latest.enc
/// ```
class GoogleDriveStorage implements CloudStorageInterface {
  final DriveApiAdapter api;

  /// Opaque root folder name — SHA-256 prefix of 'vael_sync_storage'.
  /// Avoids leaking product semantics on the user's Drive.
  static const _rootFolderName = '6d11beccfd0f0ab4';

  GoogleDriveStorage({required this.api});

  @override
  CloudProvider get provider => CloudProvider.googleDrive;

  @override
  bool get supportsSharing => true;

  @override
  Future<void> uploadChangeset(String fileName, Uint8List data) async {
    final folderId = await _ensureChangesetFolder();
    await api.uploadFile(fileName, data, parentId: folderId);
  }

  @override
  Future<Uint8List> downloadFile(String fileId) async {
    return api.downloadFile(fileId);
  }

  @override
  Future<List<CloudFileEntry>> listChangesets({DateTime? after}) async {
    final folderId = await api.findFolder(
      'changesets',
      parentId: await _vaelFolderId(),
    );
    if (folderId == null) return [];
    return api.listFiles(folderId, modifiedAfter: after);
  }

  @override
  Future<void> uploadSnapshot(Uint8List data) async {
    final folderId = await _ensureSnapshotFolder();
    final existing = await api.findFile('latest.enc', parentId: folderId);
    if (existing != null) {
      await api.updateFile(existing, data);
    } else {
      await api.uploadFile('latest.enc', data, parentId: folderId);
    }
  }

  @override
  Future<Uint8List?> downloadSnapshot() async {
    final folderId = await api.findFolder(
      'snapshots',
      parentId: await _vaelFolderId(),
    );
    if (folderId == null) return null;
    final fileId = await api.findFile('latest.enc', parentId: folderId);
    if (fileId == null) return null;
    return api.downloadFile(fileId);
  }

  @override
  Future<Map<String, dynamic>?> readManifest() async {
    final metaId = await api.findFolder(
      '.meta',
      parentId: await _vaelFolderId(),
    );
    if (metaId == null) return null;
    final fileId = await api.findFile('manifest.json', parentId: metaId);
    if (fileId == null) return null;
    final data = await api.downloadFile(fileId);
    return jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
  }

  @override
  Future<void> writeManifest(Map<String, dynamic> manifest) async {
    final metaId = await _ensureMetaFolder();
    final data = Uint8List.fromList(utf8.encode(jsonEncode(manifest)));
    final existing = await api.findFile('manifest.json', parentId: metaId);
    if (existing != null) {
      await api.updateFile(existing, data);
    } else {
      await api.uploadFile('manifest.json', data, parentId: metaId);
    }
  }

  @override
  Future<void> writeSchemaVersion(int version) async {
    final metaId = await _ensureMetaFolder();
    final data = Uint8List.fromList(
      utf8.encode(jsonEncode({'schema_version': version})),
    );
    final existing = await api.findFile(
      'schema_version.json',
      parentId: metaId,
    );
    if (existing != null) {
      await api.updateFile(existing, data);
    } else {
      await api.uploadFile('schema_version.json', data, parentId: metaId);
    }
  }

  @override
  Future<int?> readSchemaVersion() async {
    final metaId = await api.findFolder(
      '.meta',
      parentId: await _vaelFolderId(),
    );
    if (metaId == null) return null;
    final fileId = await api.findFile('schema_version.json', parentId: metaId);
    if (fileId == null) return null;
    final data = await api.downloadFile(fileId);
    final json = jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
    return json['schema_version'] as int?;
  }

  Future<String> _vaelFolderId() async {
    final id = await api.findFolder(_rootFolderName);
    if (id != null) return id;
    return api.createFolder(_rootFolderName);
  }

  Future<String> _ensureChangesetFolder() async {
    final vaelId = await _vaelFolderId();
    final id = await api.findFolder('changesets', parentId: vaelId);
    if (id != null) return id;
    return api.createFolder('changesets', parentId: vaelId);
  }

  Future<String> _ensureSnapshotFolder() async {
    final vaelId = await _vaelFolderId();
    final id = await api.findFolder('snapshots', parentId: vaelId);
    if (id != null) return id;
    return api.createFolder('snapshots', parentId: vaelId);
  }

  Future<String> _ensureMetaFolder() async {
    final vaelId = await _vaelFolderId();
    final id = await api.findFolder('.meta', parentId: vaelId);
    if (id != null) return id;
    return api.createFolder('.meta', parentId: vaelId);
  }
}
