import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:vael/features/settings/screens/passphrase_setup_screen.dart';
import 'package:vael/shared/theme/app_theme.dart';

import 'helpers/e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpPassphraseScreen(
    WidgetTester tester, {
    required void Function(String) onSetup,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: PassphraseSetupScreen(onSetup: onSetup),
      ),
    );
    await settle(tester);
  }

  group('Passphrase Setup Flow', () {
    testWidgets('valid passphrase + matching confirm calls onSetup', (tester) async {
      String? captured;
      await pumpPassphraseScreen(tester, onSetup: (p) => captured = p);

      // Title
      expect(find.text('Set Family Passphrase'), findsOneWidget);

      // Enter valid passphrase (≥8 chars)
      await tester.enterText(find.byType(TextField).at(0), 'MySecret123');
      await tester.enterText(find.byType(TextField).at(1), 'MySecret123');

      await tester.tap(find.text('Continue'));
      await settle(tester);

      expect(captured, 'MySecret123');
    });

    testWidgets('mismatched confirmation shows error', (tester) async {
      await pumpPassphraseScreen(tester, onSetup: (_) {});

      await tester.enterText(find.byType(TextField).at(0), 'MySecret123');
      await tester.enterText(find.byType(TextField).at(1), 'WrongConfirm');

      await tester.tap(find.text('Continue'));
      await settle(tester);

      expect(find.text('Passphrases do not match'), findsOneWidget);
    });

    testWidgets('too-short passphrase shows error', (tester) async {
      await pumpPassphraseScreen(tester, onSetup: (_) {});

      await tester.enterText(find.byType(TextField).at(0), 'short');
      await tester.enterText(find.byType(TextField).at(1), 'short');

      await tester.tap(find.text('Continue'));
      await settle(tester);

      expect(find.text('Passphrase must be at least 8 characters'), findsOneWidget);
    });

    testWidgets('visibility toggle shows/hides text', (tester) async {
      await pumpPassphraseScreen(tester, onSetup: (_) {});

      // Initially obscured — visibility_off icon should be present
      expect(find.byIcon(Icons.visibility_off), findsWidgets);

      // Tap toggle on first field
      await tester.tap(find.byIcon(Icons.visibility_off).first);
      await settle(tester);

      // Now visibility icon should appear (text revealed)
      expect(find.byIcon(Icons.visibility), findsWidgets);
    });
  });
}
