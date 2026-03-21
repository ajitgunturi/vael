import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/database/daos/account_dao.dart';
import '../../../core/financial/dashboard_aggregation.dart';
import '../../../core/providers/database_providers.dart';

/// Streams grouped accounts for a family (banking, investments, loans, creditCards).
final groupedAccountsProvider =
    StreamProvider.family<AccountGroups, String>((ref, familyId) {
  final dao = ref.watch(accountDaoProvider);
  return dao.watchAll(familyId).map(DashboardAggregation.groupAccounts);
});

/// Provides AccountDao for CRUD operations in the account form.
final accountCrudProvider = Provider<AccountDao>((ref) {
  return ref.watch(accountDaoProvider);
});
