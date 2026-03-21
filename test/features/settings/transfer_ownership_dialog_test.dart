import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/sync/manifest.dart';
import 'package:vael/features/settings/screens/transfer_ownership_dialog.dart';

void main() {
  final members = [
    MemberEntry(
      userId: 'u-member-1',
      email: 'alice@test.com',
      role: 'member',
      wrappedFek: Uint8List(60),
      fekSalt: Uint8List(32),
      addedAt: DateTime.utc(2026, 3, 21),
      addedBy: 'u-admin',
    ),
    MemberEntry(
      userId: 'u-member-2',
      email: 'bob@test.com',
      role: 'member',
      wrappedFek: Uint8List(60),
      fekSalt: Uint8List(32),
      addedAt: DateTime.utc(2026, 3, 21),
      addedBy: 'u-admin',
    ),
  ];

  group('TransferOwnershipDialog', () {
    Widget buildApp() {
      return MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => TransferOwnershipDialog.show(context, members),
              child: const Text('Open'),
            ),
          ),
        ),
      );
    }

    testWidgets('shows eligible member emails', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('alice@test.com'), findsOneWidget);
      expect(find.text('bob@test.com'), findsOneWidget);
    });

    testWidgets('Transfer button disabled until selection', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Find the Transfer FilledButton and verify it's disabled
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Transfer'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('Transfer button enabled after selection', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('alice@test.com'));
      await tester.pumpAndSettle();

      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Transfer'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('shows warning about irreversibility', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.textContaining('cannot be undone'), findsOneWidget);
    });

    testWidgets('cancel closes dialog', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Transfer Ownership'), findsNothing);
    });
  });
}
