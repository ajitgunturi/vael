import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/database.dart';
import '../../../core/providers/transaction_providers.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/utils/formatters.dart';
import 'transaction_form_screen.dart';

/// Displays all transactions for a family, grouped by date.
class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({
    super.key,
    required this.familyId,
    required this.userId,
  });

  final String familyId;
  final String userId;

  static const _incomeKinds = {'income', 'salary', 'dividend'};
  static const _expenseKinds = {'expense', 'emiPayment', 'insurancePremium'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txnAsync = ref.watch(transactionsProvider(familyId));

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context),
        child: const Icon(Icons.add),
      ),
      body: txnAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (transactions) => _buildBody(context, transactions),
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
            const SizedBox(height: 16),
            const Text('No transactions yet'),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => _navigateToForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Transaction'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: transactions.length,
      itemBuilder: (context, index) =>
          _TransactionTile(transaction: transactions[index]),
    );
  }

  void _navigateToForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TransactionFormScreen(
          familyId: familyId,
          userId: userId,
        ),
      ),
    );
  }

  /// Returns the display color for a transaction kind.
  static Color amountColor(String kind) {
    if (_incomeKinds.contains(kind)) return ColorTokens.positive;
    if (_expenseKinds.contains(kind)) return ColorTokens.negative;
    // ignore: deprecated_member_use
    return ColorTokens.neutralStatic; // transfer
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
}
