import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/sync/manifest.dart';
import 'package:vael/core/sync/sync_orchestrator.dart';
import 'package:vael/features/settings/screens/family_backup_screen.dart';

void main() {
  ManifestStatus makeStatus({
    bool isAdmin = true,
    int memberCount = 2,
    int fekGeneration = 1,
  }) {
    return ManifestStatus(
      memberCount: memberCount,
      isAdmin: isAdmin,
      fekGeneration: fekGeneration,
      ownerEmail: 'admin@test.com',
      members: [
        MemberEntry(
          userId: 'u-admin',
          email: 'admin@test.com',
          role: 'admin',
          wrappedFek: Uint8List(60),
          fekSalt: Uint8List(32),
          addedAt: DateTime.utc(2026, 3, 20),
          addedBy: 'u-admin',
          lastSyncAt: DateTime.now().toUtc().subtract(
            const Duration(minutes: 5),
          ),
        ),
        if (memberCount >= 2)
          MemberEntry(
            userId: 'u-member',
            email: 'member@test.com',
            role: 'member',
            wrappedFek: Uint8List(60),
            fekSalt: Uint8List(32),
            addedAt: DateTime.utc(2026, 3, 21),
            addedBy: 'u-admin',
            lastSyncAt: DateTime.now().toUtc().subtract(
              const Duration(hours: 1),
            ),
          ),
      ],
    );
  }

  Widget buildScreen({
    ManifestStatus? manifestStatus,
    SyncStatus? syncStatus,
    String currentUserId = 'u-admin',
    VoidCallback? onAddMember,
    VoidCallback? onTransferOwnership,
    VoidCallback? onCreateBackup,
    void Function(MemberEntry)? onRemoveMember,
  }) {
    return MaterialApp(
      home: FamilyBackupScreen(
        manifestStatus: manifestStatus ?? makeStatus(),
        syncStatus:
            syncStatus ?? SyncStatus(deviceId: 'device-A', pendingChanges: 0),
        currentUserId: currentUserId,
        onAddMember: onAddMember ?? () {},
        onTransferOwnership: onTransferOwnership ?? () {},
        onCreateBackup: onCreateBackup ?? () {},
        onRemoveMember: onRemoveMember ?? (_) {},
      ),
    );
  }

  group('FamilyBackupScreen', () {
    testWidgets('displays owner email in storage card', (tester) async {
      await tester.pumpWidget(buildScreen());
      expect(find.text('admin@test.com'), findsWidgets);
    });

    testWidgets('displays member count in section header', (tester) async {
      await tester.pumpWidget(buildScreen());
      expect(find.text('Members (2)'), findsOneWidget);
    });

    testWidgets('shows member emails', (tester) async {
      await tester.pumpWidget(buildScreen());
      expect(find.text('member@test.com'), findsOneWidget);
    });

    testWidgets('marks current user with (you)', (tester) async {
      await tester.pumpWidget(buildScreen());
      expect(find.text('(you)'), findsOneWidget);
    });

    testWidgets('shows admin controls when user is admin', (tester) async {
      await tester.pumpWidget(buildScreen());
      expect(find.text('Add Member'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);
    });

    testWidgets('hides admin controls when user is not admin', (tester) async {
      await tester.pumpWidget(
        buildScreen(
          manifestStatus: makeStatus(isAdmin: false),
          currentUserId: 'u-member',
        ),
      );
      expect(find.text('Add Member'), findsNothing);
      expect(find.text('Transfer'), findsNothing);
    });

    testWidgets('shows backup button for all users', (tester) async {
      await tester.pumpWidget(
        buildScreen(manifestStatus: makeStatus(isAdmin: false)),
      );
      expect(find.text('Create Backup Now'), findsOneWidget);
    });

    testWidgets('shows encryption generation', (tester) async {
      await tester.pumpWidget(
        buildScreen(manifestStatus: makeStatus(fekGeneration: 3)),
      );
      expect(find.textContaining('gen 3'), findsOneWidget);
    });

    testWidgets('shows sync status summary', (tester) async {
      await tester.pumpWidget(
        buildScreen(
          syncStatus: SyncStatus(deviceId: 'device-A', pendingChanges: 3),
        ),
      );
      expect(find.textContaining('3 changes'), findsOneWidget);
    });

    testWidgets('shows remove button for non-self members when admin', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen());
      // The remove icon button should be present for the non-current member
      expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
    });

    testWidgets('onAddMember callback fires on button tap', (tester) async {
      var called = false;
      await tester.pumpWidget(buildScreen(onAddMember: () => called = true));
      await tester.tap(find.text('Add Member'));
      expect(called, isTrue);
    });

    testWidgets('onCreateBackup callback fires on button tap', (tester) async {
      var called = false;
      await tester.pumpWidget(buildScreen(onCreateBackup: () => called = true));
      await tester.scrollUntilVisible(find.text('Create Backup Now'), 200);
      await tester.tap(find.text('Create Backup Now'));
      expect(called, isTrue);
    });

    testWidgets('displays member roles', (tester) async {
      await tester.pumpWidget(buildScreen());
      expect(find.textContaining('Admin'), findsWidgets);
      expect(find.textContaining('Member'), findsWidgets);
    });
  });
}
