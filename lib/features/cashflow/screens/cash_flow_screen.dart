import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/financial/cash_flow_engine.dart';
import '../../../core/providers/session_providers.dart';
import '../../../shared/theme/spacing.dart';
import '../providers/cash_flow_providers.dart';
import '../../recurring/screens/recurring_form_screen.dart';
import '../widgets/cash_flow_alert_row.dart';
import '../widgets/cash_flow_day_row.dart';
import '../widgets/threshold_config_sheet.dart';

/// Cash flow vertical timeline screen showing day-by-day income/expense
/// projection with running balances and threshold alerts.
class CashFlowScreen extends ConsumerStatefulWidget {
  const CashFlowScreen({super.key});

  @override
  ConsumerState<CashFlowScreen> createState() => _CashFlowScreenState();
}

class _CashFlowScreenState extends ConsumerState<CashFlowScreen> {
  @override
  Widget build(BuildContext context) {
    final month = ref.watch(selectedCashFlowMonthProvider);
    final familyId = ref.watch(sessionFamilyIdProvider);

    if (familyId == null) {
      return const Scaffold(body: Center(child: Text('No family selected')));
    }

    final projectionAsync = ref.watch(
      cashFlowProjectionProvider((familyId: familyId, month: month)),
    );
    final accountNamesAsync = ref.watch(accountNamesProvider(familyId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cash Flow'),
            Text(
              DateFormat('MMMM yyyy').format(month),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              final current = ref.read(selectedCashFlowMonthProvider);
              ref
                  .read(selectedCashFlowMonthProvider.notifier)
                  .set(DateTime(current.year, current.month - 1));
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final current = ref.read(selectedCashFlowMonthProvider);
              ref
                  .read(selectedCashFlowMonthProvider.notifier)
                  .set(DateTime(current.year, current.month + 1));
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _openThresholdConfig(familyId),
          ),
        ],
      ),
      body: projectionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $e'),
              const SizedBox(height: Spacing.md),
              FilledButton(
                onPressed: () => ref.invalidate(
                  cashFlowProjectionProvider((
                    familyId: familyId,
                    month: month,
                  )),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (days) => accountNamesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (names) => _buildTimeline(days, names),
        ),
      ),
    );
  }

  Widget _buildTimeline(
    List<DayProjection> days,
    Map<String, String> accountNames,
  ) {
    if (days.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today, size: 48),
            SizedBox(height: Spacing.md),
            Text('No recurring rules configured'),
            SizedBox(height: Spacing.sm),
            Text('Add income or expense rules to see your cash flow'),
          ],
        ),
      );
    }

    // Flatten days into a list of widgets (alerts first, then day row)
    final widgets = <Widget>[];
    for (final day in days) {
      // Render alert rows for this day
      for (final alert in day.alerts) {
        widgets.add(
          CashFlowAlertRow(
            key: ValueKey('alert_${alert.accountId}_${alert.date}'),
            alert: alert,
            accountName: accountNames[alert.accountId] ?? alert.accountId,
          ),
        );
      }
      // Render day row
      widgets.add(
        CashFlowDayRow(
          key: ValueKey('day_${day.date}'),
          day: day,
          accountNames: accountNames,
          onItemTap: _onItemTap,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: Spacing.sm, bottom: Spacing.xl),
      children: widgets,
    );
  }

  void _onItemTap(String ruleId) {
    final familyId = ref.read(sessionFamilyIdProvider);
    if (familyId == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            RecurringFormScreen(familyId: familyId, editingId: ruleId),
      ),
    );
  }

  void _openThresholdConfig(String familyId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ThresholdConfigSheet(familyId: familyId),
    );
  }
}
