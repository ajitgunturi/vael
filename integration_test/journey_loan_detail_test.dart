import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:vael/core/database/database.dart';
import 'package:vael/core/providers/database_providers.dart';
import 'package:vael/features/loans/screens/loan_detail_screen.dart';
import 'package:vael/shared/theme/app_theme.dart';

import 'helpers/e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// Pumps LoanDetailScreen directly (not via SimulatorTestApp)
  /// since the loan detail is navigated to, not a tab.
  Future<void> pumpLoanDetail(WidgetTester tester, {
    required String accountId,
    required String familyId,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: LoanDetailScreen(
            accountId: accountId,
            familyId: familyId,
          ),
        ),
      ),
    );
    await settle(tester);
  }

  group('Journey: Loan Detail + Amortization', () {
    testWidgets('should display loan summary card with correct values', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'loan_acc', name: 'Home Loan', type: 'loan', balance: 250000000);
      await seedLoanDetail(db,
        id: 'ld1',
        accountId: 'loan_acc',
        principal: 300000000, // ₹30,00,000
        annualRate: 0.085,    // 8.5%
        tenureMonths: 240,    // 20 years
        outstandingPrincipal: 250000000, // ₹25,00,000
        emiAmount: 2604400,   // ~₹26,044
        startDate: DateTime(2023, 1, 1),
      );

      await pumpLoanDetail(tester, accountId: 'loan_acc', familyId: kTestFamilyId);

      // Summary card
      expect(find.text('Loan Summary'), findsOneWidget);
      expect(find.textContaining('30,00,000'), findsWidgets); // principal
      expect(find.textContaining('25,00,000'), findsWidgets); // outstanding
      expect(find.textContaining('8.5'), findsOneWidget);     // rate
      expect(find.textContaining('240 months'), findsOneWidget); // tenure
    });

    testWidgets('should show EMI split bar with principal vs interest', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'loan_acc', name: 'Car Loan', type: 'loan', balance: 50000000);
      await seedLoanDetail(db,
        id: 'ld1',
        accountId: 'loan_acc',
        principal: 50000000,  // ₹5,00,000
        annualRate: 0.09,     // 9%
        tenureMonths: 60,     // 5 years
        outstandingPrincipal: 50000000,
        emiAmount: 1038200,   // ~₹10,382
        startDate: DateTime(2025, 1, 1),
      );

      await pumpLoanDetail(tester, accountId: 'loan_acc', familyId: kTestFamilyId);

      // EMI split section
      expect(find.text('Next EMI Split'), findsOneWidget);
      expect(find.textContaining('Principal:'), findsOneWidget);
      expect(find.textContaining('Interest:'), findsOneWidget);

      // The LinearProgressIndicator for the split bar
      expect(find.byType(LinearProgressIndicator), findsWidgets);
    });

    testWidgets('should show amortization table with Show More pagination', (tester) async {
      await seedTestFamily(db);
      await seedAccount(db, id: 'loan_acc', name: 'Personal Loan', type: 'loan', balance: 10000000);
      await seedLoanDetail(db,
        id: 'ld1',
        accountId: 'loan_acc',
        principal: 10000000,  // ₹1,00,000
        annualRate: 0.12,     // 12%
        tenureMonths: 36,     // 3 years (>12 so pagination kicks in)
        outstandingPrincipal: 10000000,
        emiAmount: 332143,    // ~₹3,321
        startDate: DateTime(2025, 1, 1),
      );

      await pumpLoanDetail(tester, accountId: 'loan_acc', familyId: kTestFamilyId);

      // Scroll down the outer ListView to reach the amortization card.
      final listView = find.byType(Scrollable).first;

      await tester.scrollUntilVisible(
        find.text('Amortization Schedule'), 200,
        scrollable: listView,
      );
      await settle(tester);
      expect(find.text('Amortization Schedule'), findsOneWidget);

      // DataTable should be present
      expect(find.byType(DataTable), findsOneWidget);

      // Scroll further to reach "Show More"
      await tester.scrollUntilVisible(
        find.text('Show More'), 200,
        scrollable: listView,
      );
      await settle(tester);
      expect(find.text('Show More'), findsOneWidget);

      // Tap "Show More" to expand
      await tester.tap(find.text('Show More'));
      await settle(tester);

      // After expansion, "Show More" should disappear
      expect(find.text('Show More'), findsNothing);
    });
  });
}
