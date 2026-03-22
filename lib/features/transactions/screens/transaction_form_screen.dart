import 'dart:convert';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database.dart';
import '../../../core/financial/balance_rules.dart';
import '../../../core/providers/category_providers.dart';
import '../../../core/providers/database_providers.dart';
import '../../../core/providers/transaction_providers.dart';
import '../../../shared/widgets/category_metadata_fields.dart';
import '../../../shared/widgets/category_picker.dart';
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

  // Category state
  String? _selectedCategoryId;
  Category? _selectedCategory;
  Map<String, String> _metadata = {};

  static const _kindLabels = {
    'income': 'Income',
    'salary': 'Salary',
    'expense': 'Expense',
    'transfer': 'Transfer',
    'emiPayment': 'EMI Payment',
    'insurancePremium': 'Insurance Premium',
    'dividend': 'Dividend',
  };

  /// Transaction kinds that represent income (filter for INCOME categories).
  static const _incomeKinds = {'income', 'salary', 'dividend'};

  @override
  void initState() {
    super.initState();
    final existing = widget.existingTransaction;
    _amountController = TextEditingController(
      text: existing != null ? (existing.amount / 100).toStringAsFixed(0) : '',
    );
    _descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
    _selectedKind = existing?.kind ?? 'expense';
    _selectedDate = existing?.date ?? DateTime.now();
    _selectedAccountId = existing?.accountId;
    _selectedToAccountId = existing?.toAccountId;
    _selectedCategoryId = existing?.categoryId;

    // Parse existing metadata
    if (existing?.metadata != null) {
      try {
        final decoded = jsonDecode(existing!.metadata!) as Map<String, dynamic>;
        _metadata = decoded.map((k, v) => MapEntry(k, v.toString()));
      } catch (_) {
        _metadata = {};
      }
    }

    // Load existing category object
    if (_selectedCategoryId != null) {
      _loadCategory(_selectedCategoryId!);
    }
  }

  Future<void> _loadCategory(String categoryId) async {
    final dao = ref.read(categoryDaoProvider);
    final cat = await dao.getById(categoryId);
    if (mounted && cat != null) {
      setState(() => _selectedCategory = cat);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Returns the category type filter based on the selected transaction kind.
  String get _categoryTypeFilter =>
      _incomeKinds.contains(_selectedKind) ? 'INCOME' : 'EXPENSE';

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
            _buildCategoryPicker(),
            if (_selectedCategory != null) ...[
              const SizedBox(height: 4),
              CategoryMetadataFields(
                groupId: _selectedCategory!.groupName,
                categoryName: _selectedCategory!.name,
                familyId: widget.familyId,
                metadata: _metadata,
                onChanged: (updated) => setState(() => _metadata = updated),
              ),
            ],
            const SizedBox(height: 16),
            CurrencyInput(
              label: 'Amount',
              controller: _amountController,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Amount is required';
                final parsed = double.tryParse(v.replaceAll(',', ''));
                if (parsed == null || parsed <= 0) {
                  return 'Enter a valid amount';
                }
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
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error loading accounts: $e'),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Save')),
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
            if (v == null) return;
            final oldType = _categoryTypeFilter;
            setState(() => _selectedKind = v);
            // Clear category if type changed (income ↔ expense)
            if (_categoryTypeFilter != oldType) {
              setState(() {
                _selectedCategoryId = null;
                _selectedCategory = null;
                _metadata = {};
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildCategoryPicker() {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () async {
        final selected = await CategoryPicker.show(
          context,
          familyId: widget.familyId,
          filterType: _categoryTypeFilter,
          selectedCategoryId: _selectedCategoryId,
        );
        // null return means "No Category" was explicitly tapped, or
        // the bottom sheet was dismissed (in which case we keep current).
        // We handle the explicit "No Category" case via the pop(null).
        setState(() {
          if (selected != null) {
            _selectedCategoryId = selected.id;
            _selectedCategory = selected;
            // Clear metadata when category changes
            _metadata = {};
          } else {
            _selectedCategoryId = null;
            _selectedCategory = null;
            _metadata = {};
          }
        });
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Category',
          suffixIcon: const Icon(Icons.arrow_drop_down),
          // Show an "uncategorized" hint if no category selected
          hintText: 'Select a category',
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurfaceVariant.withAlpha(150),
          ),
        ),
        child: _selectedCategory != null
            ? Row(
                children: [
                  Icon(
                    Icons.label_outline,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_selectedCategory!.name)),
                  // Clear button
                  GestureDetector(
                    onTap: () => setState(() {
                      _selectedCategoryId = null;
                      _selectedCategory = null;
                      _metadata = {};
                    }),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              )
            : null,
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
                .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
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

  /// Detects self-transfer: same owner for source and destination accounts.
  bool _isSelfTransfer(List<Account>? accounts) {
    if (_selectedKind != 'transfer' ||
        _selectedAccountId == null ||
        _selectedToAccountId == null) {
      return false;
    }
    if (accounts == null) return false;
    final from = accounts.where((a) => a.id == _selectedAccountId).firstOrNull;
    final to = accounts.where((a) => a.id == _selectedToAccountId).firstOrNull;
    if (from == null || to == null) return false;
    return from.userId == to.userId;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final db = ref.read(databaseProvider);
    final dao = ref.read(transactionDaoProvider);
    final balanceService = BalanceService(db);
    final accounts = ref.read(accountsProvider(widget.familyId)).value;

    final amountPaise = CurrencyInput.toPaise(_amountController.text);
    final txId = widget.existingTransaction?.id ?? const Uuid().v4();

    // Build metadata JSON
    final metadataMap = Map<String, dynamic>.from(_metadata);
    if (_isSelfTransfer(accounts)) {
      metadataMap['isSelfTransfer'] = true;
    }
    final metadataJson = metadataMap.isNotEmpty
        ? jsonEncode(metadataMap)
        : null;

    await dao.insertTransaction(
      TransactionsCompanion(
        id: Value(txId),
        amount: Value(amountPaise),
        date: Value(_selectedDate),
        description: Value(
          _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
        ),
        categoryId: Value(_selectedCategoryId),
        kind: Value(_selectedKind),
        accountId: Value(_selectedAccountId!),
        toAccountId: Value(_selectedToAccountId),
        metadata: Value(metadataJson),
        familyId: Value(widget.familyId),
      ),
    );

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
