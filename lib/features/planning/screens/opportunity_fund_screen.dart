import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/database/daos/account_dao.dart';
import '../../../core/models/money.dart';
import '../../../core/providers/database_providers.dart';
import '../../../shared/theme/spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/opportunity_fund_providers.dart';

/// Opportunity fund designation and tracking screen.
///
/// Allows the user to designate a savings account as the opportunity fund
/// with a target amount, and tracks progress toward the target.
/// Tracked separately from emergency fund (OPP-02).
class OpportunityFundScreen extends ConsumerStatefulWidget {
  const OpportunityFundScreen({super.key, required this.familyId});

  final String familyId;

  @override
  ConsumerState<OpportunityFundScreen> createState() =>
      _OpportunityFundScreenState();
}

class _OpportunityFundScreenState extends ConsumerState<OpportunityFundScreen> {
  @override
  Widget build(BuildContext context) {
    final oppAsync = ref.watch(opportunityFundProvider(widget.familyId));

    return Scaffold(
      appBar: AppBar(title: const Text('Opportunity Fund')),
      body: oppAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (account) {
          if (account == null) {
            return _buildEmptyState(context);
          }
          return _buildDesignatedState(context, account);
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty state: no account designated
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: EmptyState(
        icon: Icons.account_balance_wallet_outlined,
        title: 'No opportunity fund designated',
        subtitle: 'Designate a savings account to track your opportunity fund.',
        actionLabel: 'Designate Account',
        onAction: () => _showDesignateSheet(context),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Designated state: show progress
  // ---------------------------------------------------------------------------

  Widget _buildDesignatedState(BuildContext context, Account account) {
    final balance = account.balance;
    final target = account.opportunityFundTargetPaise ?? 0;
    final progress = target > 0 ? (balance / target).clamp(0.0, 1.0) : 0.0;
    final progressPct = (progress * 100).toStringAsFixed(0);

    return ListView(
      padding: const EdgeInsets.all(Spacing.md),
      children: [
        // Hero card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              children: [
                Text(
                  account.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: Spacing.md),
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 10,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(
                            progress >= 0.9
                                ? Colors.green
                                : progress >= 0.5
                                ? Colors.amber
                                : Colors.red,
                          ),
                        ),
                      ),
                      Text(
                        '$progressPct%',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.md),
                Text(
                  'Balance: ${Money(balance).formatted}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (target > 0)
                  Text(
                    'Target: ${Money(target).formatted}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Spacing.lg),
        // Actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showDesignateSheet(context),
                child: const Text('Change Account'),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _removeDesignation(account.id),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Remove Designation'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Designate sheet
  // ---------------------------------------------------------------------------

  void _showDesignateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _DesignateSheet(familyId: widget.familyId),
    );
  }

  Future<void> _removeDesignation(String accountId) async {
    final dao = ref.read(accountDaoProvider);
    await AccountDao(dao.attachedDatabase).clearOpportunityFund(accountId);
  }
}

// ---------------------------------------------------------------------------
// Designate account bottom sheet
// ---------------------------------------------------------------------------

class _DesignateSheet extends ConsumerStatefulWidget {
  const _DesignateSheet({required this.familyId});
  final String familyId;

  @override
  ConsumerState<_DesignateSheet> createState() => _DesignateSheetState();
}

class _DesignateSheetState extends ConsumerState<_DesignateSheet> {
  String? _selectedAccountId;
  final _targetController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(
      availableForOpportunityFundProvider(widget.familyId),
    );

    return Padding(
      padding: EdgeInsets.only(
        left: Spacing.md,
        right: Spacing.md,
        top: Spacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + Spacing.md,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Designate Opportunity Fund',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Spacing.md),
            accountsAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
              data: (accounts) {
                if (accounts.isEmpty) {
                  return const Text('No eligible accounts available.');
                }
                return DropdownButtonFormField<String>(
                  initialValue: _selectedAccountId,
                  decoration: const InputDecoration(labelText: 'Account'),
                  items: accounts
                      .map(
                        (a) =>
                            DropdownMenuItem(value: a.id, child: Text(a.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedAccountId = v),
                  validator: (v) => v == null ? 'Select an account' : null,
                );
              },
            ),
            const SizedBox(height: Spacing.sm),
            TextFormField(
              controller: _targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target amount (in rupees)',
                suffixText: '\u20B9',
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (double.tryParse(v) == null) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: Spacing.md),
            FilledButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null) return;

    final targetRupees = double.parse(_targetController.text);
    final targetPaise = (targetRupees * 100).round();

    final dao = AccountDao(ref.read(databaseProvider));
    await dao.setOpportunityFund(_selectedAccountId!, targetPaise);

    if (mounted) Navigator.of(context).pop();
  }
}
