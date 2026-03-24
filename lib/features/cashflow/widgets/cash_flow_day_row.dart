import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/financial/cash_flow_engine.dart';
import '../../../core/models/money.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/theme/spacing.dart';

/// Renders a single day's cash flow items with date header, item list, and
/// running balance badges per account.
class CashFlowDayRow extends StatelessWidget {
  const CashFlowDayRow({
    super.key,
    required this.day,
    required this.accountNames,
    this.onItemTap,
  });

  final DayProjection day;
  final Map<String, String> accountNames;
  final void Function(String ruleId)? onItemTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = ColorTokens.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.xs,
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Text(
              DateFormat('EEE, d MMM').format(day.date),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            // Items
            for (final item in day.items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: _itemIcon(item.kind, tokens),
                title: Text(item.ruleName),
                subtitle: Text(accountNames[item.accountId] ?? item.accountId),
                trailing: Text(
                  _formattedAmount(item),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _amountColor(item.kind, tokens),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: onItemTap != null ? () => onItemTap!(item.ruleId) : null,
              ),
            const SizedBox(height: Spacing.sm),
            // Running balance badges
            Wrap(
              spacing: Spacing.sm,
              runSpacing: Spacing.xs,
              children: [
                for (final entry in day.runningBalancesByAccount.entries)
                  Chip(
                    label: Text(
                      '${accountNames[entry.key] ?? entry.key}: ${Money(entry.value).formatted}',
                      style: theme.textTheme.labelSmall,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemIcon(String kind, ColorTokens tokens) {
    switch (kind) {
      case 'income':
        return Icon(Icons.arrow_upward, color: tokens.income);
      case 'expense':
        return Icon(Icons.arrow_downward, color: tokens.expense);
      case 'transfer':
        return Icon(Icons.swap_horiz, color: tokens.primary);
      default:
        return Icon(Icons.circle, color: tokens.onSurfaceVariant);
    }
  }

  String _formattedAmount(CashFlowItem item) {
    final money = Money(item.amountPaise);
    switch (item.kind) {
      case 'income':
        return '+${money.formatted}';
      case 'expense':
        return '-${money.formatted}';
      default:
        return money.formatted;
    }
  }

  Color _amountColor(String kind, ColorTokens tokens) {
    switch (kind) {
      case 'income':
        return tokens.income;
      case 'expense':
        return tokens.expense;
      default:
        return tokens.onSurface;
    }
  }
}
