import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/sync/icloud_platform_channel.dart';
import 'package:vael/core/sync/icloud_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ICloudStorage', () {
    late ICloudStorage storage;
    late Directory tempDir;
    late String containerPath;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('vael_icloud_test_');
      containerPath = tempDir.path;

      // Mock platform channel
      final channel = MethodChannel('com.vael.vael/icloud');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            switch (methodCall.method) {
              case 'getContainerPath':
                return containerPath;
              case 'isAvailable':
                return true;
              case 'startDownloading':
                return true;
              case 'isFileLocal':
                final path = (methodCall.arguments as Map)['path'] as String;
                return File(path).existsSync();
              default:
                return null;
            }
          });

      storage = ICloudStorage(platform: ICloudPlatformChannel());
    });

    tearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('com.vael.vael/icloud'),
            null,
          );
      await tempDir.delete(recursive: true);
    });

    test('creates folder structure on first use', () async {
      await storage.uploadChangeset('test.enc', Uint8List.fromList([1, 2, 3]));

      expect(
        await Directory('$containerPath/Vael/changesets').exists(),
        isTrue,
      );
    });

    test('uploads and lists changesets', () async {
      final data = Uint8List.fromList([1, 2, 3]);
      await storage.uploadChangeset('cs1.enc', data);
      await storage.uploadChangeset('cs2.enc', data);

      final entries = await storage.listChangesets();
      expect(entries, hasLength(2));
      expect(entries.map((e) => e.name), containsAll(['cs1.enc', 'cs2.enc']));
    });

    test('downloads file by path', () async {
      final data = Uint8List.fromList([10, 20, 30]);
      await storage.uploadChangeset('dl-test.enc', data);

      final entries = await storage.listChangesets();
      final downloaded = await storage.downloadFile(entries.first.id);
      expect(downloaded, equals(data));
    });

    test('uploads and downloads snapshot', () async {
      final data = Uint8List.fromList(List.generate(256, (i) => i));
      await storage.uploadSnapshot(data);

      final downloaded = await storage.downloadSnapshot();
      expect(downloaded, isNotNull);
      expect(downloaded, equals(data));
    });

    test('returns null when no snapshot exists', () async {
      final result = await storage.downloadSnapshot();
      expect(result, isNull);
    });

    test('reads and writes manifest', () async {
      final manifest = {'family_id': 'f-001', 'provider': 'icloud_drive'};
      await storage.writeManifest(manifest);

      final result = await storage.readManifest();
      expect(result, isNotNull);
      expect(result!['family_id'], 'f-001');
      expect(result['provider'], 'icloud_drive');
    });

    test('returns null manifest when none exists', () async {
      final result = await storage.readManifest();
      expect(result, isNull);
    });

    test('listChangesets filters by date', () async {
      final data = Uint8List.fromList([1]);
      await storage.uploadChangeset('old.enc', data);

      // Wait briefly so timestamps differ
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final cutoff = DateTime.now();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await storage.uploadChangeset('new.enc', data);

      final entries = await storage.listChangesets(after: cutoff);
      expect(entries, hasLength(1));
      expect(entries.first.name, 'new.enc');
    });

    test('file IDs are absolute paths', () async {
      await storage.uploadChangeset('path-test.enc', Uint8List.fromList([1]));

      final entries = await storage.listChangesets();
      expect(entries.first.id, startsWith('/'));
      expect(entries.first.id, contains('Vael/changesets/path-test.enc'));
    });
  });

  group('ICloudPlatformChannel', () {
    test('returns container path from platform', () async {
      final channel = MethodChannel('com.vael.vael/icloud');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'getContainerPath') {
              return '/mock/icloud/container';
            }
            return null;
          });

      final platform = ICloudPlatformChannel();
      final path = await platform.getContainerPath();
      expect(path, '/mock/icloud/container');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('returns null when iCloud unavailable', () async {
      final channel = MethodChannel('com.vael.vael/icloud');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'getContainerPath') return null;
            if (methodCall.method == 'isAvailable') return false;
            return null;
          });

      final platform = ICloudPlatformChannel();
      expect(await platform.getContainerPath(), isNull);
      expect(await platform.isAvailable(), isFalse);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });
  });
}
