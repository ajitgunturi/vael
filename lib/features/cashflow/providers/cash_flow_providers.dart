import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/daos/account_dao.dart';
import '../../../core/database/daos/recurring_rule_dao.dart';
import '../../../core/database/database.dart' as db;
import '../../../core/financial/cash_flow_engine.dart';
import '../../../core/financial/recurring_scheduler.dart';
import '../../../core/providers/database_providers.dart';

/// Notifier for selected cash flow month (first day of month).
class SelectedCashFlowMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void set(DateTime month) => state = DateTime(month.year, month.month);
}

/// Holds the currently selected month for the cash flow screen.
final selectedCashFlowMonthProvider =
    NotifierProvider<SelectedCashFlowMonthNotifier, DateTime>(
      SelectedCashFlowMonthNotifier.new,
    );

/// Builds [CashFlowItem] list from recurring rules for a given month range.
///
/// Pure function -- no DB access. Filters deleted rules, computes due dates
/// via [RecurringScheduler.computeDueDates], and escalated amounts via
/// [RecurringScheduler.escalatedAmount].
List<CashFlowItem> buildCashFlowItems(
  List<RecurringRule> rules,
  DateTime monthStart,
  DateTime monthEnd,
) {
  final items = <CashFlowItem>[];
  for (final rule in rules) {
    if (rule.deletedAt != null) continue;
    final dates = RecurringScheduler.computeDueDates(
      rule: rule,
      from: monthStart,
      until: monthEnd,
    );
    for (final date in dates) {
      final amount = RecurringScheduler.escalatedAmount(
        rule: rule,
        asOfDate: date,
      );
      items.add(
        CashFlowItem(
          date: date,
          ruleId: rule.id,
          ruleName: rule.name,
          accountId: rule.accountId,
          toAccountId: rule.toAccountId,
          kind: rule.kind,
          amountPaise: amount,
        ),
      );
    }
  }
  return items;
}

/// Converts a Drift [db.RecurringRule] to the scheduler's [RecurringRule].
RecurringRule _toSchedulerRule(db.RecurringRule row) {
  return RecurringRule(
    id: row.id,
    name: row.name,
    kind: row.kind,
    amount: row.amount,
    accountId: row.accountId,
    toAccountId: row.toAccountId,
    frequencyMonths: row.frequencyMonths,
    startDate: row.startDate,
    endDate: row.endDate,
    isPaused: row.isPaused,
    pausedAt: row.pausedAt,
    lastExecutedDate: row.lastExecutedDate,
    annualEscalationRate: row.annualEscalationRate,
    categoryId: row.categoryId,
    deletedAt: row.deletedAt,
  );
}

/// Cash flow projection provider keyed by (familyId, month).
///
/// Fetches rules from DAO, generates [CashFlowItem]s via [RecurringScheduler],
/// then feeds to [CashFlowEngine.projectMonth] for day-by-day projection.
final cashFlowProjectionProvider =
    FutureProvider.family<
      List<DayProjection>,
      ({String familyId, DateTime month})
    >((ref, params) async {
      final database = ref.read(databaseProvider);
      final ruleDao = RecurringRuleDao(database);
      final accountDao = AccountDao(database);

      // 1. Get rules for family
      final dbRules = await ruleDao.watchAll(params.familyId).first;
      final rules = dbRules.map(_toSchedulerRule).toList();

      // 2. Get accounts for starting balances
      final accounts = await accountDao.watchAll(params.familyId).first;
      final startingBalances = <String, int>{};
      for (final acc in accounts) {
        if (acc.deletedAt == null) startingBalances[acc.id] = acc.balance;
      }

      // 3. Get thresholds
      final thresholds = await accountDao.getThresholds(params.familyId);

      // 4. Build cash flow items for the month
      final monthStart = params.month;
      final monthEnd = DateTime(params.month.year, params.month.month + 1);
      final items = buildCashFlowItems(rules, monthStart, monthEnd);

      // 5. Project
      return CashFlowEngine.projectMonth(
        startingBalances: startingBalances,
        items: items,
        thresholds: thresholds,
      );
    });

/// Account names provider for display (accountId -> name).
final accountNamesProvider = FutureProvider.family<Map<String, String>, String>(
  (ref, familyId) async {
    final database = ref.read(databaseProvider);
    final accounts = await AccountDao(database).watchAll(familyId).first;
    return {
      for (final a in accounts)
        if (a.deletedAt == null) a.id: a.name,
    };
  },
);
