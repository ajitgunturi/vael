/// Maps legacy category names to their canonical group identifiers.
///
/// Used as a fallback when a transaction's category group is missing
/// or set to 'MISSING'. Covers all 81 category names from the
/// Expense Planner and Transaction Tracker xlsx workbooks.
class CategoryGroupMapper {
  CategoryGroupMapper._();

  static const _legacyMap = {
    // Assets
    'Investments - PPF': 'ASSETS',
    'Investments - Policies': 'ASSETS',
    'Investments - Stocks and MF': 'ASSETS',
    'Investments - Amma': 'ASSETS',
    'Investments - Savings': 'ASSETS',
    'Investments - Gold': 'ASSETS',
    'Investments - Returns': 'ASSETS',
    'Investment Returns': 'ASSETS',
    'Balance': 'ASSETS',
    'Savings Transfer': 'ASSETS',
    'Fixed Deposit': 'ASSETS',
    'Mutual Funds': 'ASSETS',
    'Stocks': 'ASSETS',
    'Gold': 'ASSETS',
    'PPF': 'ASSETS',
    'NPS': 'ASSETS',
    'NPS/EPF': 'ASSETS',
    'RSU Sale': 'ASSETS',
    'Stock Sale': 'ASSETS',
    'Banking': 'ASSETS',

    // Liabilities
    'Home Loan': 'LIABILITIES',
    'Dzire - EMI': 'LIABILITIES',
    'Home Loan EMI': 'LIABILITIES',
    'Car Loan EMI': 'LIABILITIES',
    'Car/Personal Loan EMI': 'LIABILITIES',
    'Personal Loan EMI': 'LIABILITIES',
    'Credit Card Payment': 'LIABILITIES',
    'Credit Card Bill': 'LIABILITIES',
    'Loan': 'LIABILITIES',

    // Home Expenses
    'Home Maintenance': 'HOME_EXPENSES',
    'Maintenance': 'HOME_EXPENSES',
    'Rent': 'HOME_EXPENSES',
    'Electricity': 'HOME_EXPENSES',
    'Water & Gas': 'HOME_EXPENSES',
    'Internet': 'HOME_EXPENSES',
    'Society Maintenance': 'HOME_EXPENSES',
    'Property Tax': 'HOME_EXPENSES',
    'Pravallika': 'HOME_EXPENSES',

    // Living Expense
    'Groceries': 'LIVING_EXPENSE',
    'Living Expenses': 'LIVING_EXPENSE',
    'Milk & Dairy': 'LIVING_EXPENSE',
    'Vegetables & Fruits': 'LIVING_EXPENSE',
    'Household Supplies': 'LIVING_EXPENSE',
    'Cook/Maid Salary': 'LIVING_EXPENSE',
    'Snacks': 'LIVING_EXPENSE',
    'Bevarages': 'LIVING_EXPENSE',
    'Beverages': 'LIVING_EXPENSE',
    'Parking': 'LIVING_EXPENSE',
    'Medical Test': 'LIVING_EXPENSE',
    'Utility Bills': 'LIVING_EXPENSE',
    'Home Needs': 'LIVING_EXPENSE',

    // Essential
    'Medical': 'ESSENTIAL',
    'Medical Consultation': 'ESSENTIAL',
    'Medicines': 'ESSENTIAL',
    'Health Insurance': 'ESSENTIAL',
    'Life Insurance': 'ESSENTIAL',
    'Vehicle Insurance': 'ESSENTIAL',
    'Insurance': 'ESSENTIAL',
    'School Fees': 'ESSENTIAL',
    'Education': 'ESSENTIAL',
    'Children Activities': 'ESSENTIAL',
    'Activities': 'ESSENTIAL',
    'Phone Recharge': 'ESSENTIAL',
    'Flowers': 'ESSENTIAL',
    'Flowers, Fruits and Vegetables': 'ESSENTIAL',
    'Fruits and Vegetables': 'ESSENTIAL',
    'Pooja': 'ESSENTIAL',
    'Pooja Items': 'ESSENTIAL',
    'Pooja and Pooja Items': 'ESSENTIAL',
    'Tax Filing': 'ESSENTIAL',
    'Income Tax': 'ESSENTIAL',
    'Diet': 'ESSENTIAL',
    'Policy Payout': 'ESSENTIAL',

    // Luxury Essential
    'Dining Out': 'LUXURY_ESSENTIAL',
    'Dine-in': 'LUXURY_ESSENTIAL',
    'Dine-out': 'LUXURY_ESSENTIAL',
    'Dine Out': 'LUXURY_ESSENTIAL',
    'Order In': 'LUXURY_ESSENTIAL',
    'Order In/Food Delivery': 'LUXURY_ESSENTIAL',
    'Cafe': 'LUXURY_ESSENTIAL',
    'Subscriptions': 'LUXURY_ESSENTIAL',
    'Subscription': 'LUXURY_ESSENTIAL',
    'Clothing': 'LUXURY_ESSENTIAL',
    'Clothes and Apparel': 'LUXURY_ESSENTIAL',
    'Personal Care/Salon': 'LUXURY_ESSENTIAL',
    'Salon and Grooming': 'LUXURY_ESSENTIAL',
    'Saloon': 'LUXURY_ESSENTIAL',
    'Saloon and Spa': 'LUXURY_ESSENTIAL',
    'Fitness': 'LUXURY_ESSENTIAL',
    'Fitness - Ajit': 'LUXURY_ESSENTIAL',
    'Vehicle Fuel': 'LUXURY_ESSENTIAL',
    'Vehicle Service': 'LUXURY_ESSENTIAL',
    'Dzire - Petrol': 'LUXURY_ESSENTIAL',
    'Dzire - Servicing': 'LUXURY_ESSENTIAL',
    'Dzire': 'LUXURY_ESSENTIAL',
    'Vehicle Up-Keep': 'LUXURY_ESSENTIAL',
    'Goal Expense': 'LUXURY_ESSENTIAL',
    'Jupiter': 'LUXURY_ESSENTIAL',
    'Office': 'LUXURY_ESSENTIAL',

    // Luxury Non-Essential
    'Travel': 'LUXURY_NON_ESSENTIAL',
    'Travel Expenses': 'LUXURY_NON_ESSENTIAL',
    'Movies & Entertainment': 'LUXURY_NON_ESSENTIAL',
    'Movies': 'LUXURY_NON_ESSENTIAL',
    'Entertainment': 'LUXURY_NON_ESSENTIAL',
    'Electronics': 'LUXURY_NON_ESSENTIAL',
    'Home Furnishing': 'LUXURY_NON_ESSENTIAL',
    'Home Decor': 'LUXURY_NON_ESSENTIAL',
    'Furniture': 'LUXURY_NON_ESSENTIAL',
    'Gifts': 'LUXURY_NON_ESSENTIAL',
    'Shopping': 'LUXURY_NON_ESSENTIAL',
    'Laundry': 'LUXURY_NON_ESSENTIAL',
    'Phone Accesories': 'LUXURY_NON_ESSENTIAL',
    'Phone Accessories': 'LUXURY_NON_ESSENTIAL',
    'Pocket Money': 'LUXURY_NON_ESSENTIAL',
    'Software Subscriptions': 'LUXURY_NON_ESSENTIAL',
    'Fashion - Ajit': 'LUXURY_NON_ESSENTIAL',
    'Fashion - Pravallika': 'LUXURY_NON_ESSENTIAL',
    'Celebration': 'LUXURY_NON_ESSENTIAL',

    // Philanthropy
    'Temple/Donations': 'PHILANTHROPY',
    'Donation': 'PHILANTHROPY',
    'Temple': 'PHILANTHROPY',
    'Charity': 'PHILANTHROPY',
    'Family Support': 'PHILANTHROPY',

    // Self-Improvement
    'Books': 'SELF_IMPROVEMENT',
    'Courses & Certification': 'SELF_IMPROVEMENT',
    'Certification': 'SELF_IMPROVEMENT',
    'Professional Development': 'SELF_IMPROVEMENT',
    'Productivity': 'SELF_IMPROVEMENT',
    'Life Skills': 'SELF_IMPROVEMENT',
    'Self Improvement': 'SELF_IMPROVEMENT',

    // Investments (as expense — SIP contributions, etc.)
    'SIP': 'INVESTMENTS',
    'SIP/Mutual Funds': 'INVESTMENTS',
    'SIP Investment': 'INVESTMENTS',
    'Stock Purchase': 'INVESTMENTS',
    'FD Deposit': 'INVESTMENTS',
    'PPF Contribution': 'INVESTMENTS',
    'NPS Contribution': 'INVESTMENTS',
    'Gold Purchase': 'INVESTMENTS',
    'Policy Premium': 'INVESTMENTS',
    'Investment': 'INVESTMENTS',
    'Investments': 'INVESTMENTS',

    // Non-Essential
    'Miscellaneous': 'NON_ESSENTIAL',
    'Cash Withdrawal': 'NON_ESSENTIAL',
    'Unknown': 'NON_ESSENTIAL',
    'Uncategorized': 'NON_ESSENTIAL',
    'Cancellation': 'NON_ESSENTIAL',
    'Avenger': 'NON_ESSENTIAL',
    'NLA-202': 'NON_ESSENTIAL',

    // Income types (mapped for budget fallback)
    'Salary': 'INCOME',
    'Cashback': 'INCOME',
    'Refund': 'INCOME',
    'Bank Interest': 'INCOME',
    'Self-Transfer': 'SELF_TRANSFER',
    'Un Categorized Inward Remittance': 'INCOME',
  };

  /// Resolves a category group name, falling back to the legacy map
  /// when [groupName] is null, empty, or 'MISSING'.
  static String resolve(String? groupName, String? categoryName) {
    if (groupName != null && groupName.isNotEmpty && groupName != 'MISSING') {
      return groupName;
    }
    if (categoryName != null) {
      return _legacyMap[categoryName] ?? 'MISSING';
    }
    return 'MISSING';
  }
}
