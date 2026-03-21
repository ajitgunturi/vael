import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/enums.dart';
import '../../../shared/widgets/currency_input.dart';

/// Form for creating/editing a recurring rule.
class RecurringFormScreen extends ConsumerStatefulWidget {
  const RecurringFormScreen({
    super.key,
    required this.familyId,
    this.editingId,
  });

  final String familyId;
  final String? editingId;

  @override
  ConsumerState<RecurringFormScreen> createState() =>
      _RecurringFormScreenState();
}

class _RecurringFormScreenState extends ConsumerState<RecurringFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _escalationController = TextEditingController(text: '0');

  TransactionKind _selectedKind = TransactionKind.expense;
  double _frequencyMonths = 1.0;
  DateTime _startDate = DateTime.now();

  static final _frequencies = <double, String>{
    0.5: 'Biweekly',
    1.0: 'Monthly',
    3.0: 'Quarterly',
    6.0: 'Semi-annual',
    12.0: 'Annual',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _escalationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Rule' : 'New Recurring Rule'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Rent, SIP, Salary',
              ),
              validator: (v) => v == null || v.isEmpty ? 'Name required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TransactionKind>(
              value: _selectedKind,
              decoration: const InputDecoration(labelText: 'Type'),
              items: TransactionKind.values
                  .map((k) => DropdownMenuItem(value: k, child: Text(k.name)))
                  .toList(),
              onChanged: (k) {
                if (k != null) setState(() => _selectedKind = k);
              },
            ),
            const SizedBox(height: 16),
            CurrencyInput(controller: _amountController, label: 'Amount'),
            const SizedBox(height: 16),
            DropdownButtonFormField<double>(
              value: _frequencyMonths,
              decoration: const InputDecoration(labelText: 'Frequency'),
              items: _frequencies.entries
                  .map(
                    (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                  )
                  .toList(),
              onChanged: (f) {
                if (f != null) setState(() => _frequencyMonths = f);
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Start Date'),
              subtitle: Text(
                '${_startDate.day}/${_startDate.month}/${_startDate.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickStartDate,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _escalationController,
              decoration: const InputDecoration(
                labelText: 'Annual Escalation (%)',
                hintText: '0 for no escalation, 10 for 10% yearly hike',
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              child: Text(isEditing ? 'Update' : 'Create Rule'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop();
  }
}
