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
      expect(CategoryGroupMapper.resolve(null, 'Food'), 'ESSENTIAL');
      expect(CategoryGroupMapper.resolve(null, 'Groceries'), 'ESSENTIAL');
      expect(CategoryGroupMapper.resolve(null, 'Rent'), 'ESSENTIAL');
      expect(
        CategoryGroupMapper.resolve(null, 'Entertainment'),
        'NON_ESSENTIAL',
      );
      expect(CategoryGroupMapper.resolve(null, 'Shopping'), 'NON_ESSENTIAL');
      expect(CategoryGroupMapper.resolve(null, 'EMI'), 'HOME_EXPENSES');
      expect(CategoryGroupMapper.resolve(null, 'SIP'), 'INVESTMENTS');
      expect(CategoryGroupMapper.resolve(null, 'Insurance'), 'INVESTMENTS');
    });

    test('unknown category returns MISSING', () {
      expect(CategoryGroupMapper.resolve(null, 'UnknownCategory'), 'MISSING');
      expect(CategoryGroupMapper.resolve(null, null), 'MISSING');
    });

    test('empty groupName with known category falls through to legacy map', () {
      expect(CategoryGroupMapper.resolve('', 'Food'), 'ESSENTIAL');
      expect(CategoryGroupMapper.resolve('', 'Shopping'), 'NON_ESSENTIAL');
    });

    test('MISSING groupName falls through to legacy map', () {
      expect(CategoryGroupMapper.resolve('MISSING', 'Rent'), 'ESSENTIAL');
      expect(CategoryGroupMapper.resolve('MISSING', 'Travel'), 'NON_ESSENTIAL');
    });
  });
}
