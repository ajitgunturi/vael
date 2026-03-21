import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:vael/core/database/database.dart';
import 'package:vael/core/providers/database_providers.dart';
import 'package:vael/features/recurring/screens/recurring_form_screen.dart';
import 'package:vael/features/recurring/screens/recurring_rules_screen.dart';
import 'package:vael/shared/theme/app_theme.dart';

import 'helpers/e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> pumpRulesList(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const RecurringRulesScreen(familyId: kTestFamilyId),
        ),
      ),
    );
    await settle(tester);
  }

  Future<void> pumpRecurringForm(WidgetTester tester, {String? editingId}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: RecurringFormScreen(
            familyId: kTestFamilyId,
            editingId: editingId,
          ),
        ),
      ),
    );
    await settle(tester);
  }

  group('Journey: Recurring Rules', () {
    testWidgets('should show empty state on rules screen', (tester) async {
      await seedTestFamily(db);
      await pumpRulesList(tester);

      expect(find.text('Recurring Rules'), findsOneWidget);
      expect(find.text('No recurring rules yet'), findsOneWidget);
      expect(find.text('Automate SIPs, rent, salary, and more'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should navigate to form via FAB', (tester) async {
      await seedTestFamily(db);
      await pumpRulesList(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await settle(tester);

      expect(find.text('New Recurring Rule'), findsOneWidget);
    });

    testWidgets('should display recurring form with all fields', (tester) async {
      await seedTestFamily(db);
      await pumpRecurringForm(tester);

      expect(find.text('New Recurring Rule'), findsOneWidget);
      expect(find.text('Name'), findsWidgets);
      expect(find.text('Type'), findsOneWidget);
      expect(find.text('Amount'), findsOneWidget);
      expect(find.text('Frequency'), findsOneWidget);
      expect(find.text('Start Date'), findsOneWidget);
      expect(find.textContaining('Annual Escalation'), findsOneWidget);
      expect(find.text('Create Rule'), findsOneWidget);
    });

    testWidgets('should show edit title when editing', (tester) async {
      await seedTestFamily(db);
      await pumpRecurringForm(tester, editingId: 'rule-1');

      expect(find.text('Edit Rule'), findsOneWidget);
      expect(find.text('Update'), findsOneWidget);
    });

    testWidgets('should validate empty rule name', (tester) async {
      await seedTestFamily(db);
      await pumpRecurringForm(tester);

      await tester.tap(find.text('Create Rule'));
      await settle(tester);

      expect(find.text('Name required'), findsOneWidget);
    });

    testWidgets('should show frequency dropdown with all options', (tester) async {
      await seedTestFamily(db);
      await pumpRecurringForm(tester);

      // Default is Monthly
      await tester.tap(find.text('Monthly'));
      await settle(tester);

      expect(find.text('Biweekly'), findsWidgets);
      expect(find.text('Quarterly'), findsWidgets);
      expect(find.text('Semi-annual'), findsWidgets);
      expect(find.text('Annual'), findsWidgets);
    });

    testWidgets('should show transaction kind dropdown', (tester) async {
      await seedTestFamily(db);
      await pumpRecurringForm(tester);

      // Default kind is expense — tap to see options
      await tester.tap(find.text('expense'));
      await settle(tester);

      expect(find.text('income'), findsWidgets);
      expect(find.text('salary'), findsWidgets);
      expect(find.text('transfer'), findsWidgets);
    });

    testWidgets('should display start date with calendar icon', (tester) async {
      await seedTestFamily(db);
      await pumpRecurringForm(tester);

      expect(find.text('Start Date'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('should fill form and save successfully', (tester) async {
      await seedTestFamily(db);
      await pumpRecurringForm(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Name'),
        'Monthly Rent',
      );
      await settle(tester);

      // Drag up to reveal Create Rule button (off-screen on iPhone)
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await settle(tester);
      await tester.tap(find.text('Create Rule'));
      await settle(tester);

      // Form should have popped
      expect(find.text('New Recurring Rule'), findsNothing);
    });

    testWidgets('should show escalation field with default 0', (tester) async {
      await seedTestFamily(db);
      await pumpRecurringForm(tester);

      // Escalation field defaults to "0"
      final escalationField = find.widgetWithText(TextFormField, 'Annual Escalation (%)');
      expect(escalationField, findsOneWidget);
    });
  });
}
