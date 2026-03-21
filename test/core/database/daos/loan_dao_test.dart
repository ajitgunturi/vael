import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/database/daos/loan_dao.dart';

void main() {
  late AppDatabase db;
  late LoanDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = LoanDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> _seedFamily(String familyId) async {
    await db
        .into(db.families)
        .insert(
          FamiliesCompanion.insert(
            id: familyId,
            name: 'Family',
            createdAt: DateTime(2025),
          ),
        );
    await db
        .into(db.users)
        .insert(
          UsersCompanion.insert(
            id: 'user_$familyId',
            email: '$familyId@test.com',
            displayName: 'User',
            role: 'admin',
            familyId: familyId,
          ),
        );
  }

  Future<void> _insertLoanAccount(String id, String familyId) async {
    await db
        .into(db.accounts)
        .insert(
          AccountsCompanion(
            id: Value(id),
            name: Value('Loan $id'),
            type: const Value('loan'),
            balance: const Value(0),
            visibility: const Value('shared'),
            familyId: Value(familyId),
            userId: Value('user_$familyId'),
          ),
        );
  }

  group('LoanDao', () {
    test('inserts and retrieves loan by accountId', () async {
      await _seedFamily('fam_a');
      await _insertLoanAccount('acc_loan', 'fam_a');

      await dao.insertLoan(
        LoanDetailsCompanion(
          id: const Value('ld1'),
          accountId: const Value('acc_loan'),
          principal: const Value(5000000000), // ₹50,00,000
          annualRate: const Value(0.085),
          tenureMonths: const Value(240),
          outstandingPrincipal: const Value(4800000000),
          emiAmount: const Value(4345600),
          startDate: Value(DateTime(2023, 1, 1)),
          familyId: const Value('fam_a'),
        ),
      );

      final loan = await dao.getByAccountId('acc_loan', 'fam_a');
      expect(loan, isNotNull);
      expect(loan!.principal, 5000000000);
      expect(loan.annualRate, 0.085);
      expect(loan.tenureMonths, 240);
      expect(loan.outstandingPrincipal, 4800000000);
    });

    test('returns null for non-existent account', () async {
      await _seedFamily('fam_a');
      final loan = await dao.getByAccountId('nonexistent', 'fam_a');
      expect(loan, isNull);
    });

    test('updates outstanding principal', () async {
      await _seedFamily('fam_a');
      await _insertLoanAccount('acc_loan', 'fam_a');

      await dao.insertLoan(
        LoanDetailsCompanion(
          id: const Value('ld1'),
          accountId: const Value('acc_loan'),
          principal: const Value(5000000000),
          annualRate: const Value(0.085),
          tenureMonths: const Value(240),
          outstandingPrincipal: const Value(5000000000),
          emiAmount: const Value(4345600),
          startDate: Value(DateTime(2023, 1, 1)),
          familyId: const Value('fam_a'),
        ),
      );

      await dao.updateOutstanding('ld1', 4900000000);

      final loan = await dao.getByAccountId('acc_loan', 'fam_a');
      expect(loan!.outstandingPrincipal, 4900000000);
    });

    test('getAll returns all loans for family', () async {
      await _seedFamily('fam_a');
      await _insertLoanAccount('acc_loan1', 'fam_a');
      await _insertLoanAccount('acc_loan2', 'fam_a');

      await dao.insertLoan(
        LoanDetailsCompanion(
          id: const Value('ld1'),
          accountId: const Value('acc_loan1'),
          principal: const Value(3000000000),
          annualRate: const Value(0.09),
          tenureMonths: const Value(180),
          outstandingPrincipal: const Value(3000000000),
          emiAmount: const Value(3043600),
          startDate: Value(DateTime(2024, 1, 1)),
          familyId: const Value('fam_a'),
        ),
      );
      await dao.insertLoan(
        LoanDetailsCompanion(
          id: const Value('ld2'),
          accountId: const Value('acc_loan2'),
          principal: const Value(1000000000),
          annualRate: const Value(0.075),
          tenureMonths: const Value(60),
          outstandingPrincipal: const Value(800000000),
          emiAmount: const Value(2003200),
          startDate: Value(DateTime(2023, 6, 1)),
          familyId: const Value('fam_a'),
        ),
      );

      final loans = await dao.getAll('fam_a');
      expect(loans, hasLength(2));
    });

    test('isolates by familyId', () async {
      await _seedFamily('fam_a');
      await _seedFamily('fam_b');
      await _insertLoanAccount('acc_loan_a', 'fam_a');
      await _insertLoanAccount('acc_loan_b', 'fam_b');

      await dao.insertLoan(
        LoanDetailsCompanion(
          id: const Value('ld1'),
          accountId: const Value('acc_loan_a'),
          principal: const Value(1000000000),
          annualRate: const Value(0.09),
          tenureMonths: const Value(120),
          outstandingPrincipal: const Value(1000000000),
          emiAmount: const Value(1266600),
          startDate: Value(DateTime(2024, 1, 1)),
          familyId: const Value('fam_a'),
        ),
      );
      await dao.insertLoan(
        LoanDetailsCompanion(
          id: const Value('ld2'),
          accountId: const Value('acc_loan_b'),
          principal: const Value(2000000000),
          annualRate: const Value(0.08),
          tenureMonths: const Value(240),
          outstandingPrincipal: const Value(2000000000),
          emiAmount: const Value(1673200),
          startDate: Value(DateTime(2024, 1, 1)),
          familyId: const Value('fam_b'),
        ),
      );

      final famA = await dao.getAll('fam_a');
      expect(famA, hasLength(1));
      expect(famA.first.principal, 1000000000);

      final famB = await dao.getAll('fam_b');
      expect(famB, hasLength(1));
      expect(famB.first.principal, 2000000000);
    });
  });
}
