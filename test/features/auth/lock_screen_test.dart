import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/features/auth/screens/lock_screen.dart';

void main() {
  group('LockScreen', () {
    testWidgets('renders passphrase field and unlock button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: LockScreen(onUnlocked: () {})));

      // Should find the passphrase text field
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Passphrase'), findsOneWidget);

      // Should find the Unlock button
      expect(find.text('Unlock'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);

      // Should display lock icon and title
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.text('Vael is locked'), findsOneWidget);
    });

    testWidgets('shows error when submitting empty passphrase', (
      WidgetTester tester,
    ) async {
      var unlocked = false;

      await tester.pumpWidget(
        MaterialApp(home: LockScreen(onUnlocked: () => unlocked = true)),
      );

      // Tap Unlock with empty field
      await tester.tap(find.text('Unlock'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Enter your passphrase'), findsOneWidget);
      expect(unlocked, isFalse);
    });
  });
}
