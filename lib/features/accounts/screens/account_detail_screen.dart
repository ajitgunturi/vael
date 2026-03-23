import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/providers/transaction_providers.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/theme/spacing.dart';
import '../../../shared/utils/account_icons.dart';
import '../../../shared/utils/formatters.dart';
import '../../loans/screens/loan_detail_screen.dart';
import '../../planning/screens/emergency_fund_screen.dart';
import '../../planning/widgets/ef_badge.dart';
import '../../planning/widgets/liquidity_tier_chip.dart';
import 'account_form_screen.dart';

/// Displays account details: name, type, balance, and recent transactions.
class AccountDetailScreen extends ConsumerWidget {
  const AccountDetailScreen({
    super.key,
    required this.account,
    required this.familyId,
  });

  final Account account;
  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = ColorTokens.of(context);
    final isLoan =
        account.type == 'homeLoan' ||
        account.type == 'personalLoan' ||
        account.type == 'carLoan' ||
        account.type == 'educationLoan' ||
        account.type == 'loan';

    return Scaffold(
      appBar: AppBar(
        title: Text(account.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          _AccountSummaryCard(
            account: account,
            familyId: familyId,
            theme: theme,
            colors: colors,
          ),
          if (isLoan) ...[
            const SizedBox(height: Spacing.md),
            _LoanDetailCard(accountId: account.id, familyId: familyId),
          ],
          const SizedBox(height: Spacing.lg),
          Text('Recent Transactions', style: theme.textTheme.titleMedium),
          const SizedBox(height: Spacing.sm),
          _TransactionList(familyId: familyId, accountId: account.id),
        ],
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AccountFormScreen(
          familyId: familyId,
          userId: account.userId,
          existingAccount: account,
        ),
      ),
    );
  }
}

class _AccountSummaryCard extends StatelessWidget {
  const _AccountSummaryCard({
    required this.account,
    required this.familyId,
    required this.theme,
    required this.colors,
  });

  final Account account;
  final String familyId;
  final ThemeData theme;
  final ColorTokens colors;

  @override
  Widget build(BuildContext context) {
    final balanceRupees = account.balance ~/ 100;
    final formatted = '₹${formatIndianNumber(balanceRupees)}';
    final isLiability = AccountIcons.isLiability(account.type);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AccountIcons.iconFor(account.type),
                  size: 32,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(account.name, style: theme.textTheme.titleMedium),
                      Text(
                        _accountTypeLabel(account.type),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Text(
              formatted,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isLiability ? colors.expense : colors.income,
              ),
            ),
            if (account.institution != null &&
                account.institution!.isNotEmpty) ...[
              const SizedBox(height: Spacing.xs),
              Text(
                account.institution!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
            if (account.isEmergencyFund || account.liquidityTier != null) ...[
              const SizedBox(height: Spacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (account.isEmergencyFund)
                    EfBadge(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EmergencyFundScreen(
                            familyId: familyId,
                            userId: account.userId,
                          ),
                        ),
                      ),
                    ),
                  if (account.liquidityTier != null)
                    LiquidityTierChip(tier: account.liquidityTier!),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _accountTypeLabel(String type) {
    switch (type) {
      case 'savings':
        return 'Savings Account';
      case 'current':
        return 'Current Account';
      case 'fd':
        return 'Fixed Deposit';
      case 'rd':
        return 'Recurring Deposit';
      case 'creditCard':
        return 'Credit Card';
      case 'homeLoan':
        return 'Home Loan';
      case 'personalLoan':
        return 'Personal Loan';
      case 'carLoan':
        return 'Car Loan';
      case 'educationLoan':
        return 'Education Loan';
      case 'loan':
        return 'Loan';
      case 'wallet':
        return 'Wallet';
      case 'ppf':
        return 'PPF';
      case 'nps':
        return 'NPS';
      case 'epf':
        return 'EPF';
      case 'mutualFund':
        return 'Mutual Fund';
      default:
        return type;
    }
  }
}

class _LoanDetailCard extends StatelessWidget {
  const _LoanDetailCard({required this.accountId, required this.familyId});

  final String accountId;
  final String familyId;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.account_balance),
        title: const Text('Loan Details'),
        subtitle: const Text('View amortization and EMI breakdown'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  LoanDetailScreen(accountId: accountId, familyId: familyId),
            ),
          );
        },
      ),
    );
  }
}

class _TransactionList extends ConsumerWidget {
  const _TransactionList({required this.familyId, required this.accountId});

  final String familyId;
  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txnAsync = ref.watch(transactionsProvider(familyId));
    final theme = Theme.of(context);
    final colors = ColorTokens.of(context);

    return txnAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
      data: (transactions) {
        final filtered = transactions
            .where(
              (t) => t.accountId == accountId || t.toAccountId == accountId,
            )
            .take(20)
            .toList();

        if (filtered.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
            child: Center(
              child: Text(
                'No transactions yet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          );
        }

        return Column(
          children: [
            for (final txn in filtered)
              _TransactionTile(txn: txn, colors: colors),
          ],
        );
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.txn, required this.colors});

  final Transaction txn;
  final ColorTokens colors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountRupees = txn.amount ~/ 100;
    final formatted = '₹${formatIndianNumber(amountRupees.abs())}';
    final isExpense = txn.kind == 'expense';
    final isTransfer = txn.kind == 'transfer';

    return ListTile(
      dense: true,
      title: Text(txn.description ?? txn.kind),
      subtitle: Text(
        '${txn.date.day}/${txn.date.month}/${txn.date.year}',
        style: theme.textTheme.bodySmall,
      ),
      trailing: Text(
        '${isExpense
            ? '-'
            : isTransfer
            ? ''
            : '+'}$formatted',
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: isExpense
              ? colors.expense
              : isTransfer
              ? colors.onSurfaceVariant
              : colors.income,
        ),
      ),
    );
  }
}
