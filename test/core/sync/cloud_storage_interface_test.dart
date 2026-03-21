import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/sync/cloud_storage_interface.dart';

void main() {
  group('CloudProvider', () {
    test('has googleDrive and iCloudDrive values', () {
      expect(CloudProvider.values, hasLength(2));
      expect(CloudProvider.values, contains(CloudProvider.googleDrive));
      expect(CloudProvider.values, contains(CloudProvider.iCloudDrive));
    });
  });

  group('CloudFileEntry', () {
    test('stores file metadata', () {
      final now = DateTime.utc(2026, 3, 21);
      final entry = CloudFileEntry(
        id: 'file-123',
        name: 'changeset.enc',
        modifiedTime: now,
      );

      expect(entry.id, 'file-123');
      expect(entry.name, 'changeset.enc');
      expect(entry.modifiedTime, now);
    });
  });
}
