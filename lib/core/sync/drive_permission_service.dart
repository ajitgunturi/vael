/// Exception thrown by the Drive API adapter for HTTP-level errors.
class DriveApiException implements Exception {
  final int code;
  final String message;

  DriveApiException({required this.code, required this.message});

  @override
  String toString() => 'DriveApiException($code): $message';
}

/// A single permission entry on a Google Drive file/folder.
class DrivePermission {
  final String id;
  final String email;
  final String role;
  final String type;

  DrivePermission({
    required this.id,
    required this.email,
    required this.role,
    required this.type,
  });
}

/// Abstraction over the Google Drive Permissions API for testability.
abstract class DrivePermissionAdapter {
  Future<DrivePermission> shareFolder({
    required String folderId,
    required String email,
    required String role,
  });

  Future<void> revokePermission({
    required String folderId,
    required String permissionId,
  });

  Future<List<DrivePermission>> listPermissions({required String folderId});

  Future<void> transferOwnership({
    required String folderId,
    required String permissionId,
  });
}

/// Categorized permission error types for actionable UI messages.
enum SyncPermissionErrorType {
  accessDenied,
  folderNotFound,
  invalidRequest,
  unknown,
}

/// Domain-level permission error with actionable user messaging.
class SyncPermissionError implements Exception {
  final SyncPermissionErrorType type;
  final String message;

  SyncPermissionError({required this.type, required this.message});

  String get actionableMessage {
    switch (type) {
      case SyncPermissionErrorType.accessDenied:
        return 'Drive access denied. Ask your family admin to re-share the backup folder.';
      case SyncPermissionErrorType.folderNotFound:
        return 'Backup folder not found. It may have been moved or deleted. Contact your family admin.';
      case SyncPermissionErrorType.invalidRequest:
        return 'Invalid request. Please check the email address and try again.';
      case SyncPermissionErrorType.unknown:
        return 'An unexpected error occurred. Please try again later.';
    }
  }

  @override
  String toString() => 'SyncPermissionError(${type.name}): $message';
}

/// Service layer for managing Drive folder permissions.
///
/// Wraps [DrivePermissionAdapter] with domain-level error mapping
/// and enforces Vael's permission model (admin = owner, members = writer).
class DrivePermissionService {
  final DrivePermissionAdapter adapter;

  DrivePermissionService({required this.adapter});

  /// Shares the Vael folder with a new member as "writer".
  Future<DrivePermission> inviteMember({
    required String folderId,
    required String email,
  }) async {
    return _withErrorMapping(
      () =>
          adapter.shareFolder(folderId: folderId, email: email, role: 'writer'),
    );
  }

  /// Revokes a member's access to the Vael folder.
  Future<void> revokeMember({
    required String folderId,
    required String permissionId,
  }) async {
    return _withErrorMapping(
      () => adapter.revokePermission(
        folderId: folderId,
        permissionId: permissionId,
      ),
    );
  }

  /// Lists all current permissions on the Vael folder.
  Future<List<DrivePermission>> listMembers({required String folderId}) async {
    return _withErrorMapping(() => adapter.listPermissions(folderId: folderId));
  }

  /// Initiates ownership transfer of the Vael folder.
  Future<void> initiateOwnershipTransfer({
    required String folderId,
    required String permissionId,
  }) async {
    return _withErrorMapping(
      () => adapter.transferOwnership(
        folderId: folderId,
        permissionId: permissionId,
      ),
    );
  }

  Future<T> _withErrorMapping<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DriveApiException catch (e) {
      throw SyncPermissionError(
        type: _mapErrorCode(e.code),
        message: e.message,
      );
    }
  }

  static SyncPermissionErrorType _mapErrorCode(int code) {
    switch (code) {
      case 403:
        return SyncPermissionErrorType.accessDenied;
      case 404:
        return SyncPermissionErrorType.folderNotFound;
      case 400:
        return SyncPermissionErrorType.invalidRequest;
      default:
        return SyncPermissionErrorType.unknown;
    }
  }
}
