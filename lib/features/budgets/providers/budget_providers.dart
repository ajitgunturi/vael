import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/database/daos/budget_dao.dart';
import '../../../core/database/daos/transaction_dao.dart';
import '../../../core/financial/budget_summary.dart';
import '../../../core/providers/database_providers.dart';

/// Key for budget month selection: (familyId, year, month).
typedef BudgetMonthKey = ({String familyId, int year, int month});

/// Streams budgets for a given family/year/month.
final budgetsForMonthProvider =
    StreamProvider.family<List<Budget>, BudgetMonthKey>((ref, key) {
  final dao = ref.watch(budgetDaoProvider);
  return dao.watchForMonth(key.familyId, key.year, key.month);
});

/// Computes budget summary rows: budget limits vs actual spend.
///
/// Combines budgets, transactions, categories, and accounts to produce
/// per-group summary rows with remaining/overspent flags.
final budgetSummaryProvider =
    FutureProvider.family<List<BudgetSummaryRow>, BudgetMonthKey>(
        (ref, key) async {
  final db = ref.watch(databaseProvider);
  final budgetDao = BudgetDao(db);
  final transactionDao = TransactionDao(db);

  // Fetch budgets for the month
  final budgets = await budgetDao.getForMonth(key.familyId, key.year, key.month);

  // Fetch transactions for the month
  final monthStart = DateTime(key.year, key.month, 1);
  final monthEnd = DateTime(key.year, key.month + 1, 0, 23, 59, 59);
  final transactions = await transactionDao.getByDateRange(
    key.familyId,
    monthStart,
    monthEnd,
  );

  // Fetch categories and accounts
  final categories = await db.select(db.categories).get();
  final accounts = await (db.select(db.accounts)
        ..where((a) =>
            a.familyId.equals(key.familyId) & a.deletedAt.isNull()))
      .get();

  // Compute actuals and build summary
  final actuals = BudgetSummary.computeActualsByGroup(
    transactions: transactions,
    categories: categories,
    accounts: accounts,
  );

  return BudgetSummary.buildSummary(
    budgets: budgets,
    actualsByGroup: actuals,
  );
});
