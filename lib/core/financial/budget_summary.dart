import '../database/database.dart';

/// A row in the budget summary: one per category group.
class BudgetSummaryRow {
  final String categoryGroup;
  final int limitAmount;
  final int actualSpent;
  final String? budgetId;

  int get remaining => limitAmount - actualSpent;
  bool get isOverspent => actualSpent > limitAmount;

  const BudgetSummaryRow({
    required this.categoryGroup,
    required this.limitAmount,
    required this.actualSpent,
    this.budgetId,
  });
}

/// Pure aggregation functions for budget vs actuals computation.
///
/// Algorithm (from BudgetSummaryService.java):
/// 1. Compute actuals by CategoryGroup from expense transactions
/// 2. Build summary rows: budgeted groups with remaining/overspent + unbudgeted groups
class BudgetSummary {
  BudgetSummary._();

  static const _expenseKinds = {'expense', 'emiPayment', 'insurancePremium'};

  /// Computes actual spend per category group from transactions.
  ///
  /// Filters:
  /// - Expense types only (expense, emiPayment, insurancePremium)
  /// - Shared accounts only (excludes hidden)
  /// - Maps each transaction's categoryId → category → groupName
  /// - Uncategorized transactions go to 'MISSING'
  static Map<String, int> computeActualsByGroup({
    required List<Transaction> transactions,
    required List<Category> categories,
    required List<Account> accounts,
  }) {
    // Build lookup maps
    final categoryById = {for (final c in categories) c.id: c};
    final sharedAccountIds = {
      for (final a in accounts)
        if (a.visibility != 'hidden') a.id,
    };

    final actuals = <String, int>{};

    for (final tx in transactions) {
      // Filter: expense kinds only
      if (!_expenseKinds.contains(tx.kind)) continue;

      // Filter: shared accounts only
      if (!sharedAccountIds.contains(tx.accountId)) continue;

      // Resolve category group
      final category = tx.categoryId != null
          ? categoryById[tx.categoryId]
          : null;
      final group = category?.groupName ?? 'MISSING';

      actuals[group] = (actuals[group] ?? 0) + tx.amount;
    }

    return actuals;
  }

  /// Builds budget summary rows from budgets and computed actuals.
  ///
  /// - Budgeted groups get remaining = limit - actual
  /// - Unbudgeted groups with actuals appear with limit = 0 (always overspent)
  /// - Results sorted: budgeted first, then unbudgeted
  static List<BudgetSummaryRow> buildSummary({
    required List<Budget> budgets,
    required Map<String, int> actualsByGroup,
  }) {
    final budgetedGroups = <String>{};
    final rows = <BudgetSummaryRow>[];

    // Budgeted groups first
    for (final b in budgets) {
      budgetedGroups.add(b.categoryGroup);
      rows.add(
        BudgetSummaryRow(
          categoryGroup: b.categoryGroup,
          limitAmount: b.limitAmount,
          actualSpent: actualsByGroup[b.categoryGroup] ?? 0,
          budgetId: b.id,
        ),
      );
    }

    // Unbudgeted groups with actuals
    for (final entry in actualsByGroup.entries) {
      if (!budgetedGroups.contains(entry.key)) {
        rows.add(
          BudgetSummaryRow(
            categoryGroup: entry.key,
            limitAmount: 0,
            actualSpent: entry.value,
          ),
        );
      }
    }

    return rows;
  }
}
