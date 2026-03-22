import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/features/accounts/providers/account_ui_providers.dart';
import 'package:vael/features/imports/screens/statement_import_screen.dart';

Account _fakeAccount() => const Account(
  id: 'acc1',
  name: 'HDFC Savings',
  type: 'savings',
  balance: 5000000,
  currency: 'INR',
  visibility: 'shared',
  sharedWithFamily: true,
  familyId: 'f1',
  userId: 'u1',
);

void main() {
  Widget buildApp() {
    return ProviderScope(
      overrides: [
        allAccountsProvider(
          'f1',
        ).overrideWith((_) => Stream.value([_fakeAccount()])),
      ],
      child: const MaterialApp(home: StatementImportScreen(familyId: 'f1')),
    );
  }

  group('StatementImportScreen', () {
    testWidgets('should show CSV input field and account picker initially', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Paste your bank statement CSV below'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);
      expect(find.text('Import into account'), findsOneWidget);
    });

    testWidgets('should parse and show review step on preview', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Select account first
      await tester.tap(find.text('Import into account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('HDFC Savings').last);
      await tester.pumpAndSettle();

      // Enter CSV
      const csv =
          'Date,Narration,Value Dat,Debit Amount,Credit Amount,Chq/Ref Number,Closing Balance\n'
          '01/01/2026,UPI-SWIGGY,01/01/2026,450.00,,REF1,49550.00\n'
          '02/01/2026,NEFT-SALARY,02/01/2026,,150000.00,REF2,199550.00';

      await tester.enterText(find.byType(TextField), csv);
      await tester.tap(find.text('Preview'));
      await tester.pumpAndSettle();

      // Should show review step
      expect(find.text('UPI-SWIGGY'), findsOneWidget);
      expect(find.text('NEFT-SALARY'), findsOneWidget);
      expect(find.textContaining('HDFC'), findsOneWidget);
      expect(find.textContaining('2 parsed'), findsOneWidget);
    });

    testWidgets('should allow going back from review to input', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Select account
      await tester.tap(find.text('Import into account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('HDFC Savings').last);
      await tester.pumpAndSettle();

      const csv =
          'Date,Narration,Value Dat,Debit Amount,Credit Amount,Chq/Ref Number,Closing Balance\n'
          '01/01/2026,UPI-SWIGGY,01/01/2026,450.00,,REF1,49550.00';

      await tester.enterText(find.byType(TextField), csv);
      await tester.tap(find.text('Preview'));
      await tester.pumpAndSettle();

      // Go back
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      // Should be back to input
      expect(find.text('Paste your bank statement CSV below'), findsOneWidget);
    });
  });
}
