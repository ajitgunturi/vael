import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:vael/core/database/database.dart';
import 'package:vael/core/providers/database_providers.dart';
import 'package:vael/features/investments/screens/investment_form_screen.dart';
import 'package:vael/features/investments/screens/investment_portfolio_screen.dart';
import 'package:vael/shared/theme/app_theme.dart';

import 'helpers/e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> pumpPortfolio(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const InvestmentPortfolioScreen(familyId: kTestFamilyId),
        ),
      ),
    );
    await settle(tester);
  }

  Future<void> pumpInvestmentForm(WidgetTester tester, {String? editingId}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: InvestmentFormScreen(
            familyId: kTestFamilyId,
            editingId: editingId,
          ),
        ),
      ),
    );
    await settle(tester);
  }

  group('Journey: Investment Portfolio', () {
    testWidgets('should show empty state on portfolio screen', (tester) async {
      await seedTestFamily(db);
      await pumpPortfolio(tester);

      expect(find.text('Investments'), findsOneWidget);
      expect(find.text('No investment buckets yet'), findsOneWidget);
      expect(find.text('Tap + to add your first bucket'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should navigate to add form via FAB', (tester) async {
      await seedTestFamily(db);
      await pumpPortfolio(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await settle(tester);

      expect(find.text('Add Investment Bucket'), findsOneWidget);
    });

    testWidgets('should display investment form with all fields', (tester) async {
      await seedTestFamily(db);
      await pumpInvestmentForm(tester);

      expect(find.text('Add Investment Bucket'), findsOneWidget);
      expect(find.text('Bucket Name'), findsOneWidget);
      expect(find.text('Type'), findsOneWidget);
      expect(find.text('Invested Amount'), findsOneWidget);
      expect(find.text('Current Value'), findsOneWidget);
      expect(find.text('Monthly SIP (optional)'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('should show edit title when editing', (tester) async {
      await seedTestFamily(db);
      await pumpInvestmentForm(tester, editingId: 'edit-1');

      expect(find.text('Edit Bucket'), findsOneWidget);
      expect(find.text('Update'), findsOneWidget);
    });

    testWidgets('should validate empty bucket name', (tester) async {
      await seedTestFamily(db);
      await pumpInvestmentForm(tester);

      // Tap save without entering name
      await tester.tap(find.text('Save'));
      await settle(tester);

      expect(find.text('Name required'), findsOneWidget);
    });

    testWidgets('should show default return rate for Mutual Funds', (tester) async {
      await seedTestFamily(db);
      await pumpInvestmentForm(tester);

      // Default type is Mutual Funds → 12% return rate
      expect(find.textContaining('12.0% p.a.'), findsOneWidget);
      expect(find.text('Default'), findsOneWidget);
    });

    testWidgets('should show bucket type dropdown with all types', (tester) async {
      await seedTestFamily(db);
      await pumpInvestmentForm(tester);

      // Tap the type dropdown to see all options
      await tester.tap(find.text('Mutual Funds'));
      await settle(tester);

      expect(find.text('Stocks'), findsWidgets);
      expect(find.text('PPF'), findsWidgets);
      expect(find.text('EPF'), findsWidgets);
      expect(find.text('NPS'), findsWidgets);
      expect(find.text('Fixed Deposit'), findsWidgets);
      expect(find.text('Bonds'), findsWidgets);
      expect(find.text('Insurance/ULIP'), findsWidgets);
    });

    testWidgets('should fill form and save successfully', (tester) async {
      await seedTestFamily(db);
      await pumpInvestmentForm(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Bucket Name'),
        'Retirement MFs',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Invested Amount'),
        '100000',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Current Value'),
        '120000',
      );
      await settle(tester);

      // Drag up to reveal Save button (off-screen on iPhone)
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await settle(tester);
      await tester.tap(find.text('Save'));
      await settle(tester);

      // Form should have popped
      expect(find.text('Add Investment Bucket'), findsNothing);
    });
  });
}
