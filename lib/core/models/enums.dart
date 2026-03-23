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
///
/// Source of truth for groups is the `category_groups` DB table.
/// This enum serves as a reference for known built-in groups and
/// display mapping. Custom user-created groups won't appear here.
enum CategoryGroup {
  assets,
  liabilities,
  homeExpenses,
  livingExpense,
  essential,
  luxuryEssential,
  luxuryNonEssential,
  philanthropy,
  selfImprovement,
  investments,
  nonEssential,
  missing,
}

/// Controls which family members can see a record.
///
/// Three-tier privacy model per UI_DESIGN.md §0.5:
/// - [shared] — full details visible to all family members
/// - [nameOnly] — name/label visible, amounts hidden from non-owners
/// - [hidden] — completely invisible to non-owners (private)
enum Visibility { hidden, nameOnly, shared }

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

/// Broad asset class for allocation targeting.
enum AssetClass { equity, debt, gold, cash }

/// Category of a financial goal.
enum GoalCategory { investmentGoal, purchase, retirement }

/// Type of financial decision being modeled.
enum DecisionType {
  jobChange,
  salaryNegotiation,
  majorPurchase,
  investmentWithdrawal,
  rentalChange,
  custom,
}
