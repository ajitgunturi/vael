import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database.dart';
import '../../../shared/widgets/currency_input.dart';
import '../providers/account_ui_providers.dart';

/// Create or edit an account.
class AccountFormScreen extends ConsumerStatefulWidget {
  const AccountFormScreen({
    super.key,
    required this.familyId,
    required this.userId,
    this.existingAccount,
  });

  final String familyId;
  final String userId;
  final Account? existingAccount;

  bool get isEditing => existingAccount != null;

  @override
  ConsumerState<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends ConsumerState<AccountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late String _selectedType;
  late String _selectedVisibility;

  static const _typeLabels = {
    'savings': 'Savings',
    'current': 'Current',
    'creditCard': 'Credit Card',
    'loan': 'Loan',
    'investment': 'Investment',
    'wallet': 'Wallet',
  };

  static const _visibilityLabels = {
    'shared': 'Shared',
    'private_': 'Private',
    'familyWide': 'Family Wide',
  };

  @override
  void initState() {
    super.initState();
    final existing = widget.existingAccount;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _balanceController = TextEditingController(
      text: existing != null ? (existing.balance / 100).toStringAsFixed(0) : '',
    );
    _selectedType = existing?.type ?? 'savings';
    _selectedVisibility = existing?.visibility ?? 'shared';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Account' : 'New Account'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Account Name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            _buildTypeSelector(),
            const SizedBox(height: 16),
            CurrencyInput(
              label: 'Opening Balance',
              controller: _balanceController,
            ),
            const SizedBox(height: 16),
            _buildVisibilitySelector(),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return InputDecorator(
      decoration: const InputDecoration(labelText: 'Account Type'),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedType,
          isExpanded: true,
          isDense: true,
          items: _typeLabels.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _selectedType = v);
          },
        ),
      ),
    );
  }

  Widget _buildVisibilitySelector() {
    return InputDecorator(
      decoration: const InputDecoration(labelText: 'Visibility'),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedVisibility,
          isExpanded: true,
          isDense: true,
          items: _visibilityLabels.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _selectedVisibility = v);
          },
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final dao = ref.read(accountCrudProvider);
    final balancePaise = CurrencyInput.toPaise(_balanceController.text);

    if (widget.isEditing) {
      await (dao.update(
        dao.accounts,
      )..where((a) => a.id.equals(widget.existingAccount!.id))).write(
        AccountsCompanion(
          name: Value(_nameController.text.trim()),
          type: Value(_selectedType),
          balance: Value(balancePaise),
          visibility: Value(_selectedVisibility),
        ),
      );
    } else {
      await dao.insertAccount(
        AccountsCompanion(
          id: Value(const Uuid().v4()),
          name: Value(_nameController.text.trim()),
          type: Value(_selectedType),
          balance: Value(balancePaise),
          visibility: Value(_selectedVisibility),
          familyId: Value(widget.familyId),
          userId: Value(widget.userId),
        ),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }
}
