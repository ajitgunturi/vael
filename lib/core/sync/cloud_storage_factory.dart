import 'dart:io' show Platform;

import 'cloud_storage_interface.dart';
import 'google_drive_storage.dart';
import 'icloud_platform_channel.dart';
import 'icloud_storage.dart';

/// Creates the appropriate [CloudStorageInterface] for the selected provider.
class CloudStorageFactory {
  /// Returns the available providers for the current platform.
  static List<CloudProvider> availableProviders() {
    final providers = [CloudProvider.googleDrive];
    if (Platform.isIOS || Platform.isMacOS) {
      providers.add(CloudProvider.iCloudDrive);
    }
    return providers;
  }

  /// Creates a storage instance for the given provider.
  static CloudStorageInterface create(
    CloudProvider provider, {
    DriveApiAdapter? driveApiAdapter,
    ICloudPlatformChannel? iCloudChannel,
  }) {
    switch (provider) {
      case CloudProvider.googleDrive:
        if (driveApiAdapter == null) {
          throw ArgumentError('driveApiAdapter required for Google Drive');
        }
        return GoogleDriveStorage(api: driveApiAdapter);
      case CloudProvider.iCloudDrive:
        return ICloudStorage(
          platform: iCloudChannel ?? ICloudPlatformChannel(),
        );
    }
  }
}
