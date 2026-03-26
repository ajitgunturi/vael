import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/database/daos/account_dao.dart';
import '../../../core/database/daos/goal_dao.dart';
import '../../../core/database/daos/monthly_metrics_dao.dart';
import '../../../core/database/daos/savings_allocation_rule_dao.dart';
import '../../../core/financial/savings_allocation_engine.dart' as engine;
import '../../../core/providers/database_providers.dart';
import 'emergency_fund_provider.dart';

// ---------------------------------------------------------------------------
// Stream of allocation rules for family, sorted by priority
// ---------------------------------------------------------------------------

/// Watches all active savings allocation rules for a family, ordered by
/// ascending priority (1 = highest).
final allocationRulesProvider =
    StreamProvider.family<List<SavingsAllocationRule>, String>((ref, familyId) {
      final dao = ref.watch(savingsAllocationRuleDaoProvider);
      return dao.watchByFamily(familyId);
    });

// ---------------------------------------------------------------------------
// Current month surplus in paise from MonthlyMetrics
// ---------------------------------------------------------------------------

/// Computes the current month's surplus (income - expenses) from cached
/// monthly metrics. Returns 0 if no metrics exist for the current month.
final monthlySurplusProvider = FutureProvider.family<int, String>((
  ref,
  familyId,
) async {
  final db = ref.watch(databaseProvider);
  final dao = MonthlyMetricsDao(db);
  final now = DateTime.now();
  final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
  final metrics = await dao.getByMonth(familyId, monthKey);
  if (metrics == null) return 0;
  return metrics.totalIncomePaise - metrics.totalExpensesPaise;
});

// ---------------------------------------------------------------------------
// Advisory allocation output
// ---------------------------------------------------------------------------

/// Computes advisory allocation advice by distributing the current month's
/// surplus across active rules in priority order using
/// [engine.SavingsAllocationEngine.distribute].
///
/// Builds the targets map from: EF accounts, sinking fund goals,
/// investment goals, and the designated opportunity fund account.
final allocationAdvisoryProvider =
    FutureProvider.family<List<engine.AllocationAdvice>, String>((
      ref,
      familyId,
    ) async {
      final db = ref.watch(databaseProvider);
      final ruleDao = SavingsAllocationRuleDao(db);
      final accountDao = AccountDao(db);

      // 1. Get rules sorted by priority
      final dbRules = await ruleDao.getByFamily(familyId);
      final rules = dbRules
          .map(
            (r) => engine.AllocationRule(
              priority: r.priority,
              targetType: r.targetType,
              targetId: r.targetId,
              allocationType: r.allocationType,
              amountPaise: r.amountPaise,
              percentageBp: r.percentageBp,
            ),
          )
          .toList();

      // 2. Get surplus
      final surplus = await ref.read(monthlySurplusProvider(familyId).future);
      if (surplus <= 0) return [];

      // 3. Build targets map keyed by '$targetType:$targetId'
      final targets = <String, engine.AllocationTarget>{};

      // Emergency fund target
      final efAccounts = await accountDao
          .watchEmergencyFundAccounts(familyId)
          .first;
      if (efAccounts.isNotEmpty) {
        final efBalance = efAccounts.fold<int>(0, (sum, a) => sum + a.balance);
        // Attempt to read EF target from emergencyFundStateProvider.
        // Falls back to 0 (unlimited) if userId is unavailable or provider errors.
        int efTargetPaise = 0;
        try {
          final efState = await ref.read(
            emergencyFundStateProvider((
              userId: '', // advisory context; life profile may not resolve
              familyId: familyId,
            )).future,
          );
          efTargetPaise = efState.targetAmountPaise;
        } catch (_) {
          // No life profile available -- treat EF as unlimited target
        }
        targets['emergencyFund:null'] = engine.AllocationTarget(
          targetType: 'emergencyFund',
          targetId: null,
          targetName: 'Emergency Fund',
          currentPaise: efBalance,
          targetPaise: efTargetPaise,
        );
      }

      // Sinking fund targets
      final goalDao = GoalDao(db);
      final sfGoals = await goalDao
          .watchByCategory(familyId, 'sinkingFund')
          .first;
      for (final goal in sfGoals) {
        final key = 'sinkingFund:${goal.id}';
        targets[key] = engine.AllocationTarget(
          targetType: 'sinkingFund',
          targetId: goal.id,
          targetName: goal.name,
          currentPaise: goal.currentSavings,
          targetPaise: goal.targetAmount,
        );
      }

      // Investment goal targets
      final igGoals = await goalDao
          .watchByCategory(familyId, 'investmentGoal')
          .first;
      for (final goal in igGoals) {
        final key = 'investmentGoal:${goal.id}';
        targets[key] = engine.AllocationTarget(
          targetType: 'investmentGoal',
          targetId: goal.id,
          targetName: goal.name,
          currentPaise: goal.currentSavings,
          targetPaise: goal.targetAmount,
        );
      }

      // Opportunity fund target
      final oppAccount = await accountDao.watchOpportunityFund(familyId).first;
      if (oppAccount != null) {
        targets['opportunityFund:null'] = engine.AllocationTarget(
          targetType: 'opportunityFund',
          targetId: null,
          targetName: oppAccount.name,
          currentPaise: oppAccount.balance,
          targetPaise: oppAccount.opportunityFundTargetPaise ?? 0,
        );
      }

      // 4. Distribute
      return engine.SavingsAllocationEngine.distribute(
        surplusPaise: surplus,
        rules: rules,
        targets: targets,
      );
    });
