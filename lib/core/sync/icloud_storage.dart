import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'cloud_storage_interface.dart';
import 'icloud_platform_channel.dart';

/// iCloud Drive [CloudStorageInterface] implementation.
///
/// Uses the device's iCloud ubiquity container for storage. The OS handles
/// sync automatically — no HTTP API calls needed. Files are written to a
/// local directory that the OS mirrors to iCloud.
///
/// Folder layout (same structure as Google Drive):
/// ```
/// <ubiquity_container>/6d11beccfd0f0ab4/
/// ├── .meta/manifest.json
/// ├── changesets/*.enc
/// └── snapshots/latest.enc
/// ```
///
/// Only available on Apple platforms (iOS, macOS). Android is not supported.
class ICloudStorage implements CloudStorageInterface {
  final ICloudPlatformChannel _platform;
  String? _containerPath;

  ICloudStorage({required ICloudPlatformChannel platform})
    : _platform = platform;

  @override
  CloudProvider get provider => CloudProvider.iCloudDrive;

  @override
  bool get supportsSharing => false;

  /// Resolves the Vael root directory inside the ubiquity container.
  /// Creates the directory structure if it doesn't exist.
  Future<String> _vaelRoot() async {
    if (_containerPath == null) {
      final container = await _platform.getContainerPath();
      if (container == null) {
        throw StateError(
          'iCloud is not available. Ensure the user is signed into iCloud.',
        );
      }
      _containerPath = container;
    }
    final root = '$_containerPath/6d11beccfd0f0ab4';
    await Directory(root).create(recursive: true);
    return root;
  }

  Future<String> _ensureDir(String subdir) async {
    final root = await _vaelRoot();
    final dir = '$root/$subdir';
    await Directory(dir).create(recursive: true);
    return dir;
  }

  @override
  Future<void> uploadChangeset(String fileName, Uint8List data) async {
    final dir = await _ensureDir('changesets');
    await File('$dir/$fileName').writeAsBytes(data);
  }

  @override
  Future<Uint8List> downloadFile(String fileId) async {
    final file = File(fileId);

    // Trigger download if file has been evicted by iOS
    if (!await file.exists()) {
      final downloaded = await _platform.startDownloading(fileId);
      if (!downloaded) {
        throw FileSystemException('File not available', fileId);
      }
      // Wait for the file to become available (OS downloads in background)
      await _waitForFile(file);
    }

    return file.readAsBytes();
  }

  @override
  Future<List<CloudFileEntry>> listChangesets({DateTime? after}) async {
    final dir = await _ensureDir('changesets');
    final directory = Directory(dir);

    if (!await directory.exists()) return [];

    final entries = <CloudFileEntry>[];
    await for (final entity in directory.list()) {
      if (entity is File && entity.path.endsWith('.enc')) {
        final stat = await entity.stat();
        if (after == null || stat.modified.isAfter(after)) {
          entries.add(
            CloudFileEntry(
              id: entity.path, // iCloud uses file paths as IDs
              name: entity.uri.pathSegments.last,
              modifiedTime: stat.modified,
            ),
          );
        }
      }
    }

    return entries;
  }

  @override
  Future<void> uploadSnapshot(Uint8List data) async {
    final dir = await _ensureDir('snapshots');
    await File('$dir/latest.enc').writeAsBytes(data);
  }

  @override
  Future<Uint8List?> downloadSnapshot() async {
    final dir = await _ensureDir('snapshots');
    final file = File('$dir/latest.enc');

    if (await file.exists()) {
      return file.readAsBytes();
    }

    // File might exist in iCloud but be evicted locally
    final isLocal = await _platform.isFileLocal(file.path);
    if (!isLocal) return null;

    // File exists remotely — trigger download and wait
    final started = await _platform.startDownloading(file.path);
    if (!started) return null;
    await _waitForFile(file);
    return file.readAsBytes();
  }

  @override
  Future<Map<String, dynamic>?> readManifest() async {
    final dir = await _ensureDir('.meta');
    final file = File('$dir/manifest.json');
    if (!await file.exists()) return null;
    final content = await file.readAsString();
    return jsonDecode(content) as Map<String, dynamic>;
  }

  @override
  Future<void> writeManifest(Map<String, dynamic> manifest) async {
    final dir = await _ensureDir('.meta');
    await File('$dir/manifest.json').writeAsString(jsonEncode(manifest));
  }

  @override
  Future<void> writeSchemaVersion(int version) async {
    final dir = await _ensureDir('.meta');
    await File(
      '$dir/schema_version.json',
    ).writeAsString(jsonEncode({'schema_version': version}));
  }

  @override
  Future<int?> readSchemaVersion() async {
    final dir = await _ensureDir('.meta');
    final file = File('$dir/schema_version.json');
    if (!await file.exists()) return null;
    final content = await file.readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;
    return json['schema_version'] as int?;
  }

  /// Waits for an evicted file to become locally available after
  /// triggering a download. Times out after 30 seconds.
  Future<void> _waitForFile(File file, {Duration? timeout}) async {
    final deadline = DateTime.now().add(timeout ?? const Duration(seconds: 30));
    while (!await file.exists()) {
      if (DateTime.now().isAfter(deadline)) {
        throw TimeoutException(
          'Timed out waiting for iCloud file download: ${file.path}',
        );
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }
}

/// Exception thrown when an iCloud file download times out.
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}
