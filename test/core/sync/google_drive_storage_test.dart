import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/sync/cloud_storage_interface.dart';
import 'package:vael/core/sync/google_drive_storage.dart';

/// In-memory mock of the Google Drive API for testing GoogleDriveStorage logic.
class MockDriveApi implements DriveApiAdapter {
  final files = <String, MockFile>{};
  String? vaelFolderId = 'folder-vael';
  String? changesetsFolderId = 'folder-changesets';
  String? snapshotsFolderId = 'folder-snapshots';
  String? metaFolderId = 'folder-meta';
  bool shouldFail = false;

  @override
  Future<String?> findFolder(String name, {String? parentId}) async {
    if (shouldFail) throw Exception('API error');
    switch (name) {
      case 'Vael':
        return vaelFolderId;
      case 'changesets':
        return changesetsFolderId;
      case 'snapshots':
        return snapshotsFolderId;
      case '.meta':
        return metaFolderId;
      default:
        return null;
    }
  }

  @override
  Future<String> createFolder(String name, {String? parentId}) async {
    final id = 'folder-$name';
    return id;
  }

  @override
  Future<void> uploadFile(
    String name,
    Uint8List data, {
    String? parentId,
  }) async {
    if (shouldFail) throw Exception('Upload failed');
    files[name] = MockFile(name: name, data: data, parentId: parentId);
  }

  @override
  Future<void> updateFile(String fileId, Uint8List data) async {
    if (shouldFail) throw Exception('Update failed');
    final existing = files.values.where((f) => f.name == fileId).toList();
    if (existing.isNotEmpty) {
      files[fileId] = MockFile(name: fileId, data: data);
    } else {
      files[fileId] = MockFile(name: fileId, data: data);
    }
  }

  @override
  Future<Uint8List> downloadFile(String fileId) async {
    if (shouldFail) throw Exception('Download failed');
    return files[fileId]?.data ?? Uint8List(0);
  }

  @override
  Future<List<CloudFileEntry>> listFiles(
    String parentId, {
    DateTime? modifiedAfter,
  }) async {
    if (shouldFail) throw Exception('List failed');
    return files.values
        .where((f) => f.parentId == parentId)
        .where(
          (f) => modifiedAfter == null || f.modifiedTime.isAfter(modifiedAfter),
        )
        .map(
          (f) => CloudFileEntry(
            id: f.name,
            name: f.name,
            modifiedTime: f.modifiedTime,
          ),
        )
        .toList();
  }

  @override
  Future<String?> findFile(String name, {String? parentId}) async {
    final match = files.values
        .where((f) => f.name == name && f.parentId == parentId)
        .toList();
    return match.isNotEmpty ? match.first.name : null;
  }
}

class MockFile {
  final String name;
  final Uint8List data;
  final String? parentId;
  final DateTime modifiedTime;

  MockFile({
    required this.name,
    required this.data,
    this.parentId,
    DateTime? modifiedTime,
  }) : modifiedTime = modifiedTime ?? DateTime.now().toUtc();
}

void main() {
  group('GoogleDriveStorage', () {
    late GoogleDriveStorage storage;
    late MockDriveApi mockApi;

    setUp(() {
      mockApi = MockDriveApi();
      storage = GoogleDriveStorage(api: mockApi);
    });

    test('uploads changeset to changesets folder', () async {
      final data = Uint8List.fromList([1, 2, 3]);
      await storage.uploadChangeset('test.enc', data);

      expect(mockApi.files, contains('test.enc'));
    });

    test('lists changesets from Drive', () async {
      mockApi.files['cs1.enc'] = MockFile(
        name: 'cs1.enc',
        data: Uint8List.fromList([1]),
        parentId: 'folder-changesets',
      );
      mockApi.files['cs2.enc'] = MockFile(
        name: 'cs2.enc',
        data: Uint8List.fromList([2]),
        parentId: 'folder-changesets',
      );

      final entries = await storage.listChangesets();
      expect(entries, hasLength(2));
    });

    test('downloads file by ID', () async {
      final data = Uint8List.fromList([10, 20, 30]);
      mockApi.files['cs1.enc'] = MockFile(name: 'cs1.enc', data: data);

      final downloaded = await storage.downloadFile('cs1.enc');
      expect(downloaded, equals(data));
    });

    test('uploads snapshot to snapshots folder', () async {
      final data = Uint8List.fromList(List.generate(100, (i) => i));
      await storage.uploadSnapshot(data);

      expect(mockApi.files, contains('latest.enc'));
    });

    test('downloads snapshot', () async {
      final data = Uint8List.fromList([5, 10, 15]);
      mockApi.files['latest.enc'] = MockFile(
        name: 'latest.enc',
        data: data,
        parentId: 'folder-snapshots',
      );

      final downloaded = await storage.downloadSnapshot();
      expect(downloaded, equals(data));
    });

    test('returns null when no snapshot exists', () async {
      final result = await storage.downloadSnapshot();
      expect(result, isNull);
    });

    test('reads manifest JSON', () async {
      final manifest = {'family_id': 'f-001', 'schema_version': 5};
      mockApi.files['manifest.json'] = MockFile(
        name: 'manifest.json',
        data: Uint8List.fromList(utf8.encode(jsonEncode(manifest))),
        parentId: 'folder-meta',
      );

      final result = await storage.readManifest();
      expect(result, isNotNull);
      expect(result!['family_id'], 'f-001');
    });

    test('returns null manifest when none exists', () async {
      final result = await storage.readManifest();
      expect(result, isNull);
    });

    test('writes manifest JSON', () async {
      final manifest = {'family_id': 'f-001', 'wrapped_fek': 'abc123'};
      await storage.writeManifest(manifest);

      expect(mockApi.files, contains('manifest.json'));
    });

    test('handles API errors gracefully', () async {
      mockApi.shouldFail = true;

      expect(() => storage.listChangesets(), throwsException);
    });
  });
}
