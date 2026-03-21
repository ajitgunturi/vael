import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../database/daos/transaction_dao.dart';
import 'database_providers.dart';

/// Provides TransactionDao from the database.
final transactionDaoProvider = Provider<TransactionDao>((ref) {
  return TransactionDao(ref.watch(databaseProvider));
});

/// Streams all transactions for [familyId], ordered by date descending.
final transactionsProvider = StreamProvider.family<List<Transaction>, String>((
  ref,
  familyId,
) {
  final dao = ref.watch(transactionDaoProvider);
  return dao.watchAll(familyId);
});
