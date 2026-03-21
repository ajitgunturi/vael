import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/crypto/aes_gcm.dart';
import 'package:vael/core/sync/drive_client_interface.dart';
import 'package:vael/core/sync/snapshot_manager.dart';

class MockDriveClient implements DriveClientInterface {
  Uint8List? uploadedSnapshot;
  Uint8List? storedSnapshot;

  @override
  Future<void> uploadSnapshot(Uint8List data) async {
    uploadedSnapshot = data;
    storedSnapshot = data;
  }

  @override
  Future<Uint8List?> downloadSnapshot() async => storedSnapshot;

  @override
  Future<void> uploadChangeset(String fileName, Uint8List data) async {}
  @override
  Future<Uint8List> downloadFile(String fileId) async => Uint8List(0);
  @override
  Future<List<DriveFileEntry>> listChangesets({DateTime? after}) async => [];
  @override
  Future<Map<String, dynamic>?> readManifest() async => null;
  @override
  Future<void> writeManifest(Map<String, dynamic> manifest) async {}
}

void main() {
  group('SnapshotManager', () {
    late SnapshotManager snapshotManager;
    late MockDriveClient driveClient;
    late Uint8List fek;

    setUp(() {
      driveClient = MockDriveClient();
      fek = Uint8List.fromList(List.generate(32, (i) => i));
      snapshotManager = SnapshotManager(
        driveClient: driveClient,
        aesGcm: AesGcm(),
        fek: fek,
      );
    });

    test('export → encrypt → upload → download → decrypt → restore round-trip', () async {
      final dbBytes = Uint8List.fromList(
        List.generate(1024, (i) => i % 256),
      );

      await snapshotManager.uploadSnapshot(dbBytes);
      expect(driveClient.uploadedSnapshot, isNotNull);

      // Uploaded data should be encrypted (different from raw)
      expect(driveClient.uploadedSnapshot, isNot(equals(dbBytes)));

      final restored = await snapshotManager.downloadSnapshot();
      expect(restored, isNotNull);
      expect(restored, equals(dbBytes));
    });

    test('uploaded snapshot is encrypted', () async {
      final dbBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

      await snapshotManager.uploadSnapshot(dbBytes);

      // Encrypted: IV(12) + ciphertext(5) + tag(16) = 33 bytes
      expect(driveClient.uploadedSnapshot!.length, 12 + 5 + 16);
    });

    test('returns null when no snapshot exists', () async {
      final result = await snapshotManager.downloadSnapshot();
      expect(result, isNull);
    });

    test('wrong FEK cannot decrypt snapshot', () async {
      final dbBytes = Uint8List.fromList([10, 20, 30]);
      await snapshotManager.uploadSnapshot(dbBytes);

      final wrongFek = Uint8List.fromList(List.generate(32, (i) => i + 99));
      final wrongManager = SnapshotManager(
        driveClient: driveClient,
        aesGcm: AesGcm(),
        fek: wrongFek,
      );

      expect(
        () => wrongManager.downloadSnapshot(),
        throwsA(isA<Exception>()),
      );
    });

    test('large snapshot (1 MB) round-trips correctly', () async {
      final dbBytes = Uint8List.fromList(
        List.generate(1024 * 1024, (i) => i % 256),
      );

      await snapshotManager.uploadSnapshot(dbBytes);
      final restored = await snapshotManager.downloadSnapshot();

      expect(restored, equals(dbBytes));
    });
  });
}
