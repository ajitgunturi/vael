import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/database/daos/loan_dao.dart';
import '../../../core/financial/amortization.dart';
import '../../../core/financial/amortization_row.dart';
import '../../../core/providers/database_providers.dart';

/// Key for loan detail lookup: (accountId, familyId).
typedef LoanKey = ({String accountId, String familyId});

/// Provides LoanDao from the database.
final loanDaoProvider = Provider<LoanDao>((ref) {
  return LoanDao(ref.watch(databaseProvider));
});

/// Streams a single loan detail by account ID.
final loanDetailProvider = StreamProvider.family<LoanDetail?, LoanKey>((
  ref,
  key,
) {
  final dao = ref.watch(loanDaoProvider);
  return dao.watchByAccountId(key.accountId, key.familyId);
});

/// Combined loan view data: loan detail + enrichment + schedule.
class LoanViewData {
  final LoanDetail loan;
  final List<AmortizationRow> schedule;
  final AmortizationEnrichment enrichment;

  const LoanViewData({
    required this.loan,
    required this.schedule,
    required this.enrichment,
  });
}

/// Computes loan view data: amortization schedule + enrichment.
///
/// [fromMonth] is derived from loan start date vs now to compute
/// how many months have elapsed.
final loanViewProvider = FutureProvider.family<LoanViewData?, LoanKey>((
  ref,
  key,
) async {
  final db = ref.watch(databaseProvider);
  final dao = LoanDao(db);

  final loan = await dao.getByAccountId(key.accountId, key.familyId);
  if (loan == null) return null;

  final schedule = AmortizationCalculator.generateSchedule(
    principal: loan.principal,
    annualRate: loan.annualRate,
    tenureMonths: loan.tenureMonths,
  );

  // Compute elapsed months from start date
  final now = DateTime.now();
  final elapsedMonths =
      (now.year - loan.startDate.year) * 12 + now.month - loan.startDate.month;

  final enrichment = AmortizationCalculator.enrich(
    schedule,
    fromMonth: elapsedMonths.clamp(0, schedule.length),
  );

  return LoanViewData(loan: loan, schedule: schedule, enrichment: enrichment);
});

/// Simulates prepayment impact: generates schedule with a prepayment
/// and computes interest saved.
class PrepaymentSimulation {
  final List<AmortizationRow> newSchedule;
  final int interestSaved;
  final int newTenureMonths;

  const PrepaymentSimulation({
    required this.newSchedule,
    required this.interestSaved,
    required this.newTenureMonths,
  });
}

/// Pure function to simulate a prepayment.
PrepaymentSimulation simulatePrepayment({
  required LoanDetail loan,
  required int prepaymentAmount,
  required int atMonth,
}) {
  final baseSchedule = AmortizationCalculator.generateSchedule(
    principal: loan.principal,
    annualRate: loan.annualRate,
    tenureMonths: loan.tenureMonths,
  );

  final prepaySchedule = AmortizationCalculator.generateSchedule(
    principal: loan.principal,
    annualRate: loan.annualRate,
    tenureMonths: loan.tenureMonths,
    prepayments: {atMonth: prepaymentAmount},
  );

  final saved = AmortizationCalculator.interestSaved(
    baseSchedule: baseSchedule,
    prepaySchedule: prepaySchedule,
  );

  return PrepaymentSimulation(
    newSchedule: prepaySchedule,
    interestSaved: saved,
    newTenureMonths: prepaySchedule.length,
  );
}
