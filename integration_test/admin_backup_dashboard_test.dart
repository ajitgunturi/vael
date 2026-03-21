import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:vael/core/sync/manifest.dart';
import 'package:vael/core/sync/sync_orchestrator.dart';
import 'package:vael/features/settings/screens/family_backup_screen.dart';
import 'package:vael/shared/theme/app_theme.dart';

import 'helpers/e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  MemberEntry makeMember({
    required String userId,
    required String email,
    String role = 'member',
    MemberStatus status = MemberStatus.active,
    DateTime? lastSyncAt,
  }) {
    return MemberEntry(
      userId: userId,
      email: email,
      role: role,
      wrappedFek: Uint8List(32),
      fekSalt: Uint8List(16),
      addedAt: DateTime(2025, 1, 1),
      addedBy: 'admin_user',
      lastSyncAt: lastSyncAt,
      status: status,
    );
  }

  Future<void> pumpBackupScreen(
    WidgetTester tester, {
    required ManifestStatus manifestStatus,
    required SyncStatus syncStatus,
    String currentUserId = 'admin_user',
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: FamilyBackupScreen(
          manifestStatus: manifestStatus,
          syncStatus: syncStatus,
          currentUserId: currentUserId,
          onAddMember: () {},
          onTransferOwnership: () {},
          onCreateBackup: () {},
          onRemoveMember: (_) {},
        ),
      ),
    );
    await settle(tester);
  }

  group('Admin Backup Dashboard', () {
    testWidgets('shows storage info, members, and admin controls', (tester) async {
      await pumpBackupScreen(tester,
        manifestStatus: ManifestStatus(
          memberCount: 2,
          isAdmin: true,
          fekGeneration: 1,
          ownerEmail: 'ajit@example.com',
          members: [
            makeMember(userId: 'admin_user', email: 'ajit@example.com', role: 'admin',
              lastSyncAt: DateTime.now().subtract(const Duration(minutes: 5))),
            makeMember(userId: 'member1', email: 'pravi@example.com',
              lastSyncAt: DateTime.now().subtract(const Duration(hours: 2))),
          ],
        ),
        syncStatus: SyncStatus(deviceId: 'dev1', pendingChanges: 0),
      );

      expect(find.text('Family Backup'), findsOneWidget);
      expect(find.text('Storage'), findsOneWidget);
      expect(find.text('ajit@example.com'), findsWidgets);
      expect(find.text('pravi@example.com'), findsOneWidget);
      expect(find.textContaining('Members (2)'), findsOneWidget);

      // Admin controls visible
      expect(find.text('Add Member'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);
      expect(find.text('Create Backup Now'), findsOneWidget);

      // Current user marked with (you)
      expect(find.text('(you)'), findsOneWidget);
    });

    testWidgets('non-admin sees read-only view without controls', (tester) async {
      await pumpBackupScreen(tester,
        manifestStatus: ManifestStatus(
          memberCount: 2,
          isAdmin: false,
          fekGeneration: 1,
          ownerEmail: 'ajit@example.com',
          members: [
            makeMember(userId: 'admin_user', email: 'ajit@example.com', role: 'admin'),
            makeMember(userId: 'member1', email: 'pravi@example.com'),
          ],
        ),
        syncStatus: SyncStatus(deviceId: 'dev2', pendingChanges: 3),
        currentUserId: 'member1',
      );

      // No admin controls
      expect(find.text('Add Member'), findsNothing);
      expect(find.text('Transfer'), findsNothing);

      // Members still visible
      expect(find.textContaining('Members (2)'), findsOneWidget);

      // Remove button should not appear for non-admin
      expect(find.byIcon(Icons.remove_circle_outline), findsNothing);
    });

    testWidgets('revoked member shows error styling', (tester) async {
      await pumpBackupScreen(tester,
        manifestStatus: ManifestStatus(
          memberCount: 2,
          isAdmin: true,
          fekGeneration: 2,
          ownerEmail: 'ajit@example.com',
          members: [
            makeMember(userId: 'admin_user', email: 'ajit@example.com', role: 'admin'),
            makeMember(userId: 'revoked1', email: 'old@example.com', status: MemberStatus.revoked),
          ],
        ),
        syncStatus: SyncStatus(deviceId: 'dev1', pendingChanges: 0),
      );

      expect(find.text('old@example.com'), findsOneWidget);
      expect(find.textContaining('Revoked'), findsOneWidget);
      // FEK generation should reflect rotation
      expect(find.textContaining('gen 2'), findsOneWidget);
    });
  });
}
