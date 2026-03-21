import 'dart:typed_data';

/// Abstract interface for Google Drive operations.
///
/// Allows sync components to be tested with mock implementations.
/// Real implementation in [DriveClient] wraps googleapis.
abstract class DriveClientInterface {
  Future<void> uploadChangeset(String fileName, Uint8List data);
  Future<Uint8List> downloadFile(String fileId);
  Future<List<DriveFileEntry>> listChangesets({DateTime? after});
  Future<void> uploadSnapshot(Uint8List data);
  Future<Uint8List?> downloadSnapshot();
  Future<Map<String, dynamic>?> readManifest();
  Future<void> writeManifest(Map<String, dynamic> manifest);
}

/// Metadata for a file in Google Drive.
class DriveFileEntry {
  final String id;
  final String name;
  final DateTime modifiedTime;

  DriveFileEntry({
    required this.id,
    required this.name,
    required this.modifiedTime,
  });
}
