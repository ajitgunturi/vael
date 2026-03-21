import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:vael/core/sync/sync_orchestrator.dart';
import 'package:vael/features/settings/screens/sync_status_screen.dart';
import 'package:vael/shared/theme/app_theme.dart';

import 'helpers/e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpSyncStatus(
    WidgetTester tester, {
    required SyncStatus status,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: SyncStatusScreen(
          status: status,
          onPushNow: () {},
          onPullNow: () {},
          onCreateBackup: () {},
        ),
      ),
    );
    await settle(tester);
  }

  group('Sync Status Screen', () {
    testWidgets('displays device ID and up-to-date status', (tester) async {
      await pumpSyncStatus(tester, status: SyncStatus(
        deviceId: 'device_abc123',
        pendingChanges: 0,
        lastPushAt: DateTime(2026, 3, 20, 14, 30),
        lastPullAt: DateTime(2026, 3, 20, 14, 25),
      ));

      expect(find.text('Sync Status'), findsOneWidget);
      expect(find.text('device_abc123'), findsOneWidget);
      expect(find.text('Up to date'), findsOneWidget);
    });

    testWidgets('shows pending changes count', (tester) async {
      await pumpSyncStatus(tester, status: SyncStatus(
        deviceId: 'device_xyz',
        pendingChanges: 7,
      ));

      expect(find.text('7 pending'), findsOneWidget);
    });

    testWidgets('shows push and pull timestamps', (tester) async {
      await pumpSyncStatus(tester, status: SyncStatus(
        deviceId: 'dev1',
        pendingChanges: 0,
        lastPushAt: DateTime(2026, 3, 15, 10, 45),
        lastPullAt: DateTime(2026, 3, 15, 9, 30),
      ));

      expect(find.textContaining('15/3/2026'), findsWidgets);
      expect(find.text('Push Now'), findsOneWidget);
      expect(find.text('Pull Now'), findsOneWidget);
      expect(find.text('Create Backup'), findsOneWidget);
    });
  });
}
