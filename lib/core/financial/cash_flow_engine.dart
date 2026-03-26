import 'package:collection/collection.dart';

/// A single cash flow event on a specific date.
///
/// All amounts are in **paise** (integer minor units).
class CashFlowItem {
  final DateTime date;
  final String ruleId;
  final String ruleName;
  final String accountId;
  final String? toAccountId; // non-null for transfers
  final String kind; // 'income', 'expense', 'transfer'
  final int amountPaise;

  const CashFlowItem({
    required this.date,
    required this.ruleId,
    required this.ruleName,
    required this.accountId,
    this.toAccountId,
    required this.kind,
    required this.amountPaise,
  });
}

/// A single day's projection containing items, running balances, and alerts.
class DayProjection {
  final DateTime date;
  final List<CashFlowItem> items;
  final Map<String, int> runningBalancesByAccount; // accountId -> paise
  final List<ThresholdAlert> alerts;

  const DayProjection({
    required this.date,
    required this.items,
    required this.runningBalancesByAccount,
    required this.alerts,
  });
}

/// Alert generated when an account balance dips below its threshold.
class ThresholdAlert {
  final String accountId;
  final DateTime
  date; // the day the balance dips -- needed for locked alert text format
  final int balancePaise;
  final int thresholdPaise;

  const ThresholdAlert({
    required this.accountId,
    required this.date,
    required this.balancePaise,
    required this.thresholdPaise,
  });
}

/// Pure static computation engine for day-by-day cash flow projection.
///
/// Projects running balances per account from cash flow items and generates
/// threshold alerts when any account balance dips below its minimum.
/// No DB imports, no mutable state, no async.
class CashFlowEngine {
  CashFlowEngine._();

  /// Projects day-by-day running balances from cash flow items.
  ///
  /// [startingBalances] maps accountId to current balance in paise.
  /// [items] is the list of cash flow events to project.
  /// [thresholds] maps accountId to minimum balance in paise for alerts.
  ///
  /// Returns a list of [DayProjection] sorted by date ascending.
  /// Only days with items appear (no gap-filling between dates).
  static List<DayProjection> projectMonth({
    required Map<String, int> startingBalances,
    required List<CashFlowItem> items,
    required Map<String, int> thresholds,
  }) {
    if (items.isEmpty) return [];

    // 1. Group items by date
    final grouped = groupBy(items, (CashFlowItem item) => item.date);

    // 2. Sort date keys ascending
    final sortedDates = grouped.keys.toList()..sort();

    // 3. Initialize running balances
    final runningBalances = Map<String, int>.from(startingBalances);

    // 4. For each date, apply items and check thresholds
    final projections = <DayProjection>[];
    for (final date in sortedDates) {
      final dayItems = grouped[date]!;

      for (final item in dayItems) {
        switch (item.kind) {
          case 'income':
            runningBalances[item.accountId] =
                (runningBalances[item.accountId] ?? 0) + item.amountPaise;
          case 'expense':
            runningBalances[item.accountId] =
                (runningBalances[item.accountId] ?? 0) - item.amountPaise;
          case 'transfer':
            runningBalances[item.accountId] =
                (runningBalances[item.accountId] ?? 0) - item.amountPaise;
            if (item.toAccountId != null) {
              runningBalances[item.toAccountId!] =
                  (runningBalances[item.toAccountId!] ?? 0) + item.amountPaise;
            }
        }
      }

      // Check thresholds for alerts
      final alerts = <ThresholdAlert>[];
      for (final entry in thresholds.entries) {
        final balance = runningBalances[entry.key] ?? 0;
        if (balance < entry.value) {
          alerts.add(
            ThresholdAlert(
              accountId: entry.key,
              date: date,
              balancePaise: balance,
              thresholdPaise: entry.value,
            ),
          );
        }
      }

      projections.add(
        DayProjection(
          date: date,
          items: dayItems,
          runningBalancesByAccount: Map<String, int>.from(runningBalances),
          alerts: alerts,
        ),
      );
    }

    return projections;
  }
}
