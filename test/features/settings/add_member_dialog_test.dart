import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/features/settings/screens/add_member_dialog.dart';

void main() {
  group('AddMemberDialog', () {
    Widget buildApp() {
      return MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => AddMemberDialog.show(context),
              child: const Text('Open'),
            ),
          ),
        ),
      );
    }

    testWidgets('shows email input field', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Add Member'), findsOneWidget);
      expect(find.text('Email address'), findsOneWidget);
    });

    testWidgets('validates empty email', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Invite'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('validates invalid email format', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'notanemail');
      await tester.tap(find.text('Invite'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address'), findsOneWidget);
    });

    testWidgets('cancel closes without result', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Add Member'), findsNothing);
    });

    testWidgets('shows instructional text about passphrase', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.textContaining('passphrase'), findsOneWidget);
    });
  });
}
