import 'dart:typed_data';

/// Supported cloud storage providers.
enum CloudProvider { googleDrive, iCloudDrive }

/// Provider-agnostic cloud storage interface.
///
/// Implementations handle the transport of encrypted bytes to/from
/// a cloud provider. All data is encrypted before reaching this layer —
/// implementations never see plaintext.
abstract class CloudStorageInterface {
  Future<void> uploadChangeset(String fileName, Uint8List data);
  Future<Uint8List> downloadFile(String fileId);
  Future<List<CloudFileEntry>> listChangesets({DateTime? after});
  Future<void> uploadSnapshot(Uint8List data);
  Future<Uint8List?> downloadSnapshot();
  Future<Map<String, dynamic>?> readManifest();
  Future<void> writeManifest(Map<String, dynamic> manifest);
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
