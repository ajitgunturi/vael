import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database.dart';
import '../../../shared/theme/spacing.dart';
import '../providers/life_profile_provider.dart';
import '../widgets/rate_slider.dart';
import '../widgets/risk_profile_card.dart';

const _uuid = Uuid();

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// 3-step wizard for creating or editing a life profile.
///
/// Step 1: Personal Details (DOB + retirement age)
/// Step 2: Risk Profile (card selection)
/// Step 3: Growth Rates (rate sliders + hike month)
///
/// If [existingProfile] is provided, fields are pre-filled for edit mode.
class LifeProfileWizardScreen extends ConsumerStatefulWidget {
  const LifeProfileWizardScreen({
    super.key,
    required this.userId,
    required this.familyId,
    this.existingProfile,
  });

  final String userId;
  final String familyId;
  final LifeProfile? existingProfile;

  @override
  ConsumerState<LifeProfileWizardScreen> createState() =>
      _LifeProfileWizardScreenState();
}

class _LifeProfileWizardScreenState
    extends ConsumerState<LifeProfileWizardScreen> {
  int _currentStep = 0;

  // Step 1: Personal Details
  DateTime? _dateOfBirth;
  late int _retirementAge;

  // Step 2: Risk Profile
  late String _riskProfile;

  // Step 3: Growth Rates
  late int _incomeGrowthBp;
  late int _inflationBp;
  late int _swrBp;
  late int _hikeMonth;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.existingProfile;
    _dateOfBirth = p?.dateOfBirth;
    _retirementAge = p?.plannedRetirementAge ?? 60;
    _riskProfile = p?.riskProfile ?? 'MODERATE';
    _incomeGrowthBp = p?.annualIncomeGrowthBp ?? 800;
    _inflationBp = p?.expectedInflationBp ?? 600;
    _swrBp = p?.safeWithdrawalRateBp ?? 300;
    _hikeMonth = p?.hikeMonth ?? 4;
  }

  bool get _isEditMode => widget.existingProfile != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Life Profile' : 'Life Profile Setup'),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        onStepTapped: (step) => setState(() => _currentStep = step),
        controlsBuilder: _buildControls,
        steps: [
          Step(
            title: const Text('Personal Details'),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: _buildStep1(),
          ),
          Step(
            title: const Text('Risk Profile'),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: _buildStep2(),
          ),
          Step(
            title: const Text('Growth Rates'),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
            content: _buildStep3(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: Spacing.sm),
        ListTile(
          title: const Text('Date of Birth'),
          subtitle: Text(
            _dateOfBirth != null
                ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                : 'Tap to select',
          ),
          trailing: const Icon(Icons.calendar_today),
          onTap: _pickDateOfBirth,
        ),
        const SizedBox(height: Spacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Planned Retirement Age',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SizedBox(
                width: 80,
                child: TextFormField(
                  initialValue: _retirementAge.toString(),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: Spacing.sm,
                      vertical: Spacing.sm,
                    ),
                  ),
                  onChanged: (v) {
                    final parsed = int.tryParse(v);
                    if (parsed != null && parsed >= 40 && parsed <= 80) {
                      setState(() => _retirementAge = parsed);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.sm),
      ],
    );
  }

  Widget _buildStep2() {
    const profiles = ['CONSERVATIVE', 'MODERATE', 'AGGRESSIVE'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Row(
        children: profiles
            .map(
              (p) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
                  child: RiskProfileCard(
                    riskProfile: p,
                    isSelected: _riskProfile == p,
                    onTap: () => setState(() => _riskProfile = p),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        const SizedBox(height: Spacing.sm),
        RateSlider(
          label: 'Income Growth',
          valueBp: _incomeGrowthBp,
          minBp: 0,
          maxBp: 2000,
          stepBp: 50,
          onChanged: (v) => setState(() => _incomeGrowthBp = v),
        ),
        RateSlider(
          label: 'Inflation',
          valueBp: _inflationBp,
          minBp: 200,
          maxBp: 1200,
          stepBp: 50,
          onChanged: (v) => setState(() => _inflationBp = v),
        ),
        RateSlider(
          label: 'Safe Withdrawal Rate',
          valueBp: _swrBp,
          minBp: 200,
          maxBp: 600,
          stepBp: 25,
          onChanged: (v) => setState(() => _swrBp = v),
        ),
        const SizedBox(height: Spacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Annual Hike Month',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              DropdownButton<int>(
                value: _hikeMonth,
                items: List.generate(
                  12,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text(_monthNames[i]),
                  ),
                ),
                onChanged: (v) {
                  if (v != null) setState(() => _hikeMonth = v);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.sm),
      ],
    );
  }

  Widget _buildControls(BuildContext context, ControlsDetails details) {
    // Only render controls for the active step to avoid overlap issues
    if (details.stepIndex != _currentStep) {
      return const SizedBox.shrink();
    }
    final isLastStep = _currentStep == 2;
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.md),
      child: Row(
        children: [
          if (_currentStep > 0)
            TextButton(
              onPressed: details.onStepCancel,
              child: const Text('Back'),
            ),
          const Spacer(),
          FilledButton(
            onPressed: _saving ? null : details.onStepContinue,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(isLastStep ? 'Save' : 'Next'),
          ),
        ],
      ),
    );
  }

  void _onStepContinue() {
    if (_currentStep == 0 && _dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your date of birth')),
      );
      return;
    }
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _save();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 30),
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year - 18),
      helpText: 'Select Date of Birth',
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final dao = ref.read(lifeProfileDaoProvider);
      final now = DateTime.now();
      final id = widget.existingProfile?.id ?? _uuid.v4();

      await dao.upsertProfile(
        LifeProfilesCompanion(
          id: Value(id),
          userId: Value(widget.userId),
          familyId: Value(widget.familyId),
          dateOfBirth: Value(_dateOfBirth!),
          plannedRetirementAge: Value(_retirementAge),
          riskProfile: Value(_riskProfile),
          annualIncomeGrowthBp: Value(_incomeGrowthBp),
          expectedInflationBp: Value(_inflationBp),
          safeWithdrawalRateBp: Value(_swrBp),
          hikeMonth: Value(_hikeMonth),
          createdAt: Value(widget.existingProfile?.createdAt ?? now),
          updatedAt: Value(now),
        ),
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
