import 'drive_permission_service.dart';
import 'manifest.dart';

/// Validation result for an ownership transfer request.
class TransferValidation {
  final bool isValid;
  final String? reason;

  TransferValidation.valid() : isValid = true, reason = null;
  TransferValidation.invalid(this.reason) : isValid = false;
}

/// Error thrown when transfer validation fails.
class TransferValidationError implements Exception {
  final String reason;

  TransferValidationError(this.reason);

  @override
  String toString() => 'TransferValidationError: $reason';
}

/// Audit log entry for an ownership transfer.
class TransferAuditEntry {
  final String action;
  final String fromUserId;
  final String toUserId;
  final DateTime timestamp;

  TransferAuditEntry({
    required this.action,
    required this.fromUserId,
    required this.toUserId,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'action': action,
    'from_user_id': fromUserId,
    'to_user_id': toUserId,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Result of a successful ownership transfer.
class TransferResult {
  final ManifestV2 updatedManifest;
  final TransferAuditEntry auditEntry;

  TransferResult({required this.updatedManifest, required this.auditEntry});
}

/// Orchestrates Drive folder ownership transfer with manifest update.
///
/// Coordinates three systems:
/// 1. Drive Permissions API — Google-level ownership transfer
/// 2. ManifestV2 — role swap and owner block update
/// 3. Audit trail — records the transfer event
///
/// If the Drive API call fails, the manifest is NOT updated (saga pattern).
class OwnershipTransferService {
  final DrivePermissionService permissionService;

  OwnershipTransferService({required this.permissionService});

  /// Validates that a transfer can proceed without executing it.
  Future<TransferValidation> validateTransfer({
    required ManifestV2 manifest,
    required String currentUserId,
    required String newOwnerId,
  }) async {
    if (manifest.owner.userId != currentUserId) {
      return TransferValidation.invalid(
        'Only the current admin can initiate ownership transfer.',
      );
    }

    if (currentUserId == newOwnerId) {
      return TransferValidation.invalid(
        'Cannot transfer ownership to yourself.',
      );
    }

    final newOwner = manifest.members[newOwnerId];
    if (newOwner == null || newOwner.status != MemberStatus.active) {
      return TransferValidation.invalid(
        '$newOwnerId is not an active member of this family.',
      );
    }

    return TransferValidation.valid();
  }

  /// Executes the full ownership transfer: validate → Drive API → manifest.
  ///
  /// Throws [TransferValidationError] if validation fails.
  /// Throws [SyncPermissionError] if the Drive API call fails.
  Future<TransferResult> executeTransfer({
    required ManifestV2 manifest,
    required String folderId,
    required String currentUserId,
    required String newOwnerId,
  }) async {
    // Step 1: Validate
    final validation = await validateTransfer(
      manifest: manifest,
      currentUserId: currentUserId,
      newOwnerId: newOwnerId,
    );
    if (!validation.isValid) {
      throw TransferValidationError(validation.reason!);
    }

    // Step 2: Find the new owner's Drive permission ID
    final newOwnerEmail = manifest.members[newOwnerId]!.email;
    final permissions = await permissionService.listMembers(folderId: folderId);
    final targetPerm = permissions.where((p) => p.email == newOwnerEmail);
    if (targetPerm.isEmpty) {
      throw TransferValidationError(
        'New owner does not have Drive access. Invite them first.',
      );
    }

    // Step 3: Execute Drive ownership transfer (may throw SyncPermissionError)
    await permissionService.initiateOwnershipTransfer(
      folderId: folderId,
      permissionId: targetPerm.first.id,
    );

    // Step 4: Update manifest (only if Drive call succeeded)
    final updatedManifest = manifest.transferOwnership(newOwnerId);

    // Step 5: Create audit entry
    final auditEntry = TransferAuditEntry(
      action: 'OWNERSHIP_TRANSFERRED',
      fromUserId: currentUserId,
      toUserId: newOwnerId,
      timestamp: DateTime.now().toUtc(),
    );

    return TransferResult(
      updatedManifest: updatedManifest,
      auditEntry: auditEntry,
    );
  }
}
