import 'package:drift/drift.dart';

import '../database/database.dart';

/// Seeds default category groups and categories for a new family.
///
/// India-native taxonomy derived from Expense Planner and Transaction
/// Tracker workbooks. Idempotent — skips if the family already has
/// groups or categories.
class CategorySeeder {
  CategorySeeder._();

  /// Default category groups with display order.
  static const defaultGroups = [
    ('ASSETS', 'Assets', 0),
    ('LIABILITIES', 'Liabilities', 1),
    ('HOME_EXPENSES', 'Home Expenses', 2),
    ('LIVING_EXPENSE', 'Living Expense', 3),
    ('ESSENTIAL', 'Essential', 4),
    ('LUXURY_ESSENTIAL', 'Luxury Essential', 5),
    ('LUXURY_NON_ESSENTIAL', 'Luxury Non-Essential', 6),
    ('PHILANTHROPY', 'Philanthropy', 7),
    ('SELF_IMPROVEMENT', 'Self-Improvement', 8),
    ('INVESTMENTS', 'Investments', 9),
    ('NON_ESSENTIAL', 'Non-Essential', 10),
    ('MISSING', 'Uncategorized', 11),
  ];

  /// Default categories: (name, groupId, type).
  static const defaultCategories = [
    // Home Expenses
    ('Rent', 'HOME_EXPENSES', 'EXPENSE'),
    ('Electricity', 'HOME_EXPENSES', 'EXPENSE'),
    ('Water & Gas', 'HOME_EXPENSES', 'EXPENSE'),
    ('Internet', 'HOME_EXPENSES', 'EXPENSE'),
    ('Society Maintenance', 'HOME_EXPENSES', 'EXPENSE'),
    ('Home Maintenance', 'HOME_EXPENSES', 'EXPENSE'),
    ('Property Tax', 'HOME_EXPENSES', 'EXPENSE'),

    // Living Expense
    ('Groceries', 'LIVING_EXPENSE', 'EXPENSE'),
    ('Milk & Dairy', 'LIVING_EXPENSE', 'EXPENSE'),
    ('Vegetables & Fruits', 'LIVING_EXPENSE', 'EXPENSE'),
    ('Household Supplies', 'LIVING_EXPENSE', 'EXPENSE'),
    ('Cook/Maid Salary', 'LIVING_EXPENSE', 'EXPENSE'),
    ('Snacks', 'LIVING_EXPENSE', 'EXPENSE'),
    ('Beverages', 'LIVING_EXPENSE', 'EXPENSE'),
    ('Parking', 'LIVING_EXPENSE', 'EXPENSE'),
    ('Utility Bills', 'LIVING_EXPENSE', 'EXPENSE'),

    // Essential
    ('Medical Consultation', 'ESSENTIAL', 'EXPENSE'),
    ('Medical Test', 'ESSENTIAL', 'EXPENSE'),
    ('Medicines', 'ESSENTIAL', 'EXPENSE'),
    ('Health Insurance', 'ESSENTIAL', 'EXPENSE'),
    ('Life Insurance', 'ESSENTIAL', 'EXPENSE'),
    ('Vehicle Insurance', 'ESSENTIAL', 'EXPENSE'),
    ('School Fees', 'ESSENTIAL', 'EXPENSE'),
    ('Education', 'ESSENTIAL', 'EXPENSE'),
    ('Children Activities', 'ESSENTIAL', 'EXPENSE'),
    ('Phone Recharge', 'ESSENTIAL', 'EXPENSE'),
    ('Flowers', 'ESSENTIAL', 'EXPENSE'),
    ('Pooja & Pooja Items', 'ESSENTIAL', 'EXPENSE'),
    ('Tax Filing', 'ESSENTIAL', 'EXPENSE'),
    ('Diet', 'ESSENTIAL', 'EXPENSE'),

    // Luxury Essential
    ('Dining Out', 'LUXURY_ESSENTIAL', 'EXPENSE'),
    ('Order In/Food Delivery', 'LUXURY_ESSENTIAL', 'EXPENSE'),
    ('Subscriptions', 'LUXURY_ESSENTIAL', 'EXPENSE'),
    ('Clothing', 'LUXURY_ESSENTIAL', 'EXPENSE'),
    ('Personal Care/Salon', 'LUXURY_ESSENTIAL', 'EXPENSE'),
    ('Fitness', 'LUXURY_ESSENTIAL', 'EXPENSE'),
    ('Vehicle Fuel', 'LUXURY_ESSENTIAL', 'EXPENSE'),
    ('Vehicle Service', 'LUXURY_ESSENTIAL', 'EXPENSE'),

    // Luxury Non-Essential
    ('Travel', 'LUXURY_NON_ESSENTIAL', 'EXPENSE'),
    ('Movies & Entertainment', 'LUXURY_NON_ESSENTIAL', 'EXPENSE'),
    ('Electronics', 'LUXURY_NON_ESSENTIAL', 'EXPENSE'),
    ('Home Furnishing', 'LUXURY_NON_ESSENTIAL', 'EXPENSE'),
    ('Gifts', 'LUXURY_NON_ESSENTIAL', 'EXPENSE'),
    ('Shopping', 'LUXURY_NON_ESSENTIAL', 'EXPENSE'),
    ('Laundry', 'LUXURY_NON_ESSENTIAL', 'EXPENSE'),
    ('Phone Accessories', 'LUXURY_NON_ESSENTIAL', 'EXPENSE'),
    ('Pocket Money', 'LUXURY_NON_ESSENTIAL', 'EXPENSE'),
    ('Software Subscriptions', 'LUXURY_NON_ESSENTIAL', 'EXPENSE'),

    // Philanthropy
    ('Temple/Donations', 'PHILANTHROPY', 'EXPENSE'),
    ('Charity', 'PHILANTHROPY', 'EXPENSE'),
    ('Family Support', 'PHILANTHROPY', 'EXPENSE'),

    // Self-Improvement
    ('Books', 'SELF_IMPROVEMENT', 'EXPENSE'),
    ('Courses & Certification', 'SELF_IMPROVEMENT', 'EXPENSE'),
    ('Professional Development', 'SELF_IMPROVEMENT', 'EXPENSE'),

    // Investments (expense — outflow to investment accounts)
    ('SIP/Mutual Funds', 'INVESTMENTS', 'EXPENSE'),
    ('Stock Purchase', 'INVESTMENTS', 'EXPENSE'),
    ('FD Deposit', 'INVESTMENTS', 'EXPENSE'),
    ('PPF Contribution', 'INVESTMENTS', 'EXPENSE'),
    ('NPS Contribution', 'INVESTMENTS', 'EXPENSE'),
    ('Gold Purchase', 'INVESTMENTS', 'EXPENSE'),
    ('Policy Premium', 'INVESTMENTS', 'EXPENSE'),

    // Non-Essential
    ('Miscellaneous', 'NON_ESSENTIAL', 'EXPENSE'),
    ('Cash Withdrawal', 'NON_ESSENTIAL', 'EXPENSE'),
    ('Uncategorized', 'NON_ESSENTIAL', 'EXPENSE'),

    // Assets (income — inflow from asset returns)
    ('Savings Transfer', 'ASSETS', 'INCOME'),
    ('Fixed Deposit Maturity', 'ASSETS', 'INCOME'),
    ('Mutual Fund Redemption', 'ASSETS', 'INCOME'),
    ('Stock Sale', 'ASSETS', 'INCOME'),
    ('Gold Redemption', 'ASSETS', 'INCOME'),
    ('PPF Withdrawal', 'ASSETS', 'INCOME'),
    ('NPS/EPF Withdrawal', 'ASSETS', 'INCOME'),

    // Liabilities (expense — EMI outflows)
    ('Home Loan EMI', 'LIABILITIES', 'EXPENSE'),
    ('Car/Personal Loan EMI', 'LIABILITIES', 'EXPENSE'),
    ('Credit Card Payment', 'LIABILITIES', 'EXPENSE'),

    // Income categories
    ('Salary', 'MISSING', 'INCOME'),
    ('Freelance Income', 'MISSING', 'INCOME'),
    ('Rental Income', 'MISSING', 'INCOME'),
    ('Dividend', 'MISSING', 'INCOME'),
    ('Interest Income', 'MISSING', 'INCOME'),
    ('Cashback/Refund', 'MISSING', 'INCOME'),
  ];

  /// Seeds default groups and categories for [familyId].
  ///
  /// Idempotent: does nothing if the family already has groups.
  static Future<void> seedDefaults(AppDatabase db, String familyId) async {
    final existingGroups = await (db.select(
      db.categoryGroups,
    )..where((g) => g.familyId.equals(familyId))).get();
    if (existingGroups.isNotEmpty) return;

    await db.batch((batch) {
      // Seed groups
      for (final (id, name, order) in defaultGroups) {
        batch.insert(
          db.categoryGroups,
          CategoryGroupsCompanion.insert(
            id: id,
            name: name,
            familyId: familyId,
            displayOrder: Value(order),
          ),
        );
      }

      // Seed categories — prefix IDs with familyId hash for cross-family
      // uniqueness while keeping them human-readable.
      final familyPrefix = familyId.hashCode.toRadixString(36).padLeft(4, '0');
      for (final (name, groupId, type) in defaultCategories) {
        final slug = name
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
            .replaceAll(RegExp(r'^_|_$'), '');
        batch.insert(
          db.categories,
          CategoriesCompanion.insert(
            id: '${familyPrefix}_cat_$slug',
            name: name,
            groupName: groupId,
            type: type,
            familyId: familyId,
          ),
        );
      }
    });
  }
}
