import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/investment_holdings.dart';

part 'investment_holding_dao.g.dart';

@DriftAccessor(tables: [InvestmentHoldings])
class InvestmentHoldingDao extends DatabaseAccessor<AppDatabase>
    with _$InvestmentHoldingDaoMixin {
  InvestmentHoldingDao(super.db);

  Future<List<InvestmentHolding>> getAll(String familyId) {
    return (select(
      investmentHoldings,
    )..where((h) => h.familyId.equals(familyId))).get();
  }

  Future<InvestmentHolding?> getById(String id) {
    return (select(
      investmentHoldings,
    )..where((h) => h.id.equals(id))).getSingleOrNull();
  }

  Future<List<InvestmentHolding>> getByGoal(String goalId) {
    return (select(
      investmentHoldings,
    )..where((h) => h.linkedGoalId.equals(goalId))).get();
  }

  Stream<List<InvestmentHolding>> watchAll(String familyId) {
    return (select(
      investmentHoldings,
    )..where((h) => h.familyId.equals(familyId))).watch();
  }

  Future<int> insertHolding(InvestmentHoldingsCompanion entry) {
    return into(investmentHoldings).insert(entry);
  }

  Future<bool> updateHolding(InvestmentHoldingsCompanion entry) {
    return update(investmentHoldings).replace(
      InvestmentHolding(
        id: entry.id.value,
        name: entry.name.value,
        bucketType: entry.bucketType.value,
        investedAmount: entry.investedAmount.value,
        currentValue: entry.currentValue.value,
        expectedReturnRate: entry.expectedReturnRate.value,
        monthlyContribution: entry.monthlyContribution.value,
        linkedAccountId: entry.linkedAccountId.value,
        linkedGoalId: entry.linkedGoalId.value,
        familyId: entry.familyId.value,
        userId: entry.userId.value,
        visibility: entry.visibility.value,
        createdAt: entry.createdAt.value,
        updatedAt: entry.updatedAt.value,
      ),
    );
  }

  Future<int> deleteHolding(String id) {
    return (delete(investmentHoldings)..where((h) => h.id.equals(id))).go();
  }
}
