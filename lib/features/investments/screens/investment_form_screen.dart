import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/financial/investment_valuation.dart';
import '../../../core/models/enums.dart';
import '../../../shared/widgets/currency_input.dart';

/// Form for creating/editing an investment bucket.
class InvestmentFormScreen extends ConsumerStatefulWidget {
  const InvestmentFormScreen({
    super.key,
    required this.familyId,
    this.editingId,
  });

  final String familyId;
  final String? editingId;

  @override
  ConsumerState<InvestmentFormScreen> createState() =>
      _InvestmentFormScreenState();
}

class _InvestmentFormScreenState extends ConsumerState<InvestmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _investedController = TextEditingController();
  final _currentController = TextEditingController();
  final _sipController = TextEditingController();

  BucketType _selectedType = BucketType.mutualFunds;
  double? _customReturnRate;

  @override
  void dispose() {
    _nameController.dispose();
    _investedController.dispose();
    _currentController.dispose();
    _sipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Bucket' : 'Add Investment Bucket'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Bucket Name',
                hintText: 'e.g. Retirement Fund, Education PPF',
              ),
              validator: (v) => v == null || v.isEmpty ? 'Name required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BucketType>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Type'),
              items: BucketType.values
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(_bucketTypeLabel(t)),
                    ),
                  )
                  .toList(),
              onChanged: (t) {
                if (t != null) setState(() => _selectedType = t);
              },
            ),
            const SizedBox(height: 16),
            CurrencyInput(
              controller: _investedController,
              label: 'Invested Amount',
            ),
            const SizedBox(height: 16),
            CurrencyInput(
              controller: _currentController,
              label: 'Current Value',
            ),
            const SizedBox(height: 16),
            CurrencyInput(
              controller: _sipController,
              label: 'Monthly SIP (optional)',
            ),
            const SizedBox(height: 16),
            _ReturnRateRow(
              type: _selectedType,
              customRate: _customReturnRate,
              onChanged: (r) => setState(() => _customReturnRate = r),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              child: Text(isEditing ? 'Update' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    // Will be wired to DAO in integration
    Navigator.of(context).pop();
  }

  String _bucketTypeLabel(BucketType t) {
    return switch (t) {
      BucketType.mutualFunds => 'Mutual Funds',
      BucketType.stocks => 'Stocks',
      BucketType.ppf => 'PPF',
      BucketType.epf => 'EPF',
      BucketType.nps => 'NPS',
      BucketType.fixedDeposit => 'Fixed Deposit',
      BucketType.bonds => 'Bonds',
      BucketType.policy => 'Insurance/ULIP',
    };
  }
}

class _ReturnRateRow extends StatelessWidget {
  const _ReturnRateRow({
    required this.type,
    this.customRate,
    required this.onChanged,
  });

  final BucketType type;
  final double? customRate;
  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) {
    final defaultRate = InvestmentValuation.defaultReturnRate(type);
    final effectiveRate = customRate ?? defaultRate;

    return Row(
      children: [
        Expanded(
          child: Text(
            'Expected Return: ${(effectiveRate * 100).toStringAsFixed(1)}% p.a.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        TextButton(
          onPressed: () => _showRateDialog(context, defaultRate),
          child: Text(customRate != null ? 'Custom' : 'Default'),
        ),
      ],
    );
  }

  void _showRateDialog(BuildContext context, double defaultRate) {
    final controller = TextEditingController(
      text: ((customRate ?? defaultRate) * 100).toStringAsFixed(1),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Expected Annual Return'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: '%'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              onChanged(null); // reset to default
              Navigator.pop(ctx);
            },
            child: const Text('Use Default'),
          ),
          FilledButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null) onChanged(val / 100);
              Navigator.pop(ctx);
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }
}
