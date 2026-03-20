import 'package:drift/drift.dart';

import '../database/database.dart';

/// Pure balance-delta computation for each transaction kind.
///
/// Rules:
/// - income / salary / dividend → credit fromAccount
/// - expense / emiPayment / insurancePremium → debit fromAccount
/// - transfer → debit fromAccount, credit toAccount
class BalanceRules {
  BalanceRules._();

  static const _creditKinds = {'income', 'salary', 'dividend'};
  static const _debitKinds = {'expense', 'emiPayment', 'insurancePremium'};

  /// Returns the delta to apply to fromAccount balance.
  /// For transfers, also returns delta for toAccount.
  ///
  /// Throws [ArgumentError] for unknown transaction kinds.
  static ({int fromDelta, int? toDelta}) computeDelta({
    required String kind,
    required int amount,
  }) {
    if (_creditKinds.contains(kind)) {
      return (fromDelta: amount, toDelta: null);
    }
    if (_debitKinds.contains(kind)) {
      return (fromDelta: -amount, toDelta: null);
    }
    if (kind == 'transfer') {
      return (fromDelta: -amount, toDelta: amount);
    }
    throw ArgumentError.value(kind, 'kind', 'Unknown transaction kind');
  }
}

/// Applies balance effects of a transaction atomically using drift
/// transactions.
class BalanceService {
  final AppDatabase _db;

  BalanceService(this._db);

  /// Applies a transaction's balance effect atomically.
  ///
  /// For transfers, both accounts are updated in a single drift transaction.
  /// Self-transfers are treated as no-ops.
  /// If `toAccountId` is null for a transfer, throws [StateError] and the
  /// drift transaction rolls back — no account is modified.
  Future<void> applyTransaction({
    required String kind,
    required int amount,
    required String fromAccountId,
    String? toAccountId,
  }) async {
    // Self-transfer is a no-op.
    if (kind == 'transfer' && fromAccountId == toAccountId) return;

    final deltas = BalanceRules.computeDelta(kind: kind, amount: amount);

    await _db.transaction(() async {
      // Update fromAccount balance.
      final fromRows = await (
        _db.update(_db.accounts)
          ..where((a) => a.id.equals(fromAccountId))
      ).write(AccountsCompanion.custom(
        balance: _db.accounts.balance + Variable<int>(deltas.fromDelta),
      ));

      if (fromRows == 0) {
        throw StateError('fromAccount $fromAccountId not found');
      }

      // For transfers, update toAccount as well.
      if (deltas.toDelta != null) {
        if (toAccountId == null) {
          throw StateError(
            'Transfer requires a toAccountId but none was provided',
          );
        }

        final toRows = await (
          _db.update(_db.accounts)
            ..where((a) => a.id.equals(toAccountId))
        ).write(AccountsCompanion.custom(
          balance: _db.accounts.balance + Variable<int>(deltas.toDelta!),
        ));

        if (toRows == 0) {
          throw StateError('toAccount $toAccountId not found');
        }
      }
    });
  }
}
