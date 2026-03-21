import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/sync/drive_permission_service.dart';

class MockPermissionAdapter implements DrivePermissionAdapter {
  final permissions = <DrivePermission>[];
  bool shouldFail = false;
  int? failWithCode;

  @override
  Future<DrivePermission> shareFolder({
    required String folderId,
    required String email,
    required String role,
  }) async {
    if (shouldFail) {
      throw DriveApiException(code: failWithCode ?? 500, message: 'API error');
    }
    final perm = DrivePermission(
      id: 'perm-${permissions.length + 1}',
      email: email,
      role: role,
      type: 'user',
    );
    permissions.add(perm);
    return perm;
  }

  @override
  Future<void> revokePermission({
    required String folderId,
    required String permissionId,
  }) async {
    if (shouldFail) {
      throw DriveApiException(code: failWithCode ?? 500, message: 'API error');
    }
    permissions.removeWhere((p) => p.id == permissionId);
  }

  @override
  Future<List<DrivePermission>> listPermissions({
    required String folderId,
  }) async {
    if (shouldFail) {
      throw DriveApiException(code: failWithCode ?? 500, message: 'API error');
    }
    return List.unmodifiable(permissions);
  }

  @override
  Future<void> transferOwnership({
    required String folderId,
    required String permissionId,
  }) async {
    if (shouldFail) {
      throw DriveApiException(code: failWithCode ?? 500, message: 'API error');
    }
    final idx = permissions.indexWhere((p) => p.id == permissionId);
    if (idx >= 0) {
      permissions[idx] = DrivePermission(
        id: permissions[idx].id,
        email: permissions[idx].email,
        role: 'owner',
        type: 'user',
      );
    }
  }
}

void main() {
  group('DrivePermissionService', () {
    late DrivePermissionService service;
    late MockPermissionAdapter mockAdapter;

    setUp(() {
      mockAdapter = MockPermissionAdapter();
      service = DrivePermissionService(adapter: mockAdapter);
    });

    test('inviteMember shares folder with writer role', () async {
      final result = await service.inviteMember(
        folderId: 'folder-123',
        email: 'member@test.com',
      );

      expect(result.email, 'member@test.com');
      expect(result.role, 'writer');
      expect(mockAdapter.permissions, hasLength(1));
    });

    test('revokeMember removes permission', () async {
      final perm = await service.inviteMember(
        folderId: 'folder-123',
        email: 'member@test.com',
      );

      await service.revokeMember(folderId: 'folder-123', permissionId: perm.id);

      expect(mockAdapter.permissions, isEmpty);
    });

    test('listMembers returns current permissions', () async {
      await service.inviteMember(
        folderId: 'folder-123',
        email: 'user-a@test.com',
      );
      await service.inviteMember(
        folderId: 'folder-123',
        email: 'user-b@test.com',
      );

      final members = await service.listMembers(folderId: 'folder-123');
      expect(members, hasLength(2));
      expect(
        members.map((m) => m.email),
        containsAll(['user-a@test.com', 'user-b@test.com']),
      );
    });

    test('initiateOwnershipTransfer changes role to owner', () async {
      final perm = await service.inviteMember(
        folderId: 'folder-123',
        email: 'new-admin@test.com',
      );

      await service.initiateOwnershipTransfer(
        folderId: 'folder-123',
        permissionId: perm.id,
      );

      final updated = mockAdapter.permissions.firstWhere(
        (p) => p.id == perm.id,
      );
      expect(updated.role, 'owner');
    });

    test('maps 403 to SyncPermissionError.accessDenied', () async {
      mockAdapter.shouldFail = true;
      mockAdapter.failWithCode = 403;

      expect(
        () => service.inviteMember(
          folderId: 'folder-123',
          email: 'test@test.com',
        ),
        throwsA(
          isA<SyncPermissionError>().having(
            (e) => e.type,
            'type',
            SyncPermissionErrorType.accessDenied,
          ),
        ),
      );
    });

    test('maps 404 to SyncPermissionError.folderNotFound', () async {
      mockAdapter.shouldFail = true;
      mockAdapter.failWithCode = 404;

      expect(
        () => service.listMembers(folderId: 'nonexistent'),
        throwsA(
          isA<SyncPermissionError>().having(
            (e) => e.type,
            'type',
            SyncPermissionErrorType.folderNotFound,
          ),
        ),
      );
    });

    test('maps 400 to SyncPermissionError.invalidRequest', () async {
      mockAdapter.shouldFail = true;
      mockAdapter.failWithCode = 400;

      expect(
        () => service.inviteMember(folderId: 'folder-123', email: 'bad-email'),
        throwsA(
          isA<SyncPermissionError>().having(
            (e) => e.type,
            'type',
            SyncPermissionErrorType.invalidRequest,
          ),
        ),
      );
    });

    test('maps unknown errors to SyncPermissionError.unknown', () async {
      mockAdapter.shouldFail = true;
      mockAdapter.failWithCode = 500;

      expect(
        () => service.inviteMember(
          folderId: 'folder-123',
          email: 'test@test.com',
        ),
        throwsA(
          isA<SyncPermissionError>().having(
            (e) => e.type,
            'type',
            SyncPermissionErrorType.unknown,
          ),
        ),
      );
    });

    test('SyncPermissionError provides actionable messages', () {
      final error = SyncPermissionError(
        type: SyncPermissionErrorType.accessDenied,
        message: 'Forbidden',
      );

      expect(error.actionableMessage, isNotEmpty);
      expect(error.actionableMessage, contains('admin'));
    });
  });
}
