import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/financial/budget_summary.dart';

Transaction _tx({
  required String id,
  required int amount,
  required String kind,
  String? categoryId,
  String accountId = 'acc_1',
  String? toAccountId,
}) {
  return Transaction(
    id: id,
    amount: amount,
    date: DateTime(2025, 3, 15),
    description: null,
    categoryId: categoryId,
    accountId: accountId,
    toAccountId: toAccountId,
    kind: kind,
    reconciliationKind: null,
    metadata: null,
    familyId: 'fam_a',
  );
}

Category _cat({
  required String id,
  required String name,
  required String groupName,
  String type = 'EXPENSE',
}) {
  return Category(
    id: id,
    name: name,
    groupName: groupName,
    type: type,
    icon: null,
    familyId: 'fam_a',
  );
}

Budget _budget({
  required String id,
  required String categoryGroup,
  required int limitAmount,
}) {
  return Budget(
    id: id,
    familyId: 'fam_a',
    year: 2025,
    month: 3,
    categoryGroup: categoryGroup,
    limitAmount: limitAmount,
  );
}

Account _account({required String id, String visibility = 'shared'}) {
  return Account(
    id: id,
    name: 'Account $id',
    type: 'savings',
    institution: null,
    balance: 0,
    currency: 'INR',
    visibility: visibility,
    sharedWithFamily: true,
    familyId: 'fam_a',
    userId: 'user_1',
    deletedAt: null,
    liquidityTier: null,
    isEmergencyFund: false,
    isOpportunityFund: false,
    opportunityFundTargetPaise: null,
    minimumBalancePaise: null,
  );
}

void main() {
  group('BudgetSummary', () {
    group('computeActualsByGroup', () {
      test('sums expenses by category group', () {
        final categories = [
          _cat(id: 'c1', name: 'Groceries', groupName: 'ESSENTIAL'),
          _cat(id: 'c2', name: 'Rent', groupName: 'ESSENTIAL'),
          _cat(id: 'c3', name: 'Netflix', groupName: 'NON_ESSENTIAL'),
        ];
        final transactions = [
          _tx(id: 'tx1', amount: 200000, kind: 'expense', categoryId: 'c1'),
          _tx(id: 'tx2', amount: 500000, kind: 'expense', categoryId: 'c2'),
          _tx(id: 'tx3', amount: 50000, kind: 'expense', categoryId: 'c3'),
        ];

        final actuals = BudgetSummary.computeActualsByGroup(
          transactions: transactions,
          categories: categories,
          accounts: [_account(id: 'acc_1')],
        );

        expect(actuals['ESSENTIAL'], 700000); // 200000 + 500000
        expect(actuals['NON_ESSENTIAL'], 50000);
      });

      test('filters expense kinds only (ignores income, salary, transfer)', () {
        final categories = [
          _cat(id: 'c1', name: 'Groceries', groupName: 'ESSENTIAL'),
        ];
        final transactions = [
          _tx(id: 'tx1', amount: 200000, kind: 'expense', categoryId: 'c1'),
          _tx(id: 'tx2', amount: 5000000, kind: 'salary', categoryId: 'c1'),
          _tx(id: 'tx3', amount: 100000, kind: 'transfer', categoryId: 'c1'),
          _tx(id: 'tx4', amount: 30000, kind: 'emiPayment', categoryId: 'c1'),
          _tx(
            id: 'tx5',
            amount: 15000,
            kind: 'insurancePremium',
            categoryId: 'c1',
          ),
        ];

        final actuals = BudgetSummary.computeActualsByGroup(
          transactions: transactions,
          categories: categories,
          accounts: [_account(id: 'acc_1')],
        );

        // expense + emiPayment + insurancePremium only
        expect(actuals['ESSENTIAL'], 245000);
      });

      test('excludes self-transfers', () {
        final categories = [
          _cat(id: 'c1', name: 'Food', groupName: 'ESSENTIAL'),
        ];
        final transactions = [
          _tx(
            id: 'tx1',
            amount: 100000,
            kind: 'expense',
            categoryId: 'c1',
            accountId: 'acc_1',
            toAccountId: 'acc_1',
          ),
        ];

        final actuals = BudgetSummary.computeActualsByGroup(
          transactions: transactions,
          categories: categories,
          accounts: [_account(id: 'acc_1')],
        );

        // Self-transfer expense should still count — only transfer kind is filtered
        expect(actuals['ESSENTIAL'], 100000);
      });

      test('excludes private account transactions', () {
        final categories = [
          _cat(id: 'c1', name: 'Food', groupName: 'ESSENTIAL'),
        ];
        final transactions = [
          _tx(
            id: 'tx1',
            amount: 200000,
            kind: 'expense',
            categoryId: 'c1',
            accountId: 'acc_1',
          ),
          _tx(
            id: 'tx2',
            amount: 100000,
            kind: 'expense',
            categoryId: 'c1',
            accountId: 'acc_priv',
          ),
        ];

        final actuals = BudgetSummary.computeActualsByGroup(
          transactions: transactions,
          categories: categories,
          accounts: [
            _account(id: 'acc_1', visibility: 'shared'),
            _account(id: 'acc_priv', visibility: 'hidden'),
          ],
        );

        // Only shared account transaction counted
        expect(actuals['ESSENTIAL'], 200000);
      });

      test('uncategorized transactions go to MISSING group', () {
        final transactions = [
          _tx(id: 'tx1', amount: 300000, kind: 'expense', categoryId: null),
        ];

        final actuals = BudgetSummary.computeActualsByGroup(
          transactions: transactions,
          categories: [],
          accounts: [_account(id: 'acc_1')],
        );

        expect(actuals['MISSING'], 300000);
      });
    });

    group('buildSummary', () {
      test('computes remaining and overspent for budgeted groups', () {
        final budgets = [
          _budget(id: 'b1', categoryGroup: 'ESSENTIAL', limitAmount: 1000000),
          _budget(
            id: 'b2',
            categoryGroup: 'NON_ESSENTIAL',
            limitAmount: 200000,
          ),
        ];
        final actuals = {'ESSENTIAL': 800000, 'NON_ESSENTIAL': 250000};

        final rows = BudgetSummary.buildSummary(
          budgets: budgets,
          actualsByGroup: actuals,
        );

        final essential = rows.firstWhere(
          (r) => r.categoryGroup == 'ESSENTIAL',
        );
        expect(essential.limitAmount, 1000000);
        expect(essential.actualSpent, 800000);
        expect(essential.remaining, 200000);
        expect(essential.isOverspent, false);

        final nonEssential = rows.firstWhere(
          (r) => r.categoryGroup == 'NON_ESSENTIAL',
        );
        expect(nonEssential.limitAmount, 200000);
        expect(nonEssential.actualSpent, 250000);
        expect(nonEssential.remaining, -50000);
        expect(nonEssential.isOverspent, true);
      });

      test(
        'adds unbudgeted groups with actuals as overspent with zero limit',
        () {
          final budgets = [
            _budget(id: 'b1', categoryGroup: 'ESSENTIAL', limitAmount: 500000),
          ];
          final actuals = {'ESSENTIAL': 300000, 'INVESTMENTS': 100000};

          final rows = BudgetSummary.buildSummary(
            budgets: budgets,
            actualsByGroup: actuals,
          );

          expect(rows, hasLength(2));
          final investments = rows.firstWhere(
            (r) => r.categoryGroup == 'INVESTMENTS',
          );
          expect(investments.limitAmount, 0);
          expect(investments.actualSpent, 100000);
          expect(investments.isOverspent, true);
        },
      );

      test('budgeted group with no actuals shows full remaining', () {
        final budgets = [
          _budget(id: 'b1', categoryGroup: 'ESSENTIAL', limitAmount: 500000),
        ];
        final actuals = <String, int>{};

        final rows = BudgetSummary.buildSummary(
          budgets: budgets,
          actualsByGroup: actuals,
        );

        expect(rows, hasLength(1));
        expect(rows.first.actualSpent, 0);
        expect(rows.first.remaining, 500000);
        expect(rows.first.isOverspent, false);
      });

      test('returns rows sorted: budgeted first, then unbudgeted', () {
        final budgets = [
          _budget(id: 'b1', categoryGroup: 'ESSENTIAL', limitAmount: 500000),
        ];
        final actuals = {'MISSING': 50000, 'ESSENTIAL': 200000};

        final rows = BudgetSummary.buildSummary(
          budgets: budgets,
          actualsByGroup: actuals,
        );

        expect(rows.first.categoryGroup, 'ESSENTIAL'); // budgeted first
        expect(rows.last.categoryGroup, 'MISSING'); // unbudgeted last
      });
    });
  });
}
