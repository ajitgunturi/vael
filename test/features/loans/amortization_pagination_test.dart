import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/financial/amortization.dart';
import 'package:vael/features/loans/providers/loan_providers.dart';
import 'package:vael/features/loans/screens/loan_detail_screen.dart';

LoanViewData _buildLoanData({required int tenureMonths}) {
  final loan = LoanDetail(
    id: 'ld1',
    accountId: 'acc_loan',
    principal: 10000000, // ₹1,00,000
    annualRate: 0.12,
    tenureMonths: tenureMonths,
    outstandingPrincipal: 10000000,
    emiAmount: 888400,
    startDate: DateTime(2023, 1, 1),
    disbursementDate: null,
    familyId: 'fam_a',
  );
  final schedule = AmortizationCalculator.generateSchedule(
    principal: loan.principal,
    annualRate: loan.annualRate,
    tenureMonths: loan.tenureMonths,
  );
  final enrichment = AmortizationCalculator.enrich(schedule, fromMonth: 0);
  return LoanViewData(loan: loan, schedule: schedule, enrichment: enrichment);
}

void main() {
  Widget buildTestApp(LoanViewData data) {
    final key = (accountId: 'acc_loan', familyId: 'fam_a');
    return ProviderScope(
      overrides: [loanViewProvider(key).overrideWith((_) async => data)],
      child: const MaterialApp(
        home: LoanDetailScreen(accountId: 'acc_loan', familyId: 'fam_a'),
      ),
    );
  }

  group('Amortization Table Pagination', () {
    testWidgets('shows only first 12 rows for long schedules', (tester) async {
      final data = _buildLoanData(tenureMonths: 24);
      await tester.pumpWidget(buildTestApp(data));
      await tester.pumpAndSettle();

      final dataTable = tester.widget<DataTable>(find.byType(DataTable));
      expect(dataTable.rows, hasLength(12));
    });

    testWidgets('shows "Show More" button for long schedules', (tester) async {
      final data = _buildLoanData(tenureMonths: 24);
      await tester.pumpWidget(buildTestApp(data));
      await tester.pumpAndSettle();

      expect(find.text('Show More'), findsOneWidget);
    });

    testWidgets('tapping "Show More" reveals all rows', (tester) async {
      final data = _buildLoanData(tenureMonths: 24);
      await tester.pumpWidget(buildTestApp(data));
      await tester.pumpAndSettle();

      // Scroll to make "Show More" visible
      await tester.scrollUntilVisible(
        find.text('Show More'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show More'));
      await tester.pumpAndSettle();

      final dataTable = tester.widget<DataTable>(find.byType(DataTable));
      expect(dataTable.rows, hasLength(24));
      expect(find.text('Show More'), findsNothing);
    });

    testWidgets('does not show "Show More" for short schedules (≤12)', (
      tester,
    ) async {
      final data = _buildLoanData(tenureMonths: 10);
      await tester.pumpWidget(buildTestApp(data));
      await tester.pumpAndSettle();

      expect(find.text('Show More'), findsNothing);
      final dataTable = tester.widget<DataTable>(find.byType(DataTable));
      expect(dataTable.rows, hasLength(10));
    });
  });
}
