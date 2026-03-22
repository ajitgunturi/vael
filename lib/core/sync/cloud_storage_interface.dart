import 'dart:typed_data';

/// Supported cloud storage providers.
enum CloudProvider { googleDrive, iCloudDrive }

/// Provider-agnostic cloud storage interface.
///
/// Implementations handle the transport of encrypted bytes to/from
/// a cloud provider. All data is encrypted before reaching this layer —
/// implementations never see plaintext.
abstract class CloudStorageInterface {
  /// The cloud provider this implementation targets.
  CloudProvider get provider;

  /// Whether this provider supports file sharing with other users.
  bool get supportsSharing;

  Future<void> uploadChangeset(String fileName, Uint8List data);
  Future<Uint8List> downloadFile(String fileId);
  Future<List<CloudFileEntry>> listChangesets({DateTime? after});
  Future<void> uploadSnapshot(Uint8List data);
  Future<Uint8List?> downloadSnapshot();
  Future<Map<String, dynamic>?> readManifest();
  Future<void> writeManifest(Map<String, dynamic> manifest);

  /// Writes the database schema version to `.meta/schema_version.json`.
  Future<void> writeSchemaVersion(int version);

  /// Reads the database schema version from `.meta/schema_version.json`.
  /// Returns `null` if the file does not exist.
  Future<int?> readSchemaVersion();
}

/// Metadata for a file in cloud storage.
class CloudFileEntry {
  final String id;
  final String name;
  final DateTime modifiedTime;

  CloudFileEntry({
    required this.id,
    required this.name,
    required this.modifiedTime,
  });
}
