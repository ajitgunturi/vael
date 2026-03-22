import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/database/daos/investment_holding_dao.dart';
import '../../../core/providers/database_providers.dart';

final investmentHoldingDaoProvider = Provider<InvestmentHoldingDao>((ref) {
  return InvestmentHoldingDao(ref.watch(databaseProvider));
});

final investmentHoldingsProvider =
    StreamProvider.family<List<InvestmentHolding>, String>((ref, familyId) {
      final dao = ref.watch(investmentHoldingDaoProvider);
      return dao.watchAll(familyId);
    });
