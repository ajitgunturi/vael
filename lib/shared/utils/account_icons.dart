import 'package:flutter/material.dart';

/// Maps account types to Material icons and classifies liability types.
class AccountIcons {
  AccountIcons._();

  static const _liabilityTypes = {'loan', 'creditCard'};

  /// Returns the Material icon for the given account [type] string.
  static IconData iconFor(String type) {
    switch (type) {
      case 'savings':
      case 'current':
        return Icons.account_balance;
      case 'creditCard':
        return Icons.credit_card;
      case 'loan':
        return Icons.payments_outlined;
      case 'investment':
        return Icons.trending_up;
      case 'wallet':
      default:
        return Icons.account_balance_wallet;
    }
  }

  /// Whether this account type represents a liability (loan or credit card).
  static bool isLiability(String type) => _liabilityTypes.contains(type);
}
