import 'package:flutter/material.dart';

import '../../../shared/theme/spacing.dart';

/// Form screen for creating or editing a budget limit for a category group.
class BudgetFormScreen extends StatefulWidget {
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
  State<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends State<BudgetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String? _selectedGroup;
  late final TextEditingController _amountController;

  static const _categoryGroups = [
    ('ESSENTIAL', 'Essential'),
    ('NON_ESSENTIAL', 'Non-Essential'),
    ('INVESTMENTS', 'Investments'),
    ('HOME_EXPENSES', 'Home Expenses'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedGroup = widget.initialGroup;
    final initialRupees =
        widget.initialAmount != null ? (widget.initialAmount! ~/ 100) : null;
    _amountController =
        TextEditingController(text: initialRupees?.toString() ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Budget' : 'New Budget'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(Spacing.md),
          children: [
            DropdownButtonFormField<String>(
              value: _selectedGroup,
              decoration: const InputDecoration(labelText: 'Category Group'),
              items: _categoryGroups
                  .map((g) => DropdownMenuItem(
                        value: g.$1,
                        child: Text(g.$2),
                      ))
                  .toList(),
              onChanged: widget.isEditing
                  ? null // locked when editing
                  : (v) => setState(() => _selectedGroup = v),
              validator: (v) => v == null ? 'Select a group' : null,
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    // Return result to caller
    Navigator.of(context).pop((
      group: _selectedGroup!,
      amountPaise: int.parse(_amountController.text) * 100,
    ));
  }
}
