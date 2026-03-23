import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/models/enums.dart';
import '../../../shared/theme/spacing.dart';
import '../../planning/screens/decision_modeler_screen.dart';
import '../../planning/widgets/rate_slider.dart';
import '../providers/goal_providers.dart';

/// Form for creating a new savings goal with category support.
///
/// When goalCategory is PURCHASE, shows conditional fields:
/// purchase type dropdown, down payment slider, education escalation slider.
class GoalFormScreen extends ConsumerStatefulWidget {
  const GoalFormScreen({
    super.key,
    required this.familyId,
    this.initialCategory = GoalCategory.investmentGoal,
  });

  final String familyId;
  final GoalCategory initialCategory;

  @override
  ConsumerState<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends ConsumerState<GoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _targetDate;

  late GoalCategory _goalCategory;
  String _purchaseType = 'Home';
  int _downPaymentBp = 2000; // 20%
  int _educationEscalationBp = 1000; // 10%

  @override
  void initState() {
    super.initState();
    _goalCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String get _appBarTitle {
    if (_goalCategory == GoalCategory.purchase) return 'New Purchase Goal';
    return 'New Goal';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_appBarTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(Spacing.md),
          children: [
            // Goal category segmented button
            SegmentedButton<GoalCategory>(
              segments: const [
                ButtonSegment(
                  value: GoalCategory.investmentGoal,
                  label: Text('Investment'),
                ),
                ButtonSegment(
                  value: GoalCategory.purchase,
                  label: Text('Purchase'),
                ),
                ButtonSegment(
                  value: GoalCategory.retirement,
                  label: Text('Retirement'),
                ),
              ],
              selected: {_goalCategory},
              onSelectionChanged: (selected) {
                setState(() => _goalCategory = selected.first);
              },
            ),
            const SizedBox(height: Spacing.md),
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
                prefixText: '\u20B9 ',
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
            // Purchase-specific fields with AnimatedSwitcher
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _goalCategory == GoalCategory.purchase
                  ? _buildPurchaseFields()
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
            const SizedBox(height: Spacing.lg),
            FilledButton(onPressed: _submit, child: const Text('Save')),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseFields() {
    return Column(
      key: const ValueKey('purchase_fields'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: Spacing.md),
        DropdownButtonFormField<String>(
          value: _purchaseType,
          decoration: const InputDecoration(labelText: 'Purchase Type'),
          items: [
            'Home',
            'Car',
            'Education',
            'Other',
          ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (v) {
            if (v != null) setState(() => _purchaseType = v);
          },
        ),
        const SizedBox(height: Spacing.md),
        RateSlider(
          label: 'Down Payment',
          valueBp: _downPaymentBp,
          minBp: 0,
          maxBp: 10000,
          stepBp: 500,
          onChanged: (v) => setState(() => _downPaymentBp = v),
        ),
        // Education escalation rate -- conditional on Education type
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _purchaseType == 'Education'
              ? Padding(
                  key: const ValueKey('education_escalation'),
                  padding: const EdgeInsets.only(top: Spacing.md),
                  child: RateSlider(
                    label: 'Annual Cost Escalation',
                    valueBp: _educationEscalationBp,
                    minBp: 500,
                    maxBp: 1500,
                    stepBp: 50,
                    onChanged: (v) =>
                        setState(() => _educationEscalationBp = v),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('no_escalation')),
        ),
        const SizedBox(height: Spacing.md),
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DecisionModelerScreen(
                  familyId: widget.familyId,
                  userId: 'current_user', // placeholder
                  prefilledType: DecisionType.majorPurchase,
                ),
              ),
            );
          },
          icon: const Icon(Icons.analytics_outlined),
          label: const Text('Model Impact First'),
        ),
      ],
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
        goalCategory: Value(_goalCategory.name),
        downPaymentPctBp: _goalCategory == GoalCategory.purchase
            ? Value(_downPaymentBp)
            : const Value.absent(),
        educationEscalationRateBp:
            _goalCategory == GoalCategory.purchase &&
                _purchaseType == 'Education'
            ? Value(_educationEscalationBp)
            : const Value.absent(),
        createdAt: DateTime.now(),
      ),
    );

    if (mounted) Navigator.of(context).pop();
  }
}
