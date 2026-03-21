import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import 'database_providers.dart';

/// Streams all non-deleted accounts for [familyId].
///
/// Rebuilds automatically when the accounts table changes (drift stream).
final accountsProvider =
    StreamProvider.family<List<Account>, String>((ref, familyId) {
  final dao = ref.watch(accountDaoProvider);
  return dao.watchAll(familyId);
});

/// Asset account types — balances contribute positively to net worth.
const _assetTypes = {'savings', 'current', 'investment', 'wallet'};

/// Liability account types — balances subtract from net worth.
const _liabilityTypes = {'creditCard', 'loan'};

/// Computes family net worth (assets − liabilities) in minor units (paise).
///
/// Only includes accounts with visibility `shared` or `familyWide`.
/// Excludes `private_` accounts from the family-level calculation.
final netWorthProvider =
    StreamProvider.family<int, String>((ref, familyId) {
  final dao = ref.watch(accountDaoProvider);
  return dao.watchAll(familyId).map((accounts) {
    int netWorth = 0;
    for (final account in accounts) {
      // Exclude private accounts from family net worth
      if (account.visibility == 'private_') continue;

      if (_assetTypes.contains(account.type)) {
        netWorth += account.balance;
      } else if (_liabilityTypes.contains(account.type)) {
        netWorth -= account.balance;
      }
    }
    return netWorth;
  });
});
