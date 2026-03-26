import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import 'life_profile_provider.dart';

/// Immutable snapshot of all inputs needed to compute FI metrics.
///
/// Rates are stored as integer basis points (100 bp = 1%).
/// Monetary values are in paise (100 paise = 1 rupee).
class FiInputs {
  final int swrBp;
  final int returnsBp;
  final int inflationBp;
  final int monthlyExpensesPaise;
  final int currentAge;
  final int retirementAge;
  final int currentPortfolioPaise;
  final int monthlySavingsPaise;

  /// Whether these defaults were populated from a life profile.
  final bool hasLifeProfile;

  const FiInputs({
    this.swrBp = 300,
    this.returnsBp = 1000,
    this.inflationBp = 600,
    this.monthlyExpensesPaise = 5000000,
    this.currentAge = 30,
    this.retirementAge = 60,
    this.currentPortfolioPaise = 0,
    this.monthlySavingsPaise = 0,
    this.hasLifeProfile = false,
  });

  FiInputs copyWith({
    int? swrBp,
    int? returnsBp,
    int? inflationBp,
    int? monthlyExpensesPaise,
    int? currentAge,
    int? retirementAge,
    int? currentPortfolioPaise,
    int? monthlySavingsPaise,
    bool? hasLifeProfile,
  }) {
    return FiInputs(
      swrBp: swrBp ?? this.swrBp,
      returnsBp: returnsBp ?? this.returnsBp,
      inflationBp: inflationBp ?? this.inflationBp,
      monthlyExpensesPaise: monthlyExpensesPaise ?? this.monthlyExpensesPaise,
      currentAge: currentAge ?? this.currentAge,
      retirementAge: retirementAge ?? this.retirementAge,
      currentPortfolioPaise:
          currentPortfolioPaise ?? this.currentPortfolioPaise,
      monthlySavingsPaise: monthlySavingsPaise ?? this.monthlySavingsPaise,
      hasLifeProfile: hasLifeProfile ?? this.hasLifeProfile,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FiInputs &&
          swrBp == other.swrBp &&
          returnsBp == other.returnsBp &&
          inflationBp == other.inflationBp &&
          monthlyExpensesPaise == other.monthlyExpensesPaise &&
          currentAge == other.currentAge &&
          retirementAge == other.retirementAge &&
          currentPortfolioPaise == other.currentPortfolioPaise &&
          monthlySavingsPaise == other.monthlySavingsPaise &&
          hasLifeProfile == other.hasLifeProfile;

  @override
  int get hashCode => Object.hash(
    swrBp,
    returnsBp,
    inflationBp,
    monthlyExpensesPaise,
    currentAge,
    retirementAge,
    currentPortfolioPaise,
    monthlySavingsPaise,
    hasLifeProfile,
  );
}

/// Computes current age from date of birth.
int _ageFromDob(DateTime dob) {
  final now = DateTime.now();
  int age = now.year - dob.year;
  if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
    age--;
  }
  return age;
}

/// Builds [FiInputs] from the user's life profile (if it exists),
/// falling back to standalone placeholder defaults.
///
/// This is a synchronous provider -- no async FI computation.
final fiDefaultInputsProvider =
    Provider.family<FiInputs, ({String userId, String familyId})>((
      ref,
      params,
    ) {
      final profileAsync = ref.watch(
        lifeProfileProvider((userId: params.userId, familyId: params.familyId)),
      );

      final LifeProfile? profile = profileAsync.value;

      if (profile == null) {
        return const FiInputs();
      }

      return FiInputs(
        swrBp: profile.safeWithdrawalRateBp,
        returnsBp: 1000, // default 10%, not stored in profile
        inflationBp: profile.expectedInflationBp,
        monthlyExpensesPaise:
            5000000, // placeholder, no budget provider wired yet
        currentAge: _ageFromDob(profile.dateOfBirth),
        retirementAge: profile.plannedRetirementAge,
        currentPortfolioPaise: 0,
        monthlySavingsPaise: 0,
        hasLifeProfile: true,
      );
    });
