import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/features/imports/screens/statement_import_screen.dart';

void main() {
  group('StatementImportScreen', () {
    testWidgets('should show CSV input field initially', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: StatementImportScreen(familyId: 'f1')),
        ),
      );

      expect(find.text('Paste your bank statement CSV below'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should parse and show review step on preview', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: StatementImportScreen(familyId: 'f1')),
        ),
      );

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
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: StatementImportScreen(familyId: 'f1')),
        ),
      );

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
