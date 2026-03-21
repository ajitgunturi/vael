import 'package:drift/drift.dart';

import 'accounts.dart';
import 'families.dart';

/// Amortization parameters for a loan account.
/// One-to-one with an account of type 'loan'.
class LoanDetails extends Table {
  TextColumn get id => text()();
  TextColumn get accountId => text().references(Accounts, #id)();
  IntColumn get principal => integer()(); // paise
  RealColumn get annualRate => real()(); // decimal, e.g. 0.085 for 8.5%
  IntColumn get tenureMonths => integer()();
  IntColumn get outstandingPrincipal => integer()(); // paise
  IntColumn get emiAmount => integer()(); // paise
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get disbursementDate => dateTime().nullable()();
  TextColumn get familyId => text().references(Families, #id)();

  @override
  Set<Column> get primaryKey => {id};
}
