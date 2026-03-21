/// Account classification within the family ledger.
enum AccountType { savings, current, creditCard, loan, investment, wallet }

/// Semantic kind of a monetary transaction.
enum TransactionKind {
  income,
  salary,
  expense,
  transfer,
  emiPayment,
  insurancePremium,
  dividend,
}

/// High-level grouping for expense/income categories.
enum CategoryGroup {
  essential,
  nonEssential,
  investments,
  homeExpenses,
  missing,
}

/// Controls which family members can see a record.
///
/// [private_] uses a trailing underscore to avoid the Dart reserved keyword.
enum Visibility { private_, shared, familyWide }

/// Classification of investment buckets (India-native asset types).
enum BucketType {
  mutualFunds,
  stocks,
  ppf,
  epf,
  nps,
  fixedDeposit,
  bonds,
  policy,
}

/// Role within a family vault.
enum UserRole { admin, member }

/// Tracks progress state of a financial goal.
enum GoalStatus { active, onTrack, atRisk, completed }
