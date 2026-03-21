import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/shared/utils/account_icons.dart';

void main() {
  group('AccountIcons', () {
    test('returns correct icon for each account type', () {
      expect(AccountIcons.iconFor('savings'), Icons.account_balance);
      expect(AccountIcons.iconFor('current'), Icons.account_balance);
      expect(AccountIcons.iconFor('creditCard'), Icons.credit_card);
      expect(AccountIcons.iconFor('loan'), Icons.payments_outlined);
      expect(AccountIcons.iconFor('investment'), Icons.trending_up);
      expect(AccountIcons.iconFor('wallet'), Icons.account_balance_wallet);
    });

    test('returns default icon for unknown type', () {
      expect(AccountIcons.iconFor('unknown'), Icons.account_balance_wallet);
    });

    test('isLiability returns true for loan and creditCard', () {
      expect(AccountIcons.isLiability('loan'), isTrue);
      expect(AccountIcons.isLiability('creditCard'), isTrue);
    });

    test('isLiability returns false for asset types', () {
      expect(AccountIcons.isLiability('savings'), isFalse);
      expect(AccountIcons.isLiability('current'), isFalse);
      expect(AccountIcons.isLiability('investment'), isFalse);
      expect(AccountIcons.isLiability('wallet'), isFalse);
    });
  });
}
