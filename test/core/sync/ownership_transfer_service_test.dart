import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/sync/drive_permission_service.dart';
import 'package:vael/core/sync/manifest.dart';
import 'package:vael/core/sync/ownership_transfer_service.dart';

class MockPermissionAdapter implements DrivePermissionAdapter {
  final permissions = <DrivePermission>[];
  bool shouldFail = false;
  int? failWithCode;
  bool transferCalled = false;

  @override
  Future<DrivePermission> shareFolder({
    required String folderId,
    required String email,
    required String role,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> revokePermission({
    required String folderId,
    required String permissionId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<DrivePermission>> listPermissions({
    required String folderId,
  }) async {
    if (shouldFail) {
      throw DriveApiException(code: failWithCode ?? 500, message: 'fail');
    }
    return List.unmodifiable(permissions);
  }

  @override
  Future<void> transferOwnership({
    required String folderId,
    required String permissionId,
  }) async {
    if (shouldFail) {
      throw DriveApiException(code: failWithCode ?? 500, message: 'fail');
    }
    transferCalled = true;
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

ManifestV2 _makeManifest() {
  return ManifestV2(
    familyId: 'family-001',
    owner: ManifestOwner(userId: 'u-admin', email: 'admin@test.com'),
    members: {
      'u-admin': MemberEntry(
        userId: 'u-admin',
        email: 'admin@test.com',
        role: 'admin',
        wrappedFek: Uint8List(60),
        fekSalt: Uint8List(32),
        addedAt: DateTime.utc(2026, 3, 20),
        addedBy: 'u-admin',
      ),
      'u-member': MemberEntry(
        userId: 'u-member',
        email: 'member@test.com',
        role: 'member',
        wrappedFek: Uint8List(60),
        fekSalt: Uint8List(32),
        addedAt: DateTime.utc(2026, 3, 21),
        addedBy: 'u-admin',
      ),
    },
  );
}

void main() {
  group('OwnershipTransferService', () {
    late OwnershipTransferService service;
    late MockPermissionAdapter mockAdapter;
    late DrivePermissionService permissionService;

    setUp(() {
      mockAdapter = MockPermissionAdapter();
      mockAdapter.permissions.addAll([
        DrivePermission(
          id: 'perm-admin',
          email: 'admin@test.com',
          role: 'owner',
          type: 'user',
        ),
        DrivePermission(
          id: 'perm-member',
          email: 'member@test.com',
          role: 'writer',
          type: 'user',
        ),
      ]);
      permissionService = DrivePermissionService(adapter: mockAdapter);
      service = OwnershipTransferService(permissionService: permissionService);
    });

    test('validates new owner is an active member', () async {
      final manifest = _makeManifest();

      final result = await service.validateTransfer(
        manifest: manifest,
        currentUserId: 'u-admin',
        newOwnerId: 'u-nonexistent',
      );

      expect(result.isValid, isFalse);
      expect(result.reason, contains('not an active member'));
    });

    test('validates only admin can initiate transfer', () async {
      final manifest = _makeManifest();

      final result = await service.validateTransfer(
        manifest: manifest,
        currentUserId: 'u-member',
        newOwnerId: 'u-admin',
      );

      expect(result.isValid, isFalse);
      expect(result.reason, contains('Only the current admin'));
    });

    test('validates cannot transfer to yourself', () async {
      final manifest = _makeManifest();

      final result = await service.validateTransfer(
        manifest: manifest,
        currentUserId: 'u-admin',
        newOwnerId: 'u-admin',
      );

      expect(result.isValid, isFalse);
      expect(result.reason, contains('yourself'));
    });

    test('validates transfer to active member succeeds', () async {
      final manifest = _makeManifest();

      final result = await service.validateTransfer(
        manifest: manifest,
        currentUserId: 'u-admin',
        newOwnerId: 'u-member',
      );

      expect(result.isValid, isTrue);
    });

    test('executeTransfer updates manifest ownership and roles', () async {
      final manifest = _makeManifest();

      final result = await service.executeTransfer(
        manifest: manifest,
        folderId: 'folder-123',
        currentUserId: 'u-admin',
        newOwnerId: 'u-member',
      );

      expect(result.updatedManifest.owner.userId, 'u-member');
      expect(result.updatedManifest.members['u-member']!.role, 'admin');
      expect(result.updatedManifest.members['u-admin']!.role, 'member');
    });

    test('executeTransfer calls Drive API ownership transfer', () async {
      final manifest = _makeManifest();

      await service.executeTransfer(
        manifest: manifest,
        folderId: 'folder-123',
        currentUserId: 'u-admin',
        newOwnerId: 'u-member',
      );

      expect(mockAdapter.transferCalled, isTrue);
    });

    test(
      'executeTransfer does not update manifest if Drive API fails',
      () async {
        final manifest = _makeManifest();
        mockAdapter.shouldFail = true;
        mockAdapter.failWithCode = 403;

        expect(
          () => service.executeTransfer(
            manifest: manifest,
            folderId: 'folder-123',
            currentUserId: 'u-admin',
            newOwnerId: 'u-member',
          ),
          throwsA(isA<SyncPermissionError>()),
        );
      },
    );

    test('executeTransfer fails for revoked member', () async {
      var manifest = _makeManifest();
      manifest = manifest.revokeMember('u-member');

      expect(
        () => service.executeTransfer(
          manifest: manifest,
          folderId: 'folder-123',
          currentUserId: 'u-admin',
          newOwnerId: 'u-member',
        ),
        throwsA(isA<TransferValidationError>()),
      );
    });

    test('TransferResult contains audit entry', () async {
      final manifest = _makeManifest();

      final result = await service.executeTransfer(
        manifest: manifest,
        folderId: 'folder-123',
        currentUserId: 'u-admin',
        newOwnerId: 'u-member',
      );

      expect(result.auditEntry.action, 'OWNERSHIP_TRANSFERRED');
      expect(result.auditEntry.fromUserId, 'u-admin');
      expect(result.auditEntry.toUserId, 'u-member');
      expect(result.auditEntry.timestamp, isNotNull);
    });
  });
}
