import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../shared/theme/spacing.dart';
import '../providers/goal_providers.dart';

/// Form for creating a new savings goal.
class GoalFormScreen extends ConsumerStatefulWidget {
  const GoalFormScreen({super.key, required this.familyId});

  final String familyId;

  @override
  ConsumerState<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends ConsumerState<GoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _targetDate;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Goal')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(Spacing.md),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Goal Name'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter a goal name'
                  : null,
            ),
            const SizedBox(height: Spacing.md),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Target Amount',
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter a target amount';
                }
                final parsed = int.tryParse(v.replaceAll(',', ''));
                if (parsed == null || parsed <= 0) {
                  return 'Please enter a valid positive amount';
                }
                return null;
              },
            ),
            const SizedBox(height: Spacing.md),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Target Date'),
              subtitle: Text(
                _targetDate != null
                    ? '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}'
                    : 'Tap to select',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: Spacing.lg),
            FilledButton(onPressed: _submit, child: const Text('Save')),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 30)),
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amountRupees = int.parse(_amountController.text.replaceAll(',', ''));
    final amountPaise = amountRupees * 100;
    final date = _targetDate ?? DateTime.now().add(const Duration(days: 365));

    final dao = ref.read(goalDaoProvider);
    await dao.insertGoal(
      GoalsCompanion.insert(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        targetAmount: amountPaise,
        targetDate: date,
        familyId: widget.familyId,
        createdAt: DateTime.now(),
      ),
    );

    if (mounted) Navigator.of(context).pop();
  }
}
