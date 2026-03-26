import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database.dart';
import '../../../core/financial/decision_modeler.dart';
import '../../../core/models/enums.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/theme/spacing.dart';
import '../../../core/providers/transaction_providers.dart';
import '../../../features/recurring/providers/recurring_providers.dart';
import '../providers/decision_provider.dart';
import '../widgets/decision_impact_card.dart';
import '../widgets/decision_type_card.dart';

const _uuid = Uuid();

/// Mapping of [DecisionType] to display metadata.
const _typeMetadata =
    <DecisionType, ({IconData icon, String label, String description})>{
      DecisionType.jobChange: (
        icon: Icons.work_outline,
        label: 'Job Change',
        description: 'New salary, new trajectory',
      ),
      DecisionType.salaryNegotiation: (
        icon: Icons.trending_up,
        label: 'Salary Negotiation',
        description: 'Negotiate a raise',
      ),
      DecisionType.majorPurchase: (
        icon: Icons.home_outlined,
        label: 'Major Purchase',
        description: 'Home, car, or big spend',
      ),
      DecisionType.investmentWithdrawal: (
        icon: Icons.account_balance_wallet_outlined,
        label: 'Withdrawal',
        description: 'Redeem from investments',
      ),
      DecisionType.rentalChange: (
        icon: Icons.apartment_outlined,
        label: 'Rental Change',
        description: 'Move to a new place',
      ),
      DecisionType.custom: (
        icon: Icons.tune,
        label: 'Custom',
        description: 'Define your own scenario',
      ),
    };

/// 4-step decision modeler wizard: Choose Type -> Parameters -> Impact -> Confirm.
///
/// Computes impact synchronously via [DecisionModelerEngine].
/// On implement, creates tagged transactions/recurring rules.
/// On preview, saves decision record without side effects.
class DecisionModelerScreen extends ConsumerStatefulWidget {
  const DecisionModelerScreen({
    super.key,
    required this.familyId,
    required this.userId,
    this.prefilledType,
  });

  final String familyId;
  final String userId;
  final DecisionType? prefilledType;

  @override
  ConsumerState<DecisionModelerScreen> createState() =>
      _DecisionModelerScreenState();
}

class _DecisionModelerScreenState extends ConsumerState<DecisionModelerScreen> {
  late final PageController _pageController;
  int _currentStep = 0;

  // Step 1 state
  DecisionType? _selectedType;

  // Step 2 form controllers
  final _formKey = GlobalKey<FormState>();
  // Job Change
  final _newSalaryController = TextEditingController();
  // Salary Negotiation
  final _currentSalaryController = TextEditingController();
  final _proposedSalaryController = TextEditingController();
  // Major Purchase
  final _purchaseAmountController = TextEditingController();
  int _downPaymentBp = 2000; // 20%
  int _loanRateBp = 900; // 9%
  double _loanTenureYears = 15;
  String _purchaseSubType = 'Home';
  int _educationEscalationBp = 1000; // 10%
  // Withdrawal
  final _withdrawalAmountController = TextEditingController();
  String _bucketType = 'mutualFunds';
  int _holdingMonths = 12;
  // Rental Change
  final _currentRentController = TextEditingController();
  final _newRentController = TextEditingController();
  final _securityDepositController = TextEditingController();
  // Custom
  final _customDescriptionController = TextEditingController();
  final _customIncomeChangeController = TextEditingController();
  final _customExpenseChangeController = TextEditingController();
  final _customOneTimeCostController = TextEditingController();

  // Step 3 state
  DecisionImpact? _computedImpact;

  bool _hasEnteredParams = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.prefilledType != null) {
      _selectedType = widget.prefilledType;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _newSalaryController.dispose();
    _currentSalaryController.dispose();
    _proposedSalaryController.dispose();
    _purchaseAmountController.dispose();
    _withdrawalAmountController.dispose();
    _currentRentController.dispose();
    _newRentController.dispose();
    _securityDepositController.dispose();
    _customDescriptionController.dispose();
    _customIncomeChangeController.dispose();
    _customExpenseChangeController.dispose();
    _customOneTimeCostController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    if (step == 2) {
      // Entering Step 3 (Impact) -- compute impact
      _computeImpact();
    }
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _clearStep2State() {
    _newSalaryController.clear();
    _currentSalaryController.clear();
    _proposedSalaryController.clear();
    _purchaseAmountController.clear();
    _withdrawalAmountController.clear();
    _currentRentController.clear();
    _newRentController.clear();
    _securityDepositController.clear();
    _customDescriptionController.clear();
    _customIncomeChangeController.clear();
    _customExpenseChangeController.clear();
    _customOneTimeCostController.clear();
    _downPaymentBp = 2000;
    _loanRateBp = 900;
    _loanTenureYears = 15;
    _purchaseSubType = 'Home';
    _educationEscalationBp = 1000;
    _bucketType = 'mutualFunds';
    _holdingMonths = 12;
    _hasEnteredParams = false;
  }

  DecisionParameters? _buildParams() {
    return switch (_selectedType!) {
      DecisionType.jobChange => JobChangeParams(
        newMonthlySalaryPaise: _parsePaise(_newSalaryController.text),
      ),
      DecisionType.salaryNegotiation => SalaryNegotiationParams(
        currentMonthlySalaryPaise: _parsePaise(_currentSalaryController.text),
        proposedMonthlySalaryPaise: _parsePaise(_proposedSalaryController.text),
      ),
      DecisionType.majorPurchase => MajorPurchaseParams(
        purchaseAmountPaise: _parsePaise(_purchaseAmountController.text),
        downPaymentBp: _downPaymentBp,
        loanTenureMonths: (_loanTenureYears * 12).round(),
        loanInterestRate: _loanRateBp / 10000.0,
        educationEscalationRateBp: _purchaseSubType == 'Education'
            ? _educationEscalationBp
            : null,
      ),
      DecisionType.investmentWithdrawal => InvestmentWithdrawalParams(
        amountPaise: _parsePaise(_withdrawalAmountController.text),
        bucketType: _bucketType,
        holdingMonths: _holdingMonths,
      ),
      DecisionType.rentalChange => RentalChangeParams(
        currentRentPaise: _parsePaise(_currentRentController.text),
        newRentPaise: _parsePaise(_newRentController.text),
        securityDepositPaise: _parsePaise(_securityDepositController.text),
      ),
      DecisionType.custom => CustomParams(
        description: _customDescriptionController.text,
        monthlyIncomeChangePaise: _parsePaise(
          _customIncomeChangeController.text,
        ),
        monthlyExpenseChangePaise: _parsePaise(
          _customExpenseChangeController.text,
        ),
        oneTimeCostPaise: _parsePaise(_customOneTimeCostController.text),
      ),
    };
  }

  void _computeImpact() {
    final params = _buildParams();
    if (params == null) return;

    // Use placeholder financial context (would come from life profile in production).
    _computedImpact = DecisionModelerEngine.computeImpact(
      type: _selectedType!,
      params: params,
      currentAge: 30,
      retirementAge: 60,
      currentPortfolioPaise: 50000000, // 5L
      monthlySavingsPaise: 5000000, // 50k
      annualExpensesPaise: 60000000, // 6L/yr
      currentMonthlySalaryPaise: 10000000, // 1L
      swr: 0.03,
      inflationRate: 0.06,
      annualReturnRate: 0.10,
    );
  }

  int _parsePaise(String text) {
    final cleaned = text.replaceAll(',', '').replaceAll(' ', '');
    final rupees = int.tryParse(cleaned) ?? 0;
    return rupees * 100;
  }

  Future<void> _implementDecision() async {
    final params = _buildParams();
    if (params == null) return;
    final decisionId = _uuid.v4();
    final now = DateTime.now();
    final decisionDao = ref.read(decisionDaoProvider);

    // Insert decision record
    await decisionDao.insertDecision(
      DecisionsCompanion(
        id: Value(decisionId),
        userId: Value(widget.userId),
        familyId: Value(widget.familyId),
        decisionType: Value(_selectedType!.name),
        name: Value(_typeMetadata[_selectedType]!.label),
        parameters: Value(jsonEncode(_paramsToJson(params))),
        status: const Value('implemented'),
        fiDelayYears: Value(_computedImpact?.fiDelayYears),
        createdAt: Value(now),
        implementedAt: Value(now),
      ),
    );

    // Create tagged transactions and recurring rules based on decision type
    final recurringRuleDao = ref.read(recurringRuleDaoProvider);
    final transactionDao = ref.read(transactionDaoProvider);

    switch (params) {
      case JobChangeParams(:final newMonthlySalaryPaise):
        // Create recurring rule for new salary
        await recurringRuleDao.insertRule(
          RecurringRulesCompanion(
            id: Value(_uuid.v4()),
            name: const Value('New Salary'),
            kind: const Value('income'),
            amount: Value(newMonthlySalaryPaise),
            accountId: const Value('default'),
            frequencyMonths: const Value(1),
            startDate: Value(now),
            familyId: Value(widget.familyId),
            userId: Value(widget.userId),
            createdAt: Value(now),
            decisionId: Value(decisionId),
          ),
        );
      case SalaryNegotiationParams(:final proposedMonthlySalaryPaise):
        await recurringRuleDao.insertRule(
          RecurringRulesCompanion(
            id: Value(_uuid.v4()),
            name: const Value('Negotiated Salary'),
            kind: const Value('income'),
            amount: Value(proposedMonthlySalaryPaise),
            accountId: const Value('default'),
            frequencyMonths: const Value(1),
            startDate: Value(now),
            familyId: Value(widget.familyId),
            userId: Value(widget.userId),
            createdAt: Value(now),
            decisionId: Value(decisionId),
          ),
        );
      case MajorPurchaseParams(
        :final purchaseAmountPaise,
        :final downPaymentBp,
        :final loanInterestRate,
        :final loanTenureMonths,
      ):
        final downPaymentPaise = (purchaseAmountPaise * downPaymentBp) ~/ 10000;
        // One-time down payment transaction
        await transactionDao.insertTransaction(
          TransactionsCompanion(
            id: Value(_uuid.v4()),
            description: const Value('Down payment'),
            amount: Value(downPaymentPaise),
            kind: const Value('expense'),
            accountId: const Value('default'),
            date: Value(now),
            familyId: Value(widget.familyId),
            metadata: Value(jsonEncode({'decisionId': decisionId})),
          ),
        );
        // EMI recurring rule if loan exists
        if (loanTenureMonths != null && loanTenureMonths > 0) {
          final loanAmount = purchaseAmountPaise - downPaymentPaise;
          final monthlyRate = (loanInterestRate ?? 0.09) / 12;
          final emiPaise = monthlyRate > 0
              ? (loanAmount *
                        monthlyRate *
                        math.pow(1 + monthlyRate, loanTenureMonths)) ~/
                    (math.pow(1 + monthlyRate, loanTenureMonths) - 1)
              : loanAmount ~/ loanTenureMonths;
          await recurringRuleDao.insertRule(
            RecurringRulesCompanion(
              id: Value(_uuid.v4()),
              name: const Value('Loan EMI'),
              kind: const Value('expense'),
              amount: Value(emiPaise),
              accountId: const Value('default'),
              frequencyMonths: const Value(1),
              startDate: Value(now),
              familyId: Value(widget.familyId),
              userId: Value(widget.userId),
              createdAt: Value(now),
              decisionId: Value(decisionId),
            ),
          );
        }
      case InvestmentWithdrawalParams(:final amountPaise):
        // One-time withdrawal transaction
        await transactionDao.insertTransaction(
          TransactionsCompanion(
            id: Value(_uuid.v4()),
            description: const Value('Investment withdrawal'),
            amount: Value(amountPaise),
            kind: const Value('expense'),
            accountId: const Value('default'),
            date: Value(now),
            familyId: Value(widget.familyId),
            metadata: Value(jsonEncode({'decisionId': decisionId})),
          ),
        );
      case RentalChangeParams(:final newRentPaise, :final securityDepositPaise):
        // Recurring rule for new rent
        await recurringRuleDao.insertRule(
          RecurringRulesCompanion(
            id: Value(_uuid.v4()),
            name: const Value('New Rent'),
            kind: const Value('expense'),
            amount: Value(newRentPaise),
            accountId: const Value('default'),
            frequencyMonths: const Value(1),
            startDate: Value(now),
            familyId: Value(widget.familyId),
            userId: Value(widget.userId),
            createdAt: Value(now),
            decisionId: Value(decisionId),
          ),
        );
        // One-time security deposit transaction
        if (securityDepositPaise != null && securityDepositPaise > 0) {
          await transactionDao.insertTransaction(
            TransactionsCompanion(
              id: Value(_uuid.v4()),
              description: const Value('Security deposit'),
              amount: Value(securityDepositPaise),
              kind: const Value('expense'),
              accountId: const Value('default'),
              date: Value(now),
              familyId: Value(widget.familyId),
              metadata: Value(jsonEncode({'decisionId': decisionId})),
            ),
          );
        }
      case CustomParams(
        :final monthlyIncomeChangePaise,
        :final monthlyExpenseChangePaise,
        :final oneTimeCostPaise,
      ):
        if (monthlyIncomeChangePaise != 0) {
          await recurringRuleDao.insertRule(
            RecurringRulesCompanion(
              id: Value(_uuid.v4()),
              name: const Value('Custom income change'),
              kind: Value(monthlyIncomeChangePaise > 0 ? 'income' : 'expense'),
              amount: Value(monthlyIncomeChangePaise.abs()),
              accountId: const Value('default'),
              frequencyMonths: const Value(1),
              startDate: Value(now),
              familyId: Value(widget.familyId),
              userId: Value(widget.userId),
              createdAt: Value(now),
              decisionId: Value(decisionId),
            ),
          );
        }
        if (monthlyExpenseChangePaise != 0) {
          await recurringRuleDao.insertRule(
            RecurringRulesCompanion(
              id: Value(_uuid.v4()),
              name: const Value('Custom expense change'),
              kind: const Value('expense'),
              amount: Value(monthlyExpenseChangePaise.abs()),
              accountId: const Value('default'),
              frequencyMonths: const Value(1),
              startDate: Value(now),
              familyId: Value(widget.familyId),
              userId: Value(widget.userId),
              createdAt: Value(now),
              decisionId: Value(decisionId),
            ),
          );
        }
        if (oneTimeCostPaise > 0) {
          await transactionDao.insertTransaction(
            TransactionsCompanion(
              id: Value(_uuid.v4()),
              description: const Value('Custom one-time cost'),
              amount: Value(oneTimeCostPaise),
              kind: const Value('expense'),
              accountId: const Value('default'),
              date: Value(now),
              familyId: Value(widget.familyId),
              metadata: Value(jsonEncode({'decisionId': decisionId})),
            ),
          );
        }
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Decision implemented')));
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveAsPreview() async {
    final params = _buildParams();
    if (params == null) return;
    final decisionId = _uuid.v4();
    final now = DateTime.now();
    final decisionDao = ref.read(decisionDaoProvider);

    await decisionDao.insertDecision(
      DecisionsCompanion(
        id: Value(decisionId),
        userId: Value(widget.userId),
        familyId: Value(widget.familyId),
        decisionType: Value(_selectedType!.name),
        name: Value(_typeMetadata[_selectedType]!.label),
        parameters: Value(jsonEncode(_paramsToJson(params))),
        status: const Value('preview'),
        fiDelayYears: Value(_computedImpact?.fiDelayYears),
        createdAt: Value(now),
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Decision saved as preview')),
      );
      Navigator.of(context).pop();
    }
  }

  Map<String, dynamic> _paramsToJson(DecisionParameters params) {
    return switch (params) {
      JobChangeParams p => {'newMonthlySalaryPaise': p.newMonthlySalaryPaise},
      SalaryNegotiationParams p => {
        'currentMonthlySalaryPaise': p.currentMonthlySalaryPaise,
        'proposedMonthlySalaryPaise': p.proposedMonthlySalaryPaise,
      },
      MajorPurchaseParams p => {
        'purchaseAmountPaise': p.purchaseAmountPaise,
        'downPaymentBp': p.downPaymentBp,
        'loanTenureMonths': p.loanTenureMonths,
        'loanInterestRate': p.loanInterestRate,
        'educationEscalationRateBp': p.educationEscalationRateBp,
      },
      InvestmentWithdrawalParams p => {
        'amountPaise': p.amountPaise,
        'bucketType': p.bucketType,
        'holdingMonths': p.holdingMonths,
      },
      RentalChangeParams p => {
        'currentRentPaise': p.currentRentPaise,
        'newRentPaise': p.newRentPaise,
        'securityDepositPaise': p.securityDepositPaise,
      },
      CustomParams p => {
        'monthlyIncomeChangePaise': p.monthlyIncomeChangePaise,
        'monthlyExpenseChangePaise': p.monthlyExpenseChangePaise,
        'oneTimeCostPaise': p.oneTimeCostPaise,
        'description': p.description,
      },
    };
  }

  Future<bool> _onWillPop() async {
    if (!_hasEnteredParams) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard this decision?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep Editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Discard Changes'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorTokens.of(context);
    final theme = Theme.of(context);

    return PopScope(
      canPop: !_hasEnteredParams,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Model a Decision')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                // Step indicator
                _StepIndicator(
                  currentStep: _currentStep,
                  colors: colors,
                  theme: theme,
                ),
                // Pages
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep1(theme, colors),
                      _buildStep2(theme, colors),
                      _buildStep3(theme, colors),
                      _buildStep4(theme, colors),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Step 1: Choose Type ──────────────────────────────────────────

  Widget _buildStep1(ThemeData theme, ColorTokens colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'What decision are you exploring?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.lg),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: Spacing.md,
            mainAxisSpacing: Spacing.md,
            childAspectRatio: 1.1,
            children: DecisionType.values.map((type) {
              final meta = _typeMetadata[type]!;
              return DecisionTypeCard(
                icon: meta.icon,
                label: meta.label,
                description: meta.description,
                isSelected: _selectedType == type,
                onTap: () {
                  if (_selectedType != type) {
                    setState(() {
                      _selectedType = type;
                      _clearStep2State();
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: Spacing.lg),
          FilledButton(
            onPressed: _selectedType != null ? () => _goToStep(1) : null,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  // ── Step 2: Enter Parameters ─────────────────────────────────────

  Widget _buildStep2(ThemeData theme, ColorTokens colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.xl),
      child: Form(
        key: _formKey,
        onChanged: () {
          if (!_hasEnteredParams) {
            setState(() => _hasEnteredParams = true);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ..._buildParameterFields(theme, colors),
            const SizedBox(height: Spacing.lg),
            Row(
              children: [
                TextButton(
                  onPressed: () => _goToStep(0),
                  child: const Text('Back'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => _goToStep(2),
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildParameterFields(ThemeData theme, ColorTokens colors) {
    return switch (_selectedType) {
      DecisionType.jobChange => [
        _moneyField(_newSalaryController, 'New Monthly Salary'),
      ],
      DecisionType.salaryNegotiation => [
        _moneyField(_currentSalaryController, 'Current Salary'),
        const SizedBox(height: Spacing.md),
        _moneyField(_proposedSalaryController, 'Proposed Salary'),
      ],
      DecisionType.majorPurchase => [
        DropdownButtonFormField<String>(
          value: _purchaseSubType,
          decoration: const InputDecoration(labelText: 'Purchase Type'),
          items: [
            'Home',
            'Car',
            'Education',
            'Other',
          ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (v) {
            if (v != null) setState(() => _purchaseSubType = v);
          },
        ),
        const SizedBox(height: Spacing.md),
        _moneyField(_purchaseAmountController, 'Total Cost'),
        const SizedBox(height: Spacing.md),
        _sliderField(
          label: 'Down Payment',
          valueBp: _downPaymentBp,
          minBp: 0,
          maxBp: 10000,
          stepBp: 500,
          onChanged: (v) => setState(() => _downPaymentBp = v),
        ),
        const SizedBox(height: Spacing.md),
        _sliderField(
          label: 'Loan Interest Rate',
          valueBp: _loanRateBp,
          minBp: 600,
          maxBp: 1500,
          stepBp: 25,
          onChanged: (v) => setState(() => _loanRateBp = v),
        ),
        const SizedBox(height: Spacing.md),
        Text(
          'Loan Tenure: ${_loanTenureYears.round()} years',
          style: theme.textTheme.bodyMedium,
        ),
        Slider(
          value: _loanTenureYears,
          min: 1,
          max: 30,
          divisions: 29,
          label: '${_loanTenureYears.round()} years',
          onChanged: (v) => setState(() => _loanTenureYears = v),
        ),
        if (_purchaseSubType == 'Education') ...[
          const SizedBox(height: Spacing.md),
          _sliderField(
            label: 'Annual Cost Escalation',
            valueBp: _educationEscalationBp,
            minBp: 500,
            maxBp: 1500,
            stepBp: 50,
            onChanged: (v) => setState(() => _educationEscalationBp = v),
          ),
        ],
      ],
      DecisionType.investmentWithdrawal => [
        _moneyField(_withdrawalAmountController, 'Withdrawal Amount'),
        const SizedBox(height: Spacing.md),
        DropdownButtonFormField<String>(
          value: _bucketType,
          decoration: const InputDecoration(labelText: 'Fund Type'),
          items: [
            const DropdownMenuItem(
              value: 'mutualFunds',
              child: Text('Mutual Funds'),
            ),
            const DropdownMenuItem(value: 'stocks', child: Text('Stocks')),
            const DropdownMenuItem(value: 'debt', child: Text('Debt Funds')),
          ],
          onChanged: (v) {
            if (v != null) setState(() => _bucketType = v);
          },
        ),
        const SizedBox(height: Spacing.md),
        Text(
          'Held for $_holdingMonths months',
          style: theme.textTheme.bodyMedium,
        ),
        Slider(
          value: _holdingMonths.toDouble(),
          min: 1,
          max: 120,
          divisions: 119,
          label: '$_holdingMonths months',
          onChanged: (v) => setState(() => _holdingMonths = v.round()),
        ),
      ],
      DecisionType.rentalChange => [
        _moneyField(_currentRentController, 'Current Rent'),
        const SizedBox(height: Spacing.md),
        _moneyField(_newRentController, 'New Rent'),
        const SizedBox(height: Spacing.md),
        _moneyField(_securityDepositController, 'Security Deposit'),
      ],
      DecisionType.custom => [
        TextFormField(
          controller: _customDescriptionController,
          decoration: const InputDecoration(labelText: 'Description'),
        ),
        const SizedBox(height: Spacing.md),
        _moneyField(
          _customIncomeChangeController,
          'Monthly Income Change (+/-)',
        ),
        const SizedBox(height: Spacing.md),
        _moneyField(
          _customExpenseChangeController,
          'Monthly Expense Change (+/-)',
        ),
        const SizedBox(height: Spacing.md),
        _moneyField(_customOneTimeCostController, 'One-time Cost'),
      ],
      null => [],
    };
  }

  Widget _moneyField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
      decoration: InputDecoration(
        labelText: label,
        prefixText: 'Rs ',
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _sliderField({
    required String label,
    required int valueBp,
    required int minBp,
    required int maxBp,
    required int stepBp,
    required ValueChanged<int> onChanged,
  }) {
    final pct = (valueBp / 100).toStringAsFixed(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: $pct%', style: Theme.of(context).textTheme.bodyMedium),
        Slider(
          value: valueBp.toDouble(),
          min: minBp.toDouble(),
          max: maxBp.toDouble(),
          divisions: ((maxBp - minBp) / stepBp).round(),
          label: '$pct%',
          onChanged: (v) => onChanged(v.round()),
        ),
      ],
    );
  }

  // ── Step 3: Impact Preview ───────────────────────────────────────

  Widget _buildStep3(ThemeData theme, ColorTokens colors) {
    if (_computedImpact == null || _selectedType == null) {
      return const Center(child: Text('Impact unavailable'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecisionImpactCard(
            impact: _computedImpact!,
            decisionType: _selectedType!,
          ),
          const SizedBox(height: Spacing.lg),
          Row(
            children: [
              TextButton(
                onPressed: () => _goToStep(1),
                child: const Text('Back'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => _goToStep(3),
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Step 4: Confirm ──────────────────────────────────────────────

  Widget _buildStep4(ThemeData theme, ColorTokens colors) {
    if (_selectedType == null) {
      return const SizedBox.shrink();
    }
    final meta = _typeMetadata[_selectedType]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Recap card
          Card(
            color: colors.surfaceContainer,
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Row(
                children: [
                  Icon(meta.icon, size: 32, color: colors.onSurfaceVariant),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(meta.label, style: theme.textTheme.titleMedium),
                        Text(
                          meta.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.lg),
          FilledButton(
            onPressed: _implementDecision,
            child: const Text('Implement Decision'),
          ),
          const SizedBox(height: Spacing.md),
          OutlinedButton(
            onPressed: _saveAsPreview,
            child: const Text('Save as Preview'),
          ),
          const SizedBox(height: Spacing.sm),
          Center(
            child: TextButton(
              onPressed: () => _goToStep(1),
              child: const Text('Edit Parameters'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step Indicator ─────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.currentStep,
    required this.colors,
    required this.theme,
  });

  final int currentStep;
  final ColorTokens colors;
  final ThemeData theme;

  static const _labels = ['Choose Type', 'Parameters', 'Impact', 'Confirm'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xl,
        vertical: Spacing.md,
      ),
      child: Column(
        children: [
          Semantics(
            label: 'Step ${currentStep + 1} of 4: ${_labels[currentStep]}',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == currentStep
                          ? colors.primary
                          : colors.outlineVariant,
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            _labels[currentStep],
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
