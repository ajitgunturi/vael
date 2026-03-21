import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/loan_details.dart';

part 'loan_dao.g.dart';

@DriftAccessor(tables: [LoanDetails])
class LoanDao extends DatabaseAccessor<AppDatabase> with _$LoanDaoMixin {
  LoanDao(super.db);

  /// Returns the loan detail for a specific [accountId] within [familyId].
  Future<LoanDetail?> getByAccountId(String accountId, String familyId) {
    return (select(loanDetails)..where(
          (l) => l.accountId.equals(accountId) & l.familyId.equals(familyId),
        ))
        .getSingleOrNull();
  }

  /// Returns all loan details for [familyId].
  Future<List<LoanDetail>> getAll(String familyId) {
    return (select(
      loanDetails,
    )..where((l) => l.familyId.equals(familyId))).get();
  }

  /// Watches a single loan detail by [accountId].
  Stream<LoanDetail?> watchByAccountId(String accountId, String familyId) {
    return (select(loanDetails)..where(
          (l) => l.accountId.equals(accountId) & l.familyId.equals(familyId),
        ))
        .watchSingleOrNull();
  }

  /// Inserts a new loan detail row.
  Future<int> insertLoan(LoanDetailsCompanion entry) {
    return into(loanDetails).insert(entry);
  }

  /// Updates outstanding principal after a payment or prepayment.
  Future<int> updateOutstanding(String id, int newOutstanding) {
    return (update(loanDetails)..where((l) => l.id.equals(id))).write(
      LoanDetailsCompanion(outstandingPrincipal: Value(newOutstanding)),
    );
  }
}
