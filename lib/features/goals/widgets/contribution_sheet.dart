import 'dart:convert';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/financial/sinking_fund_engine.dart';
import '../../../core/providers/transaction_providers.dart';
import '../../../shared/theme/spacing.dart';
import '../providers/goal_providers.dart';

/// Bottom sheet for adding a contribution to a sinking fund goal.
///
/// Creates a tagged transaction and updates goal progress via GoalDao.
class ContributionSheet extends ConsumerStatefulWidget {
  const ContributionSheet({super.key, required this.goal});

  final Goal goal;

  @override
  ConsumerState<ContributionSheet> createState() => _ContributionSheetState();
}

class _ContributionSheetState extends ConsumerState<ContributionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
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
                'Add Contribution',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                widget.goal.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.md),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\u20B9 ',
                ),
                keyboardType: TextInputType.number,
                autofocus: true,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  final parsed = int.tryParse(v.replaceAll(',', ''));
                  if (parsed == null || parsed <= 0) {
                    return 'Please enter a valid positive amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: Spacing.lg),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add Contribution'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final amountRupees = int.parse(_amountController.text.replaceAll(',', ''));
    final amountPaise = amountRupees * 100;
    final goal = widget.goal;
    final now = DateTime.now();

    // Create tagged transaction
    final txDao = ref.read(transactionDaoProvider);
    final accountId = goal.linkedAccountId ?? 'unlinked';
    await txDao.insertTransaction(
      TransactionsCompanion.insert(
        id: '${now.millisecondsSinceEpoch}',
        amount: amountPaise,
        date: now,
        description: Value('Contribution to ${goal.name}'),
        accountId: accountId,
        kind: 'transfer',
        metadata: Value(
          jsonEncode({'goalId': goal.id, 'type': 'sinkingFundContribution'}),
        ),
        familyId: goal.familyId,
      ),
    );

    // Update goal progress
    final newSavings = goal.currentSavings + amountPaise;
    final isComplete = SinkingFundEngine.isComplete(
      newSavings,
      goal.targetAmount,
    );
    final goalDao = ref.read(goalDaoProvider);
    await goalDao.updateProgress(
      goal.id,
      currentSavings: newSavings,
      status: isComplete ? 'completed' : goal.status,
    );

    if (mounted) Navigator.of(context).pop();
  }
}

/// Shows the contribution bottom sheet for a sinking fund goal.
void showContributionSheet(BuildContext context, Goal goal) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => ContributionSheet(goal: goal),
  );
}
