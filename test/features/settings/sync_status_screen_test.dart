import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/sync/sync_orchestrator.dart';
import 'package:vael/features/settings/screens/sync_status_screen.dart';

void main() {
  group('SyncStatusScreen', () {
    Widget buildScreen(SyncStatus status) {
      return MaterialApp(
        home: SyncStatusScreen(
          status: status,
          onPushNow: () {},
          onPullNow: () {},
          onCreateBackup: () {},
        ),
      );
    }

    testWidgets('displays device ID', (tester) async {
      await tester.pumpWidget(buildScreen(SyncStatus(
        deviceId: 'device-A',
        pendingChanges: 0,
      )));

      expect(find.textContaining('device-A'), findsOneWidget);
    });

    testWidgets('shows pending changes count', (tester) async {
      await tester.pumpWidget(buildScreen(SyncStatus(
        deviceId: 'device-A',
        pendingChanges: 5,
      )));

      expect(find.textContaining('5'), findsOneWidget);
    });

    testWidgets('shows zero pending as synced', (tester) async {
      await tester.pumpWidget(buildScreen(SyncStatus(
        deviceId: 'device-A',
        pendingChanges: 0,
      )));

      expect(find.textContaining('Up to date'), findsOneWidget);
    });

    testWidgets('displays push/pull timestamps', (tester) async {
      await tester.pumpWidget(buildScreen(SyncStatus(
        deviceId: 'device-A',
        pendingChanges: 0,
        lastPushAt: DateTime.utc(2026, 3, 20, 10, 30),
        lastPullAt: DateTime.utc(2026, 3, 20, 11, 0),
      )));

      expect(find.textContaining('Last push'), findsOneWidget);
      expect(find.textContaining('Last pull'), findsOneWidget);
    });

    testWidgets('shows sync now and backup buttons', (tester) async {
      await tester.pumpWidget(buildScreen(SyncStatus(
        deviceId: 'device-A',
        pendingChanges: 0,
      )));

      expect(find.text('Push Now'), findsOneWidget);
      expect(find.text('Pull Now'), findsOneWidget);
      expect(find.text('Create Backup'), findsOneWidget);
    });
  });
}
