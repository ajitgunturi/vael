import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database.dart';
import '../../../core/financial/balance_rules.dart';
import '../../../core/providers/database_providers.dart';
import '../../../core/providers/transaction_providers.dart';
import '../../../shared/widgets/currency_input.dart';
import '../../../core/providers/account_providers.dart';

/// Create or edit a transaction.
class TransactionFormScreen extends ConsumerStatefulWidget {
  const TransactionFormScreen({
    super.key,
    required this.familyId,
    required this.userId,
    this.existingTransaction,
  });

  final String familyId;
  final String userId;
  final Transaction? existingTransaction;

  bool get isEditing => existingTransaction != null;

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late String _selectedKind;
  late DateTime _selectedDate;
  String? _selectedAccountId;
  String? _selectedToAccountId;

  static const _kindLabels = {
    'income': 'Income',
    'salary': 'Salary',
    'expense': 'Expense',
    'transfer': 'Transfer',
    'emiPayment': 'EMI Payment',
    'insurancePremium': 'Insurance Premium',
    'dividend': 'Dividend',
  };

  @override
  void initState() {
    super.initState();
    final existing = widget.existingTransaction;
    _amountController = TextEditingController(
      text: existing != null ? (existing.amount / 100).toStringAsFixed(0) : '',
    );
    _descriptionController =
        TextEditingController(text: existing?.description ?? '');
    _selectedKind = existing?.kind ?? 'expense';
    _selectedDate = existing?.date ?? DateTime.now();
    _selectedAccountId = existing?.accountId;
    _selectedToAccountId = existing?.toAccountId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider(widget.familyId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Transaction' : 'New Transaction'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildKindSelector(),
            const SizedBox(height: 16),
            CurrencyInput(
              label: 'Amount',
              controller: _amountController,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Amount is required';
                final parsed = double.tryParse(v.replaceAll(',', ''));
                if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),
            _buildDatePicker(),
            const SizedBox(height: 16),
            accountsAsync.when(
              data: (accounts) => _buildAccountPickers(accounts),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error loading accounts: $e'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKindSelector() {
    return InputDecorator(
      decoration: const InputDecoration(labelText: 'Transaction Type'),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedKind,
          isExpanded: true,
          isDense: true,
          items: _kindLabels.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _selectedKind = v);
          },
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    final formatted = DateFormat('dd MMM yyyy').format(_selectedDate);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Date'),
      subtitle: Text(formatted),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
    );
  }

  Widget _buildAccountPickers(List<Account> accounts) {
    if (accounts.isEmpty) {
      return const Text('No accounts available. Create one first.');
    }

    // Default to first account if none selected
    _selectedAccountId ??= accounts.first.id;

    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _selectedAccountId,
          decoration: const InputDecoration(labelText: 'From Account'),
          items: accounts
              .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
              .toList(),
          onChanged: (v) => setState(() => _selectedAccountId = v),
          validator: (v) => v == null ? 'Select an account' : null,
        ),
        if (_selectedKind == 'transfer') ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedToAccountId,
            decoration: const InputDecoration(labelText: 'To Account'),
            items: accounts
                .map(
                    (a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
                .toList(),
            onChanged: (v) => setState(() => _selectedToAccountId = v),
            validator: (v) {
              if (_selectedKind == 'transfer' && v == null) {
                return 'Select destination account';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final db = ref.read(databaseProvider);
    final dao = ref.read(transactionDaoProvider);
    final balanceService = BalanceService(db);

    final amountPaise = CurrencyInput.toPaise(_amountController.text);
    final txId = widget.existingTransaction?.id ?? const Uuid().v4();

    await dao.insertTransaction(TransactionsCompanion(
      id: Value(txId),
      amount: Value(amountPaise),
      date: Value(_selectedDate),
      description: Value(_descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : null),
      kind: Value(_selectedKind),
      accountId: Value(_selectedAccountId!),
      toAccountId: Value(_selectedToAccountId),
      familyId: Value(widget.familyId),
    ));

    // Apply balance cascade
    await balanceService.applyTransaction(
      kind: _selectedKind,
      amount: amountPaise,
      fromAccountId: _selectedAccountId!,
      toAccountId: _selectedToAccountId,
    );

    if (mounted) Navigator.of(context).pop();
  }
}
