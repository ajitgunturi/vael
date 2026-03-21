import 'package:flutter/services.dart';

/// Platform channel for iCloud Drive operations that require native APIs.
///
/// File read/write uses dart:io directly on the ubiquity container path.
/// This channel handles only the operations that require native platform APIs:
/// - Discovering the ubiquity container URL
/// - Checking iCloud availability
/// - Triggering downloads for evicted files
class ICloudPlatformChannel {
  final MethodChannel _channel;

  ICloudPlatformChannel({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('com.vael.vael/icloud');

  /// Returns the absolute path to the iCloud ubiquity container, or null
  /// if iCloud is not available.
  ///
  /// On iOS: `NSFileManager.url(forUbiquityContainerIdentifier:)`
  /// On macOS: `~/Library/Mobile Documents/iCloud~com~vael~vael/`
  Future<String?> getContainerPath() async {
    return await _channel.invokeMethod<String>('getContainerPath');
  }

  /// Whether the user is signed into iCloud on this device.
  Future<bool> isAvailable() async {
    return await _channel.invokeMethod<bool>('isAvailable') ?? false;
  }

  /// Triggers download of an evicted (cloud-only) file.
  ///
  /// iOS may evict local copies of iCloud files to free storage.
  /// This tells the OS to re-download the file. Returns true if the
  /// download was initiated, false if the file was already local.
  Future<bool> startDownloading(String path) async {
    return await _channel.invokeMethod<bool>('startDownloading', {
          'path': path,
        }) ??
        false;
  }

  /// Checks whether a file exists locally (not evicted).
  Future<bool> isFileLocal(String path) async {
    return await _channel.invokeMethod<bool>('isFileLocal', {'path': path}) ??
        false;
  }
}
