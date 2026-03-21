import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/models/enums.dart';

void main() {
  group('AccountType', () {
    test('should have exactly 6 values', () {
      expect(AccountType.values.length, 6);
    });

    test('should contain all expected values', () {
      expect(
        AccountType.values,
        containsAll([
          AccountType.savings,
          AccountType.current,
          AccountType.creditCard,
          AccountType.loan,
          AccountType.investment,
          AccountType.wallet,
        ]),
      );
    });

    test('should be lookable by name', () {
      for (final value in AccountType.values) {
        expect(AccountType.values.byName(value.name), value);
      }
    });
  });

  group('TransactionKind', () {
    test('should have exactly 7 values', () {
      expect(TransactionKind.values.length, 7);
    });

    test('should contain all expected values', () {
      expect(
        TransactionKind.values,
        containsAll([
          TransactionKind.income,
          TransactionKind.salary,
          TransactionKind.expense,
          TransactionKind.transfer,
          TransactionKind.emiPayment,
          TransactionKind.insurancePremium,
          TransactionKind.dividend,
        ]),
      );
    });

    test('should be lookable by name', () {
      for (final value in TransactionKind.values) {
        expect(TransactionKind.values.byName(value.name), value);
      }
    });
  });

  group('CategoryGroup', () {
    test('should have exactly 5 values', () {
      expect(CategoryGroup.values.length, 5);
    });

    test('should contain all expected values', () {
      expect(
        CategoryGroup.values,
        containsAll([
          CategoryGroup.essential,
          CategoryGroup.nonEssential,
          CategoryGroup.investments,
          CategoryGroup.homeExpenses,
          CategoryGroup.missing,
        ]),
      );
    });

    test('should be lookable by name', () {
      for (final value in CategoryGroup.values) {
        expect(CategoryGroup.values.byName(value.name), value);
      }
    });
  });

  group('Visibility', () {
    test('should have exactly 3 values', () {
      expect(Visibility.values.length, 3);
    });

    test('should contain all expected values', () {
      expect(
        Visibility.values,
        containsAll([
          Visibility.private_,
          Visibility.shared,
          Visibility.familyWide,
        ]),
      );
    });

    test('should be lookable by name', () {
      for (final value in Visibility.values) {
        expect(Visibility.values.byName(value.name), value);
      }
    });
  });

  group('BucketType', () {
    test('should have exactly 8 values', () {
      expect(BucketType.values.length, 8);
    });

    test('should contain all expected values', () {
      expect(
        BucketType.values,
        containsAll([
          BucketType.mutualFunds,
          BucketType.stocks,
          BucketType.ppf,
          BucketType.epf,
          BucketType.nps,
          BucketType.fixedDeposit,
          BucketType.bonds,
          BucketType.policy,
        ]),
      );
    });

    test('should be lookable by name', () {
      for (final value in BucketType.values) {
        expect(BucketType.values.byName(value.name), value);
      }
    });
  });

  group('UserRole', () {
    test('should have exactly 2 values', () {
      expect(UserRole.values.length, 2);
    });

    test('should contain all expected values', () {
      expect(UserRole.values, containsAll([UserRole.admin, UserRole.member]));
    });

    test('should be lookable by name', () {
      for (final value in UserRole.values) {
        expect(UserRole.values.byName(value.name), value);
      }
    });
  });

  group('GoalStatus', () {
    test('should have exactly 4 values', () {
      expect(GoalStatus.values.length, 4);
    });

    test('should contain all expected values', () {
      expect(
        GoalStatus.values,
        containsAll([
          GoalStatus.active,
          GoalStatus.onTrack,
          GoalStatus.atRisk,
          GoalStatus.completed,
        ]),
      );
    });

    test('should be lookable by name', () {
      for (final value in GoalStatus.values) {
        expect(GoalStatus.values.byName(value.name), value);
      }
    });
  });
}
