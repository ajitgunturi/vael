import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/providers/database_providers.dart';

// ---------------------------------------------------------------------------
// Opportunity fund account (nullable stream)
// ---------------------------------------------------------------------------

/// Watches the account designated as opportunity fund for a family.
/// Emits null if no account is designated.
final opportunityFundProvider = StreamProvider.family<Account?, String>((
  ref,
  familyId,
) {
  final dao = ref.watch(accountDaoProvider);
  return dao.watchOpportunityFund(familyId);
});

// ---------------------------------------------------------------------------
// Accounts available for OPP designation
// ---------------------------------------------------------------------------

/// Returns all non-deleted accounts that are not already designated as
/// emergency fund or opportunity fund. Used to populate the "Designate
/// Account" picker.
final availableForOpportunityFundProvider =
    FutureProvider.family<List<Account>, String>((ref, familyId) async {
      final dao = ref.watch(accountDaoProvider);
      final accounts = await dao.watchAll(familyId).first;
      return accounts
          .where((a) => !a.isEmergencyFund && !a.isOpportunityFund)
          .toList();
    });
