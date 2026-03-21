import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/financial/amortization.dart';
import 'package:vael/features/loans/providers/loan_providers.dart';
import 'package:vael/features/loans/screens/loan_detail_screen.dart';

LoanDetail _fakeLoan({
  int principal = 5000000000, // ₹5,00,00,000 (5 crore paise = 50 lakh rupees)
  double annualRate = 0.085,
  int tenureMonths = 240,
  int outstandingPrincipal = 4800000000,
  int emiAmount = 4345600,
}) {
  return LoanDetail(
    id: 'ld1',
    accountId: 'acc_loan',
    principal: principal,
    annualRate: annualRate,
    tenureMonths: tenureMonths,
    outstandingPrincipal: outstandingPrincipal,
    emiAmount: emiAmount,
    startDate: DateTime(2023, 1, 1),
    disbursementDate: null,
    familyId: 'fam_a',
  );
}

void main() {
  Widget buildTestApp({LoanViewData? data}) {
    final key = (accountId: 'acc_loan', familyId: 'fam_a');
    return ProviderScope(
      overrides: [loanViewProvider(key).overrideWith((_) async => data)],
      child: const MaterialApp(
        home: LoanDetailScreen(accountId: 'acc_loan', familyId: 'fam_a'),
      ),
    );
  }

  group('LoanDetailScreen', () {
    testWidgets('shows loan summary with principal, rate, tenure', (
      tester,
    ) async {
      final loan = _fakeLoan();
      final schedule = AmortizationCalculator.generateSchedule(
        principal: loan.principal,
        annualRate: loan.annualRate,
        tenureMonths: loan.tenureMonths,
      );
      final enrichment = AmortizationCalculator.enrich(schedule, fromMonth: 24);

      await tester.pumpWidget(
        buildTestApp(
          data: LoanViewData(
            loan: loan,
            schedule: schedule,
            enrichment: enrichment,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Loan Summary'), findsOneWidget);
      expect(
        find.textContaining('5,00,00,000'),
        findsWidgets,
      ); // principal in rupees
      expect(find.textContaining('8.5%'), findsOneWidget);
      expect(find.textContaining('240 months'), findsOneWidget);
    });

    testWidgets('shows EMI split with principal and interest labels', (
      tester,
    ) async {
      final loan = _fakeLoan();
      final schedule = AmortizationCalculator.generateSchedule(
        principal: loan.principal,
        annualRate: loan.annualRate,
        tenureMonths: loan.tenureMonths,
      );
      final enrichment = AmortizationCalculator.enrich(schedule, fromMonth: 12);

      await tester.pumpWidget(
        buildTestApp(
          data: LoanViewData(
            loan: loan,
            schedule: schedule,
            enrichment: enrichment,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Next EMI Split'), findsOneWidget);
      expect(find.textContaining('Principal:'), findsOneWidget);
      expect(find.textContaining('Interest:'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('shows amortization schedule table', (tester) async {
      // Use a small loan for manageable schedule
      final loan = _fakeLoan(
        principal: 10000000, // ₹1,00,000
        annualRate: 0.12,
        tenureMonths: 12,
        outstandingPrincipal: 10000000,
        emiAmount: 888400,
      );
      final schedule = AmortizationCalculator.generateSchedule(
        principal: loan.principal,
        annualRate: loan.annualRate,
        tenureMonths: loan.tenureMonths,
      );
      final enrichment = AmortizationCalculator.enrich(schedule, fromMonth: 0);

      await tester.pumpWidget(
        buildTestApp(
          data: LoanViewData(
            loan: loan,
            schedule: schedule,
            enrichment: enrichment,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Amortization Schedule'), findsOneWidget);
      expect(find.byType(DataTable), findsOneWidget);
      // Verify schedule has 12 rows by checking month column entries
      expect(find.text('1'), findsWidgets); // month 1
      expect(find.text('12'), findsWidgets); // month 12
    });

    testWidgets('shows "Loan not found" when data is null', (tester) async {
      await tester.pumpWidget(buildTestApp(data: null));
      await tester.pumpAndSettle();

      expect(find.text('Loan not found'), findsOneWidget);
    });

    testWidgets('shows remaining tenure and interest remaining', (
      tester,
    ) async {
      final loan = _fakeLoan();
      final schedule = AmortizationCalculator.generateSchedule(
        principal: loan.principal,
        annualRate: loan.annualRate,
        tenureMonths: loan.tenureMonths,
      );
      final enrichment = AmortizationCalculator.enrich(schedule, fromMonth: 24);

      await tester.pumpWidget(
        buildTestApp(
          data: LoanViewData(
            loan: loan,
            schedule: schedule,
            enrichment: enrichment,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('${enrichment.remainingTenure} months'),
        findsOneWidget,
      );
      expect(find.textContaining('Interest Remaining'), findsOneWidget);
    });
  });
}
