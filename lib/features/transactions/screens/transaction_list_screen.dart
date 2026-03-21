import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/database.dart';
import '../../../core/financial/transaction_grouping.dart';
import '../../../core/providers/transaction_providers.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/theme/spacing.dart';
import '../../../shared/utils/formatters.dart';
import 'transaction_form_screen.dart';

/// Displays all transactions for a family, grouped by date with search and
/// kind-based filtering.
class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({
    super.key,
    required this.familyId,
    required this.userId,
  });

  final String familyId;
  final String userId;

  static const _incomeKinds = {'income', 'salary', 'dividend'};
  static const _expenseKinds = {'expense', 'emiPayment', 'insurancePremium'};

  /// Returns the display color for a transaction kind.
  static Color amountColor(String kind) {
    if (_incomeKinds.contains(kind)) return ColorTokens.positive;
    if (_expenseKinds.contains(kind)) return ColorTokens.negative;
    // ignore: deprecated_member_use
    return ColorTokens.neutralStatic; // transfer
  }

  @override
  ConsumerState<TransactionListScreen> createState() =>
      _TransactionListScreenState();
}

enum _KindFilter { all, income, expense, transfer }

class _TransactionListScreenState
    extends ConsumerState<TransactionListScreen> {
  bool _searching = false;
  String _searchQuery = '';
  _KindFilter _activeFilter = _KindFilter.all;

  @override
  Widget build(BuildContext context) {
    final txnAsync = ref.watch(transactionsProvider(widget.familyId));

    return Scaffold(
      appBar: _searching
          ? AppBar(
              title: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search transactions…',
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  _searching = false;
                  _searchQuery = '';
                }),
              ),
            )
          : AppBar(
              title: const Text('Transactions'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => setState(() => _searching = true),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(transactionsProvider(widget.familyId));
        },
        child: txnAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (transactions) => _buildBody(context, transactions),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: Spacing.md),
            const Text('No transactions yet'),
            const SizedBox(height: Spacing.sm),
            FilledButton.icon(
              onPressed: () => _navigateToForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Transaction'),
            ),
          ],
        ),
      );
    }

    // Apply kind filter
    var filtered = transactions;
    if (_activeFilter != _KindFilter.all) {
      filtered = filtered.where((t) {
        switch (_activeFilter) {
          case _KindFilter.income:
            return TransactionListScreen._incomeKinds.contains(t.kind);
          case _KindFilter.expense:
            return TransactionListScreen._expenseKinds.contains(t.kind);
          case _KindFilter.transfer:
            return t.kind == 'transfer';
          case _KindFilter.all:
            return true;
        }
      }).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final lower = _searchQuery.toLowerCase();
      filtered = filtered.where((t) {
        final desc = t.description ?? '';
        final kind = _kindLabel(t.kind);
        return desc.toLowerCase().contains(lower) ||
            kind.toLowerCase().contains(lower);
      }).toList();
    }

    // Group by date
    final now = DateTime.now();
    final grouped = TransactionGrouping.groupByDate(
      filtered.map((t) => t.date).toList(),
      referenceDate: now,
    );

    // Build a flat list of headers + tiles
    final items = <Widget>[];
    var txnIndex = 0;

    for (final entry in grouped.entries) {
      items.add(_DateHeader(label: entry.key));
      for (var i = 0; i < entry.value.length; i++) {
        items.add(_TransactionTile(transaction: filtered[txnIndex]));
        txnIndex++;
      }
    }

    return Column(
      children: [
        _FilterChipRow(
          active: _activeFilter,
          onSelected: (f) => setState(() => _activeFilter = f),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: items,
          ),
        ),
      ],
    );
  }

  void _navigateToForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TransactionFormScreen(
          familyId: widget.familyId,
          userId: widget.userId,
        ),
      ),
    );
  }
}

class _FilterChipRow extends StatelessWidget {
  const _FilterChipRow({required this.active, required this.onSelected});

  final _KindFilter active;
  final ValueChanged<_KindFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md, vertical: Spacing.sm),
      child: Row(
        children: [
          _chip(context, 'All', _KindFilter.all),
          const SizedBox(width: Spacing.sm),
          _chip(context, 'Income', _KindFilter.income),
          const SizedBox(width: Spacing.sm),
          _chip(context, 'Expense', _KindFilter.expense),
          const SizedBox(width: Spacing.sm),
          _chip(context, 'Transfer', _KindFilter.transfer),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label, _KindFilter filter) {
    return FilterChip(
      label: Text(label),
      selected: active == filter,
      onSelected: (_) => onSelected(filter),
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = ColorTokens.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Spacing.md, Spacing.md, Spacing.md, Spacing.xs),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountRupees = transaction.amount ~/ 100;
    final formatted = '₹${formatIndianNumber(amountRupees)}';
    final color = TransactionListScreen.amountColor(transaction.kind);
    final dateStr = DateFormat('dd MMM yyyy').format(transaction.date);
    final kindLabel = _kindLabel(transaction.kind);

    return ListTile(
      title: Text(transaction.description ?? kindLabel),
      subtitle: Text('$kindLabel · $dateStr'),
      trailing: Text(
        formatted,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String _kindLabel(String kind) {
  switch (kind) {
    case 'income':
      return 'Income';
    case 'salary':
      return 'Salary';
    case 'expense':
      return 'Expense';
    case 'transfer':
      return 'Transfer';
    case 'emiPayment':
      return 'EMI Payment';
    case 'insurancePremium':
      return 'Insurance';
    case 'dividend':
      return 'Dividend';
    default:
      return kind;
  }
}
