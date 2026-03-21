import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/financial/dashboard_aggregation.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/utils/account_icons.dart';
import '../../../shared/utils/formatters.dart';
import '../providers/account_ui_providers.dart';
import 'account_form_screen.dart';

/// Displays accounts grouped by type (banking, investments, loans, credit cards).
class AccountListScreen extends ConsumerWidget {
  const AccountListScreen({super.key, required this.familyId});

  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedAsync = ref.watch(groupedAccountsProvider(familyId));

    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context),
        child: const Icon(Icons.add),
      ),
      body: groupedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (grouped) => _buildBody(context, grouped),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AccountGroups grouped) {
    final hasAny =
        grouped.banking.isNotEmpty ||
        grouped.investments.isNotEmpty ||
        grouped.loans.isNotEmpty ||
        grouped.creditCards.isNotEmpty;

    if (!hasAny) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            const Text('No accounts yet'),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => _navigateToForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Account'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        if (grouped.banking.isNotEmpty)
          _AccountSection(title: 'Banking', accounts: grouped.banking),
        if (grouped.investments.isNotEmpty)
          _AccountSection(title: 'Investments', accounts: grouped.investments),
        if (grouped.loans.isNotEmpty)
          _AccountSection(title: 'Loans', accounts: grouped.loans),
        if (grouped.creditCards.isNotEmpty)
          _AccountSection(title: 'Credit Cards', accounts: grouped.creditCards),
      ],
    );
  }

  void _navigateToForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AccountFormScreen(
          familyId: familyId,
          userId: 'user_$familyId', // TODO: get from auth provider
        ),
      ),
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({required this.title, required this.accounts});

  final String title;
  final List<Account> accounts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(title, style: theme.textTheme.titleSmall),
        ),
        for (final account in accounts) _AccountTile(account: account),
      ],
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = ColorTokens.of(context);
    final balanceRupees = account.balance ~/ 100;
    final formatted = '₹${formatIndianNumber(balanceRupees)}';
    final visLabel = _visibilityLabel(account.visibility);
    final isLiability = AccountIcons.isLiability(account.type);

    return ListTile(
      leading: Icon(
        AccountIcons.iconFor(account.type),
        color: colors.onSurfaceVariant,
      ),
      title: Text(account.name),
      subtitle: Text(visLabel),
      trailing: Text(
        formatted,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: isLiability ? colors.expense : null,
        ),
      ),
    );
  }

  String _visibilityLabel(String visibility) {
    switch (visibility) {
      case 'shared':
        return 'Shared';
      case 'private_':
        return 'Private';
      case 'familyWide':
        return 'Family Wide';
      default:
        return visibility;
    }
  }
}
