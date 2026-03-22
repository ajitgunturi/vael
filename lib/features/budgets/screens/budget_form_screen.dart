import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database.dart';
import '../../../core/models/category_group_display.dart';
import '../../../core/providers/category_providers.dart';
import '../../../core/providers/database_providers.dart';
import '../../../shared/theme/spacing.dart';

/// Form screen for creating or editing a budget limit for a category group.
class BudgetFormScreen extends ConsumerStatefulWidget {
  const BudgetFormScreen({
    super.key,
    required this.familyId,
    required this.year,
    required this.month,
    this.editBudgetId,
    this.initialGroup,
    this.initialAmount,
  });

  final String familyId;
  final int year;
  final int month;

  /// Non-null when editing an existing budget.
  final String? editBudgetId;
  final String? initialGroup;
  final int? initialAmount;

  bool get isEditing => editBudgetId != null;

  @override
  ConsumerState<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends ConsumerState<BudgetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String? _selectedGroup;
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _selectedGroup = widget.initialGroup;
    final initialRupees = widget.initialAmount != null
        ? (widget.initialAmount! ~/ 100)
        : null;
    _amountController = TextEditingController(
      text: initialRupees?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(categoryGroupsProvider(widget.familyId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Budget' : 'New Budget'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(Spacing.md),
          children: [
            groupsAsync.when(
              data: (groups) => DropdownButtonFormField<String>(
                value: _selectedGroup,
                decoration: const InputDecoration(labelText: 'Category Group'),
                items: groups
                    .map(
                      (g) => DropdownMenuItem(
                        value: g.id,
                        child: Text(CategoryGroupDisplay.nameOf(g.id)),
                      ),
                    )
                    .toList(),
                onChanged: widget.isEditing
                    ? null // locked when editing
                    : (v) => setState(() => _selectedGroup = v),
                validator: (v) => v == null ? 'Select a group' : null,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error loading groups: $e'),
            ),
            const SizedBox(height: Spacing.md),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Monthly Limit (₹)',
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter an amount';
                if (int.tryParse(v) == null) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: Spacing.lg),
            FilledButton(
              onPressed: _submit,
              child: Text(widget.isEditing ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amountPaise = int.parse(_amountController.text) * 100;
    final dao = ref.read(budgetDaoProvider);

    if (widget.isEditing) {
      await dao.updateLimit(widget.editBudgetId!, amountPaise);
    } else {
      await dao.insertBudget(
        BudgetsCompanion.insert(
          id: const Uuid().v4(),
          familyId: widget.familyId,
          year: widget.year,
          month: widget.month,
          categoryGroup: _selectedGroup!,
          limitAmount: amountPaise,
        ),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }
}
