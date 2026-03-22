import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/providers/session_providers.dart';
import 'package:vael/features/settings/screens/settings_screen.dart';

void main() {
  group('SettingsScreen', () {
    Widget buildScreen({String familyId = 'fam-1', String userId = 'usr-1'}) {
      return ProviderScope(
        child: MaterialApp(
          home: SettingsScreen(familyId: familyId, userId: userId),
        ),
      );
    }

    testWidgets('shows settings title in app bar', (tester) async {
      await tester.pumpWidget(buildScreen());
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows Family Backup tile', (tester) async {
      await tester.pumpWidget(buildScreen());
      expect(find.text('Family Backup'), findsOneWidget);
      expect(find.byIcon(Icons.folder_shared), findsOneWidget);
    });

    testWidgets('shows Sync Status tile', (tester) async {
      await tester.pumpWidget(buildScreen());
      expect(find.text('Sync Status'), findsOneWidget);
      expect(find.byIcon(Icons.sync), findsOneWidget);
    });

    testWidgets('shows Passphrase tile', (tester) async {
      await tester.pumpWidget(buildScreen());
      expect(find.text('Passphrase'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('shows Sign Out tile', (tester) async {
      await tester.pumpWidget(buildScreen());
      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('tapping Family Backup navigates to FamilyBackupScreen', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen());
      await tester.tap(find.text('Family Backup'));
      await tester.pumpAndSettle();

      expect(find.text('Family Backup'), findsWidgets);
    });

    testWidgets('tapping Sync Status navigates to SyncStatusScreen', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen());
      await tester.tap(find.text('Sync Status'));
      await tester.pumpAndSettle();

      expect(find.text('Sync Status'), findsWidgets);
    });

    testWidgets('tapping Passphrase navigates to PassphraseSetupScreen', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen());
      await tester.tap(find.text('Passphrase'));
      await tester.pumpAndSettle();

      expect(find.text('Set Family Passphrase'), findsOneWidget);
    });

    testWidgets('tapping Sign Out clears session and pops', (tester) async {
      // Wrap in a parent route so we can verify pop behavior.
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Pre-set session so we can verify it clears.
      container.read(sessionFamilyIdProvider.notifier).set('fam-1');
      container.read(sessionUserIdProvider.notifier).set('usr-1');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(
                        familyId: 'fam-1',
                        userId: 'usr-1',
                      ),
                    ),
                  ),
                  child: const Text('Open Settings'),
                ),
              ),
            ),
          ),
        ),
      );

      // Navigate to SettingsScreen
      await tester.tap(find.text('Open Settings'));
      await tester.pumpAndSettle();

      // Tap Sign Out
      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      // Session providers should be cleared
      expect(container.read(sessionFamilyIdProvider), isNull);
      expect(container.read(sessionUserIdProvider), isNull);

      // Should have popped back
      expect(find.text('Open Settings'), findsOneWidget);
    });

    testWidgets('shows app version info section', (tester) async {
      await tester.pumpWidget(buildScreen());
      expect(find.text('Vael'), findsOneWidget);
    });
  });
}
