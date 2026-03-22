import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/financial/income_growth_engine.dart';
import '../../../core/financial/projection_engine.dart';
import 'life_profile_provider.dart';

/// Computes salary trajectory flows from a user's life profile.
///
/// Returns null if no life profile exists yet.
/// Layer 1 provider: watches Layer 0 [lifeProfileProvider].
/// When the life profile changes (e.g. after wizard save), this provider
/// automatically recomputes — satisfying LIFE-04 reactive updates.
final salaryTrajectoryProvider =
    Provider.family<
      List<ProjectionCashFlow>?,
      ({String userId, String familyId, int currentMonthlySalary})
    >((ref, params) {
      final profileAsync = ref.watch(
        lifeProfileProvider((userId: params.userId, familyId: params.familyId)),
      );
      return profileAsync.whenOrNull(
        data: (profile) {
          if (profile == null) return null;
          final now = DateTime.now();
          final age = now.year - profile.dateOfBirth.year;
          return IncomeGrowthEngine.buildSalaryTrajectory(
            currentMonthlySalary: params.currentMonthlySalary,
            currentAge: age,
            retirementAge: profile.plannedRetirementAge,
            baseAnnualGrowthRate: bpToRate(profile.annualIncomeGrowthBp),
            hikeMonth: profile.hikeMonth,
          );
        },
      );
    });
