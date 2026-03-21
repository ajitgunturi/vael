import '../database/database.dart';

/// Dashboard scope: family-wide vs personal (single user).
enum DashboardScope { family, personal }

/// Account groups for dashboard display.
class AccountGroups {
  /// Banking: savings, current, wallet.
  final List<Account> banking;

  /// Investment accounts.
  final List<Account> investments;

  /// Loan accounts.
  final List<Account> loans;

  /// Credit card accounts.
  final List<Account> creditCards;

  const AccountGroups({
    required this.banking,
    required this.investments,
    required this.loans,
    required this.creditCards,
  });
}

/// Monthly income/expense summary.
class MonthlySummary {
  /// Sum of income/salary/dividend amounts in paise.
  final int totalIncome;

  /// Sum of expense/emiPayment/insurancePremium amounts in paise.
  final int totalExpenses;

  /// Income minus expenses.
  int get netSavings => totalIncome - totalExpenses;

  const MonthlySummary({
    required this.totalIncome,
    required this.totalExpenses,
  });
}

/// Pure aggregation functions for the dashboard.
///
/// All functions are stateless — they take data in and return computed results.
/// No DB access; the caller fetches data and passes it here.
class DashboardAggregation {
  DashboardAggregation._();

  static const _assetTypes = {'savings', 'current', 'investment', 'wallet'};
  static const _liabilityTypes = {'creditCard', 'loan'};
  static const _incomeKinds = {'income', 'salary', 'dividend'};
  static const _expenseKinds = {'expense', 'emiPayment', 'insurancePremium'};

  /// Groups accounts into banking, investments, loans, and creditCards.
  static AccountGroups groupAccounts(List<Account> accounts) {
    final banking = <Account>[];
    final investments = <Account>[];
    final loans = <Account>[];
    final creditCards = <Account>[];

    for (final a in accounts) {
      switch (a.type) {
        case 'savings' || 'current' || 'wallet':
          banking.add(a);
        case 'investment':
          investments.add(a);
        case 'loan':
          loans.add(a);
        case 'creditCard':
          creditCards.add(a);
      }
    }

    return AccountGroups(
      banking: banking,
      investments: investments,
      loans: loans,
      creditCards: creditCards,
    );
  }

  /// Computes net worth: sum of asset balances minus sum of liability balances.
  static int computeNetWorth(List<Account> accounts) {
    int netWorth = 0;
    for (final a in accounts) {
      if (_assetTypes.contains(a.type)) {
        netWorth += a.balance;
      } else if (_liabilityTypes.contains(a.type)) {
        netWorth -= a.balance;
      }
    }
    return netWorth;
  }

  /// Computes monthly income/expense summary from a list of transactions.
  ///
  /// Transfers are excluded — they are internal movements, not income or expense.
  static MonthlySummary monthlySummary(List<Transaction> transactions) {
    int income = 0;
    int expenses = 0;

    for (final tx in transactions) {
      if (_incomeKinds.contains(tx.kind)) {
        income += tx.amount;
      } else if (_expenseKinds.contains(tx.kind)) {
        expenses += tx.amount;
      }
      // transfers are excluded
    }

    return MonthlySummary(totalIncome: income, totalExpenses: expenses);
  }

  /// Filters accounts by scope.
  ///
  /// - [DashboardScope.family]: shared + familyWide (excludes private_)
  /// - [DashboardScope.personal]: only accounts owned by [userId]
  static List<Account> filterByScope(
    List<Account> accounts, {
    required DashboardScope scope,
    String? userId,
  }) {
    switch (scope) {
      case DashboardScope.family:
        return accounts
            .where((a) => a.visibility != 'private_')
            .toList();
      case DashboardScope.personal:
        assert(userId != null, 'userId required for personal scope');
        return accounts.where((a) => a.userId == userId).toList();
    }
  }
}
