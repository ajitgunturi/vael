import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/financial/fi_calculator.dart';
import '../../../core/models/money.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/theme/spacing.dart';
import '../providers/fi_calculator_provider.dart';
import '../widgets/fi_hero_card.dart';
import '../widgets/fi_secondary_card.dart';
import '../widgets/rate_slider.dart';
import 'life_profile_wizard_screen.dart';

/// Formats paise into compact Indian display for secondary cards.
String _formatCompact(int paise) {
  final rupees = paise / 100;
  if (rupees >= 10000000) {
    final cr = rupees / 10000000;
    return 'Rs ${cr >= 10 ? cr.toStringAsFixed(1) : cr.toStringAsFixed(2)} Cr';
  } else if (rupees >= 100000) {
    final l = rupees / 100000;
    return 'Rs ${l >= 10 ? l.toStringAsFixed(1) : l.toStringAsFixed(2)} L';
  }
  return Money(paise).formatted;
}

/// FI Calculator screen: hero FI number, secondary metrics, sensitivity sliders.
///
/// All computation is synchronous -- slider changes update instantly.
/// Works in standalone mode with placeholder defaults when no life profile exists.
class FiCalculatorScreen extends ConsumerStatefulWidget {
  const FiCalculatorScreen({
    super.key,
    required this.familyId,
    required this.userId,
  });

  final String familyId;
  final String userId;

  @override
  ConsumerState<FiCalculatorScreen> createState() => _FiCalculatorScreenState();
}

class _FiCalculatorScreenState extends ConsumerState<FiCalculatorScreen> {
  late int _swrBp;
  late int _returnsBp;
  late int _inflationBp;
  late int _monthlyExpensesPaise;
  late int _currentAge;
  late int _retirementAge;
  late int _currentPortfolioPaise;
  late int _monthlySavingsPaise;
  late bool _hasLifeProfile;

  late TextEditingController _expenseController;
  Timer? _debounceTimer;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _expenseController = TextEditingController();
  }

  void _initFromDefaults(FiInputs defaults) {
    if (_initialized) return;
    _swrBp = defaults.swrBp;
    _returnsBp = defaults.returnsBp;
    _inflationBp = defaults.inflationBp;
    _monthlyExpensesPaise = defaults.monthlyExpensesPaise;
    _currentAge = defaults.currentAge;
    _retirementAge = defaults.retirementAge;
    _currentPortfolioPaise = defaults.currentPortfolioPaise;
    _monthlySavingsPaise = defaults.monthlySavingsPaise;
    _hasLifeProfile = defaults.hasLifeProfile;
    _expenseController.text = (_monthlyExpensesPaise ~/ 100).toString();
    _initialized = true;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _expenseController.dispose();
    super.dispose();
  }

  void _onExpenseChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final parsed = int.tryParse(value);
      if (parsed != null && parsed > 0) {
        setState(() {
          _monthlyExpensesPaise = parsed * 100; // rupees to paise
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final defaults = ref.watch(
      fiDefaultInputsProvider((
        userId: widget.userId,
        familyId: widget.familyId,
      )),
    );
    _initFromDefaults(defaults);

    final yearsToRetirement = _retirementAge - _currentAge;
    final swr = _swrBp / 10000.0;
    final returns = _returnsBp / 10000.0;
    final inflation = _inflationBp / 10000.0;

    final fiNumber = FiCalculator.computeFiNumber(
      annualExpensesPaise: _monthlyExpensesPaise * 12,
      swr: swr,
      inflationRate: inflation,
      yearsToRetirement: yearsToRetirement,
    );
    final yearsToFi = FiCalculator.yearsToFi(
      currentPortfolioPaise: _currentPortfolioPaise,
      monthlySavingsPaise: _monthlySavingsPaise,
      annualReturnRate: returns,
      fiNumberPaise: fiNumber,
    );
    final coastFi = FiCalculator.coastFi(
      fiNumberPaise: fiNumber,
      annualReturnRate: returns,
      yearsToRetirement: yearsToRetirement,
    );

    final theme = Theme.of(context);
    final colors = ColorTokens.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      appBar: AppBar(title: const Text('FI Calculator')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile banner
                if (!_hasLifeProfile)
                  Container(
                    margin: const EdgeInsets.only(bottom: Spacing.md),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.md,
                      vertical: Spacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(Spacing.cardRadius),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Set up your life profile for personalized results',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => LifeProfileWizardScreen(
                                  userId: widget.userId,
                                  familyId: widget.familyId,
                                ),
                              ),
                            );
                          },
                          child: const Text('Set Up'),
                        ),
                      ],
                    ),
                  ),

                // Hero FI card
                Semantics(
                  label:
                      'Financial Independence number: '
                      'Rs ${_formatCompact(fiNumber)}',
                  child: FiHeroCard(
                    fiNumberPaise: fiNumber,
                    expenseLabel: _formatCompact(_monthlyExpensesPaise * 12),
                    swrPercent: (_swrBp / 100).toStringAsFixed(1),
                    inflationPercent: (_inflationBp / 100).toStringAsFixed(1),
                  ),
                ),

                const SizedBox(height: Spacing.lg),

                // Secondary cards
                if (isWide)
                  Row(
                    children: [
                      Expanded(child: _buildYearsToFiCard(yearsToFi)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildCoastFiCard(coastFi)),
                    ],
                  )
                else ...[
                  _buildYearsToFiCard(yearsToFi),
                  const SizedBox(height: Spacing.md),
                  _buildCoastFiCard(coastFi),
                ],

                const SizedBox(height: Spacing.xxl),

                // Sliders
                RateSlider(
                  label: 'Safe Withdrawal Rate',
                  valueBp: _swrBp,
                  minBp: 200,
                  maxBp: 500,
                  stepBp: 25,
                  onChanged: (v) => setState(() => _swrBp = v),
                ),
                RateSlider(
                  label: 'Expected Returns',
                  valueBp: _returnsBp,
                  minBp: 600,
                  maxBp: 1500,
                  stepBp: 50,
                  onChanged: (v) => setState(() => _returnsBp = v),
                ),
                RateSlider(
                  label: 'Inflation',
                  valueBp: _inflationBp,
                  minBp: 300,
                  maxBp: 900,
                  stepBp: 50,
                  onChanged: (v) => setState(() => _inflationBp = v),
                ),

                const SizedBox(height: Spacing.md),

                // Monthly expenses text field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                  child: TextField(
                    controller: _expenseController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Monthly Expenses',
                      prefixText: 'Rs ',
                      hintText: 'Enter monthly expenses',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: _onExpenseChanged,
                  ),
                ),

                const SizedBox(height: Spacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYearsToFiCard(int yearsToFi) {
    final isUnreachable = yearsToFi == -1;
    final fiAge = _currentAge + yearsToFi;

    return FiSecondaryCard(
      label: 'Years to FI',
      value: yearsToFi == 0 ? 'Already FI!' : '$yearsToFi years',
      subtext: 'At your current savings rate (age $fiAge)',
      isUnreachable: isUnreachable,
    );
  }

  Widget _buildCoastFiCard(int coastFiPaise) {
    return FiSecondaryCard(
      label: 'Coast FI',
      value: _formatCompact(coastFiPaise),
      subtext: 'Stop saving today, still reach FI by retirement',
    );
  }
}
