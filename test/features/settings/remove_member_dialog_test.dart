import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/sync/manifest.dart';
import 'package:vael/features/settings/screens/remove_member_dialog.dart';

void main() {
  final testMember = MemberEntry(
    userId: 'u-member',
    email: 'member@test.com',
    role: 'member',
    wrappedFek: Uint8List(60),
    fekSalt: Uint8List(32),
    addedAt: DateTime.utc(2026, 3, 21),
    addedBy: 'u-admin',
  );

  group('RemoveMemberDialog', () {
    Widget buildApp() {
      return MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => RemoveMemberDialog.show(context, testMember),
              child: const Text('Open'),
            ),
          ),
        ),
      );
    }

    testWidgets('shows member email in confirmation', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.textContaining('member@test.com'), findsOneWidget);
    });

    testWidgets('shows consequences of removal', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Revoke their access'), findsOneWidget);
      expect(find.textContaining('encryption key'), findsOneWidget);
      expect(find.textContaining('local data'), findsOneWidget);
    });

    testWidgets('shows Remove and Cancel buttons', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Remove'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('cancel closes dialog', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Remove Member'), findsNothing);
    });
  });
}
