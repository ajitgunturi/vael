import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/financial/category_group_mapper.dart';

void main() {
  group('CategoryGroupMapper', () {
    test('known group name passes through', () {
      expect(CategoryGroupMapper.resolve('ESSENTIAL', 'Food'), 'ESSENTIAL');
      expect(
        CategoryGroupMapper.resolve('NON_ESSENTIAL', null),
        'NON_ESSENTIAL',
      );
      expect(CategoryGroupMapper.resolve('INVESTMENTS', 'SIP'), 'INVESTMENTS');
    });

    test('legacy category name maps correctly', () {
      // Living Expense group
      expect(CategoryGroupMapper.resolve(null, 'Groceries'), 'LIVING_EXPENSE');
      expect(
        CategoryGroupMapper.resolve(null, 'Utility Bills'),
        'LIVING_EXPENSE',
      );

      // Home Expenses group
      expect(CategoryGroupMapper.resolve(null, 'Rent'), 'HOME_EXPENSES');
      expect(CategoryGroupMapper.resolve(null, 'Maintenance'), 'HOME_EXPENSES');

      // Luxury Non-Essential group
      expect(
        CategoryGroupMapper.resolve(null, 'Entertainment'),
        'LUXURY_NON_ESSENTIAL',
      );
      expect(
        CategoryGroupMapper.resolve(null, 'Shopping'),
        'LUXURY_NON_ESSENTIAL',
      );
      expect(
        CategoryGroupMapper.resolve(null, 'Travel'),
        'LUXURY_NON_ESSENTIAL',
      );

      // Essential group
      expect(CategoryGroupMapper.resolve(null, 'Insurance'), 'ESSENTIAL');
      expect(CategoryGroupMapper.resolve(null, 'Medical'), 'ESSENTIAL');

      // Investments group
      expect(CategoryGroupMapper.resolve(null, 'SIP'), 'INVESTMENTS');
      expect(CategoryGroupMapper.resolve(null, 'Investments'), 'INVESTMENTS');

      // Philanthropy
      expect(CategoryGroupMapper.resolve(null, 'Donation'), 'PHILANTHROPY');
      expect(CategoryGroupMapper.resolve(null, 'Temple'), 'PHILANTHROPY');

      // Liabilities
      expect(CategoryGroupMapper.resolve(null, 'Home Loan'), 'LIABILITIES');
      expect(
        CategoryGroupMapper.resolve(null, 'Credit Card Bill'),
        'LIABILITIES',
      );

      // Assets
      expect(CategoryGroupMapper.resolve(null, 'Banking'), 'ASSETS');
      expect(CategoryGroupMapper.resolve(null, 'RSU Sale'), 'ASSETS');

      // Self-Improvement
      expect(CategoryGroupMapper.resolve(null, 'Books'), 'SELF_IMPROVEMENT');
      expect(
        CategoryGroupMapper.resolve(null, 'Certification'),
        'SELF_IMPROVEMENT',
      );

      // Luxury Essential
      expect(
        CategoryGroupMapper.resolve(null, 'Dining Out'),
        'LUXURY_ESSENTIAL',
      );
      expect(CategoryGroupMapper.resolve(null, 'Fitness'), 'LUXURY_ESSENTIAL');
    });

    test('unknown category returns MISSING', () {
      expect(CategoryGroupMapper.resolve(null, 'UnknownCategory'), 'MISSING');
      expect(CategoryGroupMapper.resolve(null, null), 'MISSING');
    });

    test('empty groupName with known category falls through to legacy map', () {
      expect(CategoryGroupMapper.resolve('', 'Groceries'), 'LIVING_EXPENSE');
      expect(
        CategoryGroupMapper.resolve('', 'Shopping'),
        'LUXURY_NON_ESSENTIAL',
      );
    });

    test('MISSING groupName falls through to legacy map', () {
      expect(CategoryGroupMapper.resolve('MISSING', 'Rent'), 'HOME_EXPENSES');
      expect(
        CategoryGroupMapper.resolve('MISSING', 'Travel'),
        'LUXURY_NON_ESSENTIAL',
      );
    });
  });
}
