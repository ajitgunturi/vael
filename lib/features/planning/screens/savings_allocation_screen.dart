import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database.dart';
import '../../../core/financial/savings_allocation_engine.dart' as engine;
import '../../../core/models/money.dart';
import '../../../core/providers/database_providers.dart';
import '../../../shared/theme/spacing.dart';
import '../providers/savings_allocation_providers.dart';

/// Savings allocation screen: rule management with drag-to-reorder and
/// advisory surplus distribution output.
///
/// SAVE-04 compliance: output is advisory only -- NO "Apply" or
/// "Create Transaction" buttons exist anywhere on this screen.
class SavingsAllocationScreen extends ConsumerStatefulWidget {
  const SavingsAllocationScreen({super.key, required this.familyId});

  final String familyId;

  @override
  ConsumerState<SavingsAllocationScreen> createState() =>
      _SavingsAllocationScreenState();
}

class _SavingsAllocationScreenState
    extends ConsumerState<SavingsAllocationScreen> {
  @override
  Widget build(BuildContext context) {
    final rulesAsync = ref.watch(allocationRulesProvider(widget.familyId));
    final advisoryAsync = ref.watch(
      allocationAdvisoryProvider(widget.familyId),
    );
    final surplusAsync = ref.watch(monthlySurplusProvider(widget.familyId));

    return Scaffold(
      appBar: AppBar(title: const Text('Savings Allocation')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          // Section A: Rules List
          _buildRulesSection(context, rulesAsync),
          const SizedBox(height: Spacing.lg),
          // Section B: Advisory Output
          _buildAdvisorySection(context, advisoryAsync, surplusAsync),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section A: Rules
  // ---------------------------------------------------------------------------

  Widget _buildRulesSection(
    BuildContext context,
    AsyncValue<List<SavingsAllocationRule>> rulesAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Allocation Rules',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton.icon(
              onPressed: () => _showAddRuleSheet(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Rule'),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        rulesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error loading rules: $e'),
          data: (rules) {
            if (rules.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: Spacing.lg),
                child: Center(
                  child: Text(
                    'No allocation rules yet. Add one to get started.',
                  ),
                ),
              );
            }
            return ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rules.length,
              onReorder: (oldIndex, newIndex) =>
                  _onReorder(rules, oldIndex, newIndex),
              itemBuilder: (context, index) {
                final rule = rules[index];
                return _RuleCard(
                  key: ValueKey(rule.id),
                  rule: rule,
                  index: index,
                  onDelete: () => _deleteRule(rule.id),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Future<void> _onReorder(
    List<SavingsAllocationRule> rules,
    int oldIndex,
    int newIndex,
  ) async {
    if (oldIndex < newIndex) newIndex -= 1;
    final ids = rules.map((r) => r.id).toList();
    final id = ids.removeAt(oldIndex);
    ids.insert(newIndex, id);

    final dao = ref.read(savingsAllocationRuleDaoProvider);
    await dao.reorderPriorities(widget.familyId, ids);
  }

  Future<void> _deleteRule(String id) async {
    final dao = ref.read(savingsAllocationRuleDaoProvider);
    await dao.softDelete(id);
  }

  // ---------------------------------------------------------------------------
  // Add Rule bottom sheet
  // ---------------------------------------------------------------------------

  void _showAddRuleSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddRuleSheet(familyId: widget.familyId),
    );
  }

  // ---------------------------------------------------------------------------
  // Section B: Advisory Output
  // ---------------------------------------------------------------------------

  Widget _buildAdvisorySection(
    BuildContext context,
    AsyncValue<List<engine.AllocationAdvice>> advisoryAsync,
    AsyncValue<int> surplusAsync,
  ) {
    final surplus = surplusAsync.whenOrNull(data: (v) => v) ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "This Month's Surplus Allocation",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              Money(surplus).formatted,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: surplus > 0 ? Colors.green : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        advisoryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (advices) {
            if (surplus <= 0 || advices.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: Spacing.md),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Colors.grey),
                    SizedBox(width: Spacing.sm),
                    Text('No surplus to allocate this month'),
                  ],
                ),
              );
            }
            return Column(
              children: [
                for (final advice in advices) _AdvisoryRow(advice: advice),
                const SizedBox(height: Spacing.sm),
                Text(
                  'Advisory only \u2014 no transactions are created automatically',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Rule card widget
// ---------------------------------------------------------------------------

class _RuleCard extends StatelessWidget {
  const _RuleCard({
    super.key,
    required this.rule,
    required this.index,
    required this.onDelete,
  });

  final SavingsAllocationRule rule;
  final int index;
  final VoidCallback onDelete;

  IconData _iconForType(String targetType) {
    return switch (targetType) {
      'emergencyFund' => Icons.shield_outlined,
      'sinkingFund' => Icons.savings_outlined,
      'investmentGoal' => Icons.trending_up,
      'opportunityFund' => Icons.account_balance_wallet_outlined,
      _ => Icons.attach_money,
    };
  }

  String _labelForType(String targetType) {
    return switch (targetType) {
      'emergencyFund' => 'Emergency Fund',
      'sinkingFund' => 'Sinking Fund',
      'investmentGoal' => 'Investment Goal',
      'opportunityFund' => 'Opportunity Fund',
      _ => targetType,
    };
  }

  @override
  Widget build(BuildContext context) {
    final allocationLabel = rule.allocationType == 'fixed'
        ? 'Fixed ${Money(rule.amountPaise ?? 0).formatted}'
        : '${((rule.percentageBp ?? 0) / 100.0).toStringAsFixed(1)}% of surplus';

    return Card(
      child: ListTile(
        leading: CircleAvatar(radius: 16, child: Text('${index + 1}')),
        title: Row(
          children: [
            Icon(_iconForType(rule.targetType), size: 18),
            const SizedBox(width: Spacing.xs),
            Expanded(child: Text(_labelForType(rule.targetType))),
          ],
        ),
        subtitle: Text(allocationLabel),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') onDelete();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Advisory row widget
// ---------------------------------------------------------------------------

class _AdvisoryRow extends StatelessWidget {
  const _AdvisoryRow({required this.advice});

  final engine.AllocationAdvice advice;

  IconData _iconForType(String targetType) {
    return switch (targetType) {
      'emergencyFund' => Icons.shield_outlined,
      'sinkingFund' => Icons.savings_outlined,
      'investmentGoal' => Icons.trending_up,
      'opportunityFund' => Icons.account_balance_wallet_outlined,
      _ => Icons.attach_money,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Row(
        children: [
          Icon(_iconForType(advice.targetType), size: 20),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(advice.targetName),
                if (advice.remainingToTarget > 0)
                  Text(
                    'Remaining to target: ${Money(advice.remainingToTarget).formatted}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          Text(
            Money(advice.allocatedPaise).formatted,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: Colors.green),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add rule bottom sheet
// ---------------------------------------------------------------------------

class _AddRuleSheet extends ConsumerStatefulWidget {
  const _AddRuleSheet({required this.familyId});
  final String familyId;

  @override
  ConsumerState<_AddRuleSheet> createState() => _AddRuleSheetState();
}

class _AddRuleSheetState extends ConsumerState<_AddRuleSheet> {
  final _formKey = GlobalKey<FormState>();
  String _targetType = 'emergencyFund';
  String _allocationType = 'fixed';
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              'Add Allocation Rule',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Spacing.md),
            DropdownButtonFormField<String>(
              initialValue: _targetType,
              decoration: const InputDecoration(labelText: 'Target Type'),
              items: const [
                DropdownMenuItem(
                  value: 'emergencyFund',
                  child: Text('Emergency Fund'),
                ),
                DropdownMenuItem(
                  value: 'sinkingFund',
                  child: Text('Sinking Fund'),
                ),
                DropdownMenuItem(
                  value: 'investmentGoal',
                  child: Text('Investment Goal'),
                ),
                DropdownMenuItem(
                  value: 'opportunityFund',
                  child: Text('Opportunity Fund'),
                ),
              ],
              onChanged: (v) => setState(() => _targetType = v!),
            ),
            const SizedBox(height: Spacing.sm),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'fixed', label: Text('Fixed Amount')),
                ButtonSegment(value: 'percentage', label: Text('Percentage')),
              ],
              selected: {_allocationType},
              onSelectionChanged: (s) =>
                  setState(() => _allocationType = s.first),
            ),
            const SizedBox(height: Spacing.sm),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: _allocationType == 'fixed'
                    ? 'Amount (in rupees)'
                    : 'Percentage',
                suffixText: _allocationType == 'fixed' ? '\u20B9' : '%',
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (double.tryParse(v) == null) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: Spacing.md),
            FilledButton(onPressed: _save, child: const Text('Save Rule')),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final dao = ref.read(savingsAllocationRuleDaoProvider);
    final existingRules = await dao.getByFamily(widget.familyId);
    final nextPriority = existingRules.length + 1;

    final value = double.parse(_amountController.text);
    final int? amountPaise;
    final int? percentageBp;

    if (_allocationType == 'fixed') {
      amountPaise = (value * 100).round(); // rupees to paise
      percentageBp = null;
    } else {
      amountPaise = null;
      percentageBp = (value * 100).round(); // percent to basis points
    }

    await dao.insertRule(
      SavingsAllocationRulesCompanion(
        id: Value(const Uuid().v4()),
        familyId: Value(widget.familyId),
        priority: Value(nextPriority),
        targetType: Value(_targetType),
        allocationType: Value(_allocationType),
        amountPaise: Value(amountPaise),
        percentageBp: Value(percentageBp),
        createdAt: Value(DateTime.now()),
      ),
    );

    if (mounted) Navigator.of(context).pop();
  }
}
