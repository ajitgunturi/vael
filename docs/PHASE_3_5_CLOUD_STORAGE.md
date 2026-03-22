# Cloud Storage Abstraction — Multi-Provider Backup

## Problem Statement

Vael currently hardcodes Google Drive as the only cloud backup provider. Users on Apple devices have iCloud Drive built into their OS — requiring them to set up Google OAuth for what their device already provides natively is unnecessary friction. The storage layer should be provider-agnostic: users pick their preferred cloud, and Vael treats it as blind encrypted storage regardless.

## Design Principle

> Cloud providers are interchangeable blind storage. The encryption layer — not the provider — is the trust boundary. Switching providers must not require re-encryption, re-keying, or data migration.

This means:
- The FEK, manifest, changeset format, and snapshot format are provider-independent
- Only the transport layer (how bytes get to/from the cloud) changes per provider
- No feature parity required — each provider supports what it natively can
- Provider selection is per-family, not per-device (all family members use the same provider)

## Provider Comparison

| Capability | Google Drive | iCloud Drive |
|-----------|-------------|--------------|
| **Platforms** | iOS, Android, macOS, web | iOS, macOS only |
| **Auth** | OAuth 2.0 (Google Sign-In) | Automatic (device Apple ID) |
| **API model** | HTTP REST API | File system (NSFileManager / ubiquity container) |
| **Sharing** | Permissions API (email-based) | iCloud Sharing (CloudKit CKShare) |
| **Setup cost** | OAuth consent screen + client IDs | Zero — works with Apple ID on device |
| **Folder structure** | Virtual folders via API | Real directories on disk |
| **File IDs** | Opaque Google-assigned IDs | File paths (relative to container) |
| **Offline** | Manual cache management | OS-managed sync with local replica |
| **Free tier** | 15 GB (shared with Gmail, Photos) | 5 GB (shared with Photos, backups) |
| **Family sharing** | Drive folder sharing | iCloud Shared Folder or CloudKit sharing zone |
| **Android support** | Yes | No |

### Key Implication

iCloud is Apple-only. This means:
- **Android users** → Google Drive is the only option
- **Apple-only families** → can choose either Google Drive or iCloud Drive
- **Mixed families** (some Android, some Apple) → must use Google Drive

The provider choice is stored in the manifest and enforced at onboarding: if a family uses iCloud, only Apple devices can join.

## Architecture

### Current: Google-Coupled

```
SyncOrchestrator → DriveClientInterface → DriveClient (Google)
                                              ↓
                                        DriveApiAdapter (googleapis)
```

### Proposed: Provider-Agnostic

```
SyncOrchestrator → CloudStorageInterface → GoogleDriveStorage
                                         → ICloudStorage

                   CloudStorageFactory.create(provider) → concrete impl
```

### Interface Rename & Generalization

The current `DriveClientInterface` becomes `CloudStorageInterface` — the contract stays almost identical, but naming and types become provider-neutral:

```dart
/// Provider-agnostic cloud storage interface.
///
/// Implementations handle the transport of encrypted bytes to/from
/// a cloud provider. All data is encrypted before reaching this layer —
/// implementations never see plaintext.
abstract class CloudStorageInterface {
  /// Upload an encrypted changeset file.
  Future<void> uploadChangeset(String fileName, Uint8List data);

  /// Download a file by its provider-specific identifier.
  Future<Uint8List> downloadFile(String fileId);

  /// List changeset files, optionally filtered by modification time.
  Future<List<CloudFileEntry>> listChangesets({DateTime? after});

  /// Upload an encrypted full database snapshot.
  Future<void> uploadSnapshot(Uint8List data);

  /// Download the latest encrypted snapshot, or null if none exists.
  Future<Uint8List?> downloadSnapshot();

  /// Read the family manifest (member list, wrapped FEKs, owner info).
  Future<Map<String, dynamic>?> readManifest();

  /// Write the family manifest.
  Future<void> writeManifest(Map<String, dynamic> manifest);

  /// The provider type for display and configuration.
  CloudProvider get provider;

  /// Whether this provider supports family sharing (multi-user access).
  bool get supportsSharing;
}

/// Metadata for a file in cloud storage.
class CloudFileEntry {
  final String id;        // Provider-specific: Google file ID or iCloud path
  final String name;
  final DateTime modifiedTime;

  CloudFileEntry({
    required this.id,
    required this.name,
    required this.modifiedTime,
  });
}

/// Supported cloud storage providers.
enum CloudProvider {
  googleDrive,
  iCloudDrive,
}
```

### Google Drive Implementation

`GoogleDriveStorage` — wraps the existing `DriveClient` logic. Essentially a rename + implementing the new interface:

```dart
class GoogleDriveStorage implements CloudStorageInterface {
  final DriveApiAdapter api;

  @override
  CloudProvider get provider => CloudProvider.googleDrive;

  @override
  bool get supportsSharing => true;

  // ... existing DriveClient methods unchanged
}
```

### iCloud Drive Implementation

iCloud Drive uses the file system — the OS syncs the ubiquity container automatically.

```dart
class ICloudStorage implements CloudStorageInterface {
  // Base directory: the app's iCloud ubiquity container
  // On iOS:  NSFileManager.defaultManager.URLForUbiquityContainerIdentifier
  // On macOS: ~/Library/Mobile Documents/iCloud~com~vael~vael/

  @override
  CloudProvider get provider => CloudProvider.iCloudDrive;

  @override
  bool get supportsSharing => true; // via iCloud Shared Folders

  // Folder structure (same as Google Drive, but real directories):
  // <container>/
  // ├── .meta/manifest.json
  // ├── changesets/*.enc
  // └── snapshots/latest.enc
}
```

**How iCloud file operations differ from Google Drive:**

| Operation | Google Drive | iCloud Drive |
|-----------|-------------|--------------|
| Upload changeset | HTTP POST to googleapis | `File.writeAsBytes()` to ubiquity container |
| Download file | HTTP GET by file ID | `File.readAsBytes()` by path |
| List changesets | HTTP GET with query params | `Directory.list()` with date filter |
| Find file | HTTP GET with name query | `File.existsSync()` by path |
| Create folder | HTTP POST (create folder resource) | `Directory.create()` |
| File identity | Google-assigned opaque ID | Relative file path |

**iCloud sync is automatic.** Once a file is written to the ubiquity container, iOS/macOS syncs it to iCloud in the background. There's no explicit "upload" call — the OS handles it. The app just reads/writes local files and the OS propagates changes.

### Platform Channel for iCloud

Flutter doesn't have a first-party iCloud Drive plugin. The implementation requires a platform channel:

```
Dart (ICloudStorage) → MethodChannel → Swift/Kotlin
                                          ↓
                              NSFileManager (ubiquity container)
```

Key native operations:
- `getUbiquityContainerUrl()` — get the iCloud container path
- `isICloudAvailable()` — check if user is signed into iCloud
- `startDownloading(path)` — trigger download of cloud-only files (iOS evicts local copies)
- File read/write can use `dart:io` directly once the container path is known

### Provider Selection Flow

```
First-time family setup:
  1. "Where should Vael store your encrypted backup?"
     ┌─────────────────────────┐
     │  ☁️  Google Drive        │ ← Available on all platforms
     │  Works on Android + iOS │
     │  + macOS                │
     ├─────────────────────────┤
     │  🍎 iCloud Drive        │ ← Only shown on Apple devices
     │  Works on iOS + macOS   │
     │  Zero setup required    │
     └─────────────────────────┘
  2. Selection stored in local preferences AND manifest
  3. All family members must use the same provider

Joining existing family:
  1. App detects provider from manifest
  2. If provider is iCloud but device is Android → block with clear message:
     "This family uses iCloud Drive for backup. iCloud is not available on Android.
      Ask the family admin to switch to Google Drive, or use an Apple device."
```

### Manifest Extension

The manifest gains a `provider` field:

```json
{
  "schema_version": 2,
  "provider": "icloud_drive",
  "family_id": "family-001",
  "owner": { ... },
  "members": { ... }
}
```

This is informational — the manifest itself is stored on whatever provider was chosen. But it's useful for:
- New devices confirming they can access the same provider
- Migration scenarios (future: switching providers)

## iCloud-Specific Considerations

### Authentication

None required from the app. If the user is signed into iCloud on their device (which they are if they set up the device normally), the ubiquity container is available. No OAuth, no consent screens, no client IDs.

Check availability:
```swift
// Swift (platform channel)
FileManager.default.ubiquityIdentityToken != nil
```

### Family Sharing on iCloud

iCloud supports two sharing mechanisms:

1. **iCloud Shared Folders** (iOS 16+, macOS 13+) — share a folder via iCloud with specific people. Recipients get read/write access. The folder owner controls membership. This maps directly to the admin-owns-storage model in Phase 3.5.

2. **CloudKit Sharing Zones** — more granular but requires CloudKit framework. Overkill for Vael's use case.

**Recommendation:** Use iCloud Shared Folders. The admin creates the Vael folder in their iCloud container, then shares it with family members via iCloud sharing. This mirrors the Google Drive permission model.

### Entitlements & Capabilities

The app's Xcode project needs:
- `com.apple.developer.icloud-container-identifiers` → `iCloud.com.vael.vael`
- `com.apple.developer.ubiquity-container-identifiers` → `iCloud.com.vael.vael`
- iCloud capability enabled in Signing & Capabilities

These are configured once in Xcode and the Apple Developer portal — no runtime cost.

### Storage Limits

iCloud free tier is 5 GB (vs Google's 15 GB). Vael's encrypted data is small:
- Typical family: 1,000 transactions/year → ~50 KB per full snapshot
- Changesets: ~1 KB each, dozens per week
- 10 years of data + all changesets: well under 100 MB

Storage is a non-issue for either provider.

### Offline Behavior

iCloud Drive has better offline behavior than Google Drive for Vael's use case:
- Files in the ubiquity container are cached locally by the OS
- Changes written offline sync automatically when connectivity returns
- No explicit "am I online?" checks needed
- The OS shows download progress for files not yet cached

Google Drive requires manual cache management — the app must explicitly download files and handle connectivity.

### File Eviction (iOS)

iOS may evict (remove local copies of) iCloud files to free storage. When the app needs an evicted file:

```swift
// Tell iOS to download the file
try FileManager.default.startDownloadingUbiquitousItem(at: fileURL)
// Then observe NSMetadataQuery for download completion
```

The `ICloudStorage` implementation must handle this transparently — if a file isn't locally available, trigger download and wait.

## What This Does NOT Include

- **Provider migration** (switching from Google Drive to iCloud or vice versa) — this is a future feature that would involve downloading all data from one provider and uploading to another. The encryption layer makes this straightforward (same encrypted bytes, different transport), but the UX needs design.
- **Simultaneous multi-provider** — backup to both Google Drive AND iCloud at once. Not needed; adds complexity with no clear benefit.
- **Feature parity** — iCloud implementation doesn't need Google Drive's permission API integration from Phase 3.5. iCloud uses its own sharing model. Each provider implements what it natively supports.

## Task Breakdown

This work extends Phase 3.5 as an additional wave.

### Wave 6: Cloud Storage Abstraction

| # | Task | Details |
|---|------|---------|
| 6.1 | Rename interface | `DriveClientInterface` → `CloudStorageInterface`, `DriveFileEntry` → `CloudFileEntry`. Update all 11 referencing files |
| 6.2 | Add `CloudProvider` enum | Provider type enum + manifest `provider` field |
| 6.3 | Rename implementation | `DriveClient` → `GoogleDriveStorage`, update import paths |
| 6.4 | Provider selection model | Local preference + manifest field + provider-aware factory |
| 6.5 | Tests | Verify all existing tests pass after rename. Add provider selection tests |

### Wave 7: iCloud Drive Implementation

| # | Task | Details |
|---|------|---------|
| 7.1 | Platform channel | Swift method channel for ubiquity container access, availability check, file download trigger |
| 7.2 | `ICloudStorage` class | Implement `CloudStorageInterface` using file system operations on ubiquity container |
| 7.3 | iCloud entitlements | Configure Xcode project with iCloud container identifiers |
| 7.4 | File eviction handling | Detect non-local files, trigger download, wait for availability |
| 7.5 | Provider selection UI | Setup screen showing available providers per platform |
| 7.6 | Platform guards | Block iCloud selection on Android, show clear messaging |
| 7.7 | Tests | iCloud storage round-trip tests (mock file system), platform guard tests, provider selection UI tests |

## Exit Criteria

- [ ] All sync operations work identically regardless of chosen provider
- [ ] Apple device users can select iCloud Drive with zero OAuth setup
- [ ] Android users see only Google Drive as an option
- [ ] Provider choice stored in manifest and enforced at family join
- [ ] iCloud file eviction handled transparently (no user-visible errors)
- [ ] Existing Google Drive users unaffected by the abstraction rename
- [ ] Mixed platform family (Android + iOS) correctly blocks iCloud selection
