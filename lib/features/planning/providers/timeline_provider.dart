import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/daos/goal_dao.dart';
import '../../../core/financial/fi_calculator.dart';
import '../../../core/financial/milestone_engine.dart';
import '../../../core/providers/database_providers.dart';
import '../../../shared/utils/formatters.dart';
import 'fi_calculator_provider.dart';
import 'life_profile_provider.dart';
import 'milestone_provider.dart';

/// Type of event represented on the lifetime timeline.
enum TimelineNodeType { milestone, purchase, fiDate }

/// Status of a timeline node for color coding.
enum TimelineNodeStatus { onTrack, atRisk, behind }

/// A single node on the lifetime timeline.
class TimelineNode {
  final TimelineNodeType type;
  final int age;
  final String label;
  final TimelineNodeStatus statusColor;
  final String? detailRoute;
  final String? referenceId;

  const TimelineNode({
    required this.type,
    required this.age,
    required this.label,
    required this.statusColor,
    this.detailRoute,
    this.referenceId,
  });
}

/// Formats paise into compact Indian form: "1Cr", "50L", "5K".
String _compactLabel(int paise) {
  final rupees = paise / 100;
  if (rupees >= 10000000) {
    final cr = rupees / 10000000;
    return '${cr >= 10 ? cr.toStringAsFixed(0) : cr.toStringAsFixed(1)}Cr';
  } else if (rupees >= 100000) {
    final l = rupees / 100000;
    return '${l >= 10 ? l.toStringAsFixed(0) : l.toStringAsFixed(1)}L';
  } else if (rupees >= 1000) {
    final k = rupees / 1000;
    return '${k >= 10 ? k.toStringAsFixed(0) : k.toStringAsFixed(1)}K';
  }
  return formatIndianNumber(rupees.toInt());
}

/// Maps [MilestoneStatus] to [TimelineNodeStatus].
TimelineNodeStatus _mapMilestoneStatus(MilestoneStatus status) {
  switch (status) {
    case MilestoneStatus.ahead:
    case MilestoneStatus.onTrack:
    case MilestoneStatus.reached:
      return TimelineNodeStatus.onTrack;
    case MilestoneStatus.behind:
    case MilestoneStatus.missed:
      return TimelineNodeStatus.behind;
  }
}

/// Computes age from date of birth.
int _ageFromDob(DateTime dob) {
  final now = DateTime.now();
  int age = now.year - dob.year;
  if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
    age--;
  }
  return age;
}

/// Provides the current age from the life profile, or null if none.
final currentAgeProvider =
    Provider.family<int?, ({String userId, String familyId})>((ref, params) {
      final fi = ref.watch(fiDefaultInputsProvider(params));
      return fi.hasLifeProfile ? fi.currentAge : null;
    });

/// Combines milestones, purchase goals, and FI date into timeline nodes.
///
/// Returns empty list when no life profile exists.
final timelineNodesProvider =
    FutureProvider.family<
      List<TimelineNode>,
      ({String userId, String familyId})
    >((ref, params) async {
      final fi = ref.watch(fiDefaultInputsProvider(params));
      if (!fi.hasLifeProfile) return [];

      final profileAsync = ref.watch(
        lifeProfileProvider((userId: params.userId, familyId: params.familyId)),
      );
      final profile = profileAsync.value;
      if (profile == null) return [];

      final currentAge = fi.currentAge;
      final nodes = <TimelineNode>[];

      // --- Milestone nodes ---
      final milestoneAsync = ref.watch(
        milestoneListProvider((
          userId: params.userId,
          familyId: params.familyId,
        )),
      );
      final milestones = milestoneAsync.value ?? [];
      for (final m in milestones) {
        nodes.add(
          TimelineNode(
            type: TimelineNodeType.milestone,
            age: m.age,
            label: _compactLabel(m.targetAmountPaise),
            statusColor: _mapMilestoneStatus(m.status),
            detailRoute: 'milestone',
            referenceId: m.milestoneId,
          ),
        );
      }

      // --- Purchase goal nodes ---
      final db = ref.watch(databaseProvider);
      final goalDao = GoalDao(db);
      final purchaseGoals = await goalDao
          .watchByCategory(params.familyId, 'purchase')
          .first;
      final dob = profile.dateOfBirth;
      for (final g in purchaseGoals) {
        final goalAge =
            _ageFromDob(dob) +
            g.targetDate.difference(DateTime.now()).inDays ~/ 365;
        final truncatedName = g.name.length > 6
            ? g.name.substring(0, 6)
            : g.name;
        nodes.add(
          TimelineNode(
            type: TimelineNodeType.purchase,
            age: goalAge,
            label: truncatedName,
            statusColor: TimelineNodeStatus.onTrack,
            detailRoute: 'purchase',
            referenceId: g.id,
          ),
        );
      }

      // --- FI date node ---
      final fiNumber = FiCalculator.computeFiNumber(
        annualExpensesPaise: fi.monthlyExpensesPaise * 12,
        swr: fi.swrBp / 10000.0,
        inflationRate: fi.inflationBp / 10000.0,
        yearsToRetirement: fi.retirementAge - currentAge,
      );
      final yearsToFi = FiCalculator.yearsToFi(
        currentPortfolioPaise: fi.currentPortfolioPaise,
        monthlySavingsPaise: fi.monthlySavingsPaise,
        annualReturnRate: fi.returnsBp / 10000.0,
        fiNumberPaise: fiNumber,
      );
      if (yearsToFi >= 0) {
        nodes.add(
          TimelineNode(
            type: TimelineNodeType.fiDate,
            age: currentAge + yearsToFi,
            label: 'FI',
            statusColor: TimelineNodeStatus.onTrack,
            detailRoute: 'fi',
          ),
        );
      }

      // Sort by age ascending
      nodes.sort((a, b) => a.age.compareTo(b.age));
      return nodes;
    });
