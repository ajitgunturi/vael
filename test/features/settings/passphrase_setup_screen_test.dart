import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/features/settings/screens/passphrase_setup_screen.dart';

void main() {
  group('PassphraseSetupScreen', () {
    Widget buildScreen({
      void Function(String passphrase)? onSetup,
    }) {
      return MaterialApp(
        home: PassphraseSetupScreen(
          onSetup: onSetup ?? (_) {},
        ),
      );
    }

    testWidgets('shows passphrase and confirm fields', (tester) async {
      await tester.pumpWidget(buildScreen());

      expect(find.text('Set Family Passphrase'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('shows error when passphrases do not match', (tester) async {
      await tester.pumpWidget(buildScreen());

      await tester.enterText(find.byType(TextField).first, 'passphrase1');
      await tester.enterText(find.byType(TextField).last, 'different');
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.text('Passphrases do not match'), findsOneWidget);
    });

    testWidgets('shows error when passphrase is too short', (tester) async {
      await tester.pumpWidget(buildScreen());

      await tester.enterText(find.byType(TextField).first, 'ab');
      await tester.enterText(find.byType(TextField).last, 'ab');
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.text('Passphrase must be at least 8 characters'),
          findsOneWidget);
    });

    testWidgets('calls onSetup when valid passphrase confirmed',
        (tester) async {
      String? capturedPassphrase;
      await tester.pumpWidget(buildScreen(
        onSetup: (p) => capturedPassphrase = p,
      ));

      await tester.enterText(
          find.byType(TextField).first, 'strong-passphrase');
      await tester.enterText(
          find.byType(TextField).last, 'strong-passphrase');
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(capturedPassphrase, 'strong-passphrase');
    });

    testWidgets('toggle password visibility', (tester) async {
      await tester.pumpWidget(buildScreen());

      // Initially obscured
      final textField = tester.widget<TextField>(find.byType(TextField).first);
      expect(textField.obscureText, true);

      // Tap visibility icon
      await tester.tap(find.byIcon(Icons.visibility_off).first);
      await tester.pump();

      final textFieldAfter =
          tester.widget<TextField>(find.byType(TextField).first);
      expect(textFieldAfter.obscureText, false);
    });
  });
}
