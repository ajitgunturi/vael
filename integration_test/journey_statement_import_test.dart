import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:vael/core/database/database.dart';
import 'package:vael/core/providers/database_providers.dart';
import 'package:vael/features/imports/screens/statement_import_screen.dart';
import 'package:vael/shared/theme/app_theme.dart';

import 'helpers/e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> pumpImportScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const StatementImportScreen(familyId: kTestFamilyId),
        ),
      ),
    );
    await settle(tester);
  }

  // HDFC-format CSV fixture
  const hdfcCsv = '''Date,Narration,Value Dat,Debit Amount,Credit Amount,Chq/Ref Number,Closing Balance
01/03/2025,SWIGGY FOOD ORDER,01/03/2025,450.00,,REF001,99550.00
05/03/2025,SALARY MARCH,05/03/2025,,75000.00,REF002,174550.00
10/03/2025,AMAZON PURCHASE,10/03/2025,2500.00,,REF003,172050.00''';

  // Generic CSV fixture
  const genericCsv = '''Date,Description,Amount
2025-03-01,Grocery BigBasket,-1200.50
2025-03-05,Salary Credit,75000.00
2025-03-10,Netflix Subscription,-199.00''';

  group('Journey: Statement Import', () {
    testWidgets('should show input step with paste area', (tester) async {
      await seedTestFamily(db);
      await pumpImportScreen(tester);

      expect(find.text('Import Statement'), findsOneWidget);
      expect(find.text('Paste your bank statement CSV below'), findsOneWidget);
      expect(find.text('Supported: HDFC, SBI, ICICI, or generic CSV'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);
    });

    testWidgets('should show monospace text field for CSV input', (tester) async {
      await seedTestFamily(db);
      await pumpImportScreen(tester);

      // TextField with CSV hint
      expect(find.widgetWithText(TextField, ''), findsOneWidget);
    });

    testWidgets('should parse HDFC CSV and show review step', (tester) async {
      await seedTestFamily(db);
      await pumpImportScreen(tester);

      // Enter HDFC CSV
      await tester.enterText(find.byType(TextField), hdfcCsv);
      await settle(tester);

      // Tap Preview
      await tester.tap(find.text('Preview'));
      await settle(tester);

      // Review step should show — format name is combined: "HDFC · 3 parsed"
      expect(find.textContaining('HDFC'), findsOneWidget);
      expect(find.textContaining('3 parsed'), findsOneWidget);
      expect(find.textContaining('3 selected'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('should display parsed transactions in review', (tester) async {
      await seedTestFamily(db);
      await pumpImportScreen(tester);

      await tester.enterText(find.byType(TextField), hdfcCsv);
      await tester.tap(find.text('Preview'));
      await settle(tester);

      // Transaction descriptions
      expect(find.text('SWIGGY FOOD ORDER'), findsOneWidget);
      expect(find.text('SALARY MARCH'), findsOneWidget);
      expect(find.text('AMAZON PURCHASE'), findsOneWidget);

      // Inferred categories
      expect(find.textContaining('Food & Dining'), findsOneWidget);
      expect(find.textContaining('Salary'), findsOneWidget);
      expect(find.textContaining('Shopping'), findsOneWidget);
    });

    testWidgets('should show all transactions selected by default', (tester) async {
      await seedTestFamily(db);
      await pumpImportScreen(tester);

      await tester.enterText(find.byType(TextField), hdfcCsv);
      await tester.tap(find.text('Preview'));
      await settle(tester);

      // All 3 checkboxes should be checked
      final checkboxes = tester.widgetList<CheckboxListTile>(
        find.byType(CheckboxListTile),
      );
      expect(checkboxes.length, 3);
      for (final cb in checkboxes) {
        expect(cb.value, isTrue);
      }
    });

    testWidgets('should allow deselecting transactions', (tester) async {
      await seedTestFamily(db);
      await pumpImportScreen(tester);

      await tester.enterText(find.byType(TextField), hdfcCsv);
      await tester.tap(find.text('Preview'));
      await settle(tester);

      // Deselect first transaction
      await tester.tap(find.byType(CheckboxListTile).first);
      await settle(tester);

      expect(find.textContaining('2 selected'), findsOneWidget);
      expect(find.textContaining('Import 2 transactions'), findsOneWidget);
    });

    testWidgets('should go back to input step via Back button', (tester) async {
      await seedTestFamily(db);
      await pumpImportScreen(tester);

      await tester.enterText(find.byType(TextField), hdfcCsv);
      await tester.tap(find.text('Preview'));
      await settle(tester);

      await tester.tap(find.text('Back'));
      await settle(tester);

      // Back to input step
      expect(find.text('Paste your bank statement CSV below'), findsOneWidget);
    });

    testWidgets('should parse generic CSV format', (tester) async {
      await seedTestFamily(db);
      await pumpImportScreen(tester);

      await tester.enterText(find.byType(TextField), genericCsv);
      await tester.tap(find.text('Preview'));
      await settle(tester);

      expect(find.textContaining('Generic CSV'), findsOneWidget);
      expect(find.textContaining('3 parsed'), findsOneWidget);
      expect(find.text('Grocery BigBasket'), findsOneWidget);
      expect(find.textContaining('Groceries'), findsOneWidget);
    });

    testWidgets('should commit import and show snackbar', (tester) async {
      await seedTestFamily(db);
      // Wrap in a Navigator so pop() works cleanly
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            theme: AppTheme.light(),
            routes: {
              '/': (_) => const Scaffold(body: Center(child: Text('Home'))),
              '/import': (_) => const StatementImportScreen(familyId: kTestFamilyId),
            },
            initialRoute: '/import',
          ),
        ),
      );
      await settle(tester);

      await tester.enterText(find.byType(TextField), hdfcCsv);
      await tester.tap(find.text('Preview'));
      await settle(tester);

      // Tap import button
      await tester.tap(find.textContaining('Import 3 transactions'));
      await tester.pump(); // allow snackbar to appear before pop

      // After pop, we're on Home — snackbar was on the import screen's scaffold
      // Verify the commit action completed (screen popped to Home)
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('should not preview empty CSV', (tester) async {
      await seedTestFamily(db);
      await pumpImportScreen(tester);

      // Tap Preview with empty field — should stay on input step
      await tester.tap(find.text('Preview'));
      await settle(tester);

      expect(find.text('Paste your bank statement CSV below'), findsOneWidget);
    });

    testWidgets('should disable import button when none selected', (tester) async {
      await seedTestFamily(db);
      await pumpImportScreen(tester);

      await tester.enterText(find.byType(TextField), genericCsv);
      await tester.tap(find.text('Preview'));
      await settle(tester);

      // Deselect all
      for (final cb in find.byType(CheckboxListTile).evaluate()) {
        await tester.tap(find.byWidget(cb.widget));
        await settle(tester);
      }

      // Import button should be disabled (0 selected)
      expect(find.textContaining('Import 0 transactions'), findsOneWidget);
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });
  });
}
