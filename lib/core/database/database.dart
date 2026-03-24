import 'package:drift/drift.dart';

import 'tables/accounts.dart';
import 'tables/allocation_targets.dart';
import 'tables/audit_log.dart';
import 'tables/balance_snapshots.dart';
import 'tables/budgets.dart';
import 'tables/categories.dart';
import 'tables/category_groups.dart';
import 'tables/decisions.dart';
import 'tables/families.dart';
import 'tables/goals.dart';
import 'tables/monthly_metrics.dart';
import 'tables/investment_holdings.dart';
import 'tables/life_profiles.dart';
import 'tables/loan_details.dart';
import 'tables/net_worth_milestones.dart';
import 'tables/recurring_rules.dart';
import 'tables/savings_allocation_rules.dart';
import 'tables/sync_changelog.dart';
import 'tables/sync_state.dart';
import 'tables/transactions.dart';
import 'tables/users.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Families,
    Users,
    Accounts,
    Categories,
    CategoryGroups,
    Transactions,
    BalanceSnapshots,
    AuditLog,
    Goals,
    Budgets,
    LoanDetails,
    InvestmentHoldings,
    LifeProfiles,
    NetWorthMilestones,
    RecurringRules,
    AllocationTargets,
    Decisions,
    MonthlyMetrics,
    SavingsAllocationRules,
    SyncChangelog,
    SyncStateTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 14;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // v6 -> v7: add deletedAt to transactions and recurring_rules
      if (from < 7) {
        await m.addColumn(transactions, transactions.deletedAt);
        await m.addColumn(recurringRules, recurringRules.deletedAt);
      }
      // v7 -> v8: add category_groups table
      if (from < 8) {
        await m.createTable(categoryGroups);
      }
      // v8 -> v9: add life_profiles table + isSecondaryIncome column
      if (from < 9) {
        await m.createTable(lifeProfiles);
        await m.addColumn(recurringRules, recurringRules.isSecondaryIncome);
      }
      // v9 -> v10: add net_worth_milestones table
      if (from < 10) {
        await m.createTable(netWorthMilestones);
      }
      // v10 -> v11: allocation_targets, decisions tables + goal/rule columns
      if (from < 11) {
        await m.createTable(allocationTargets);
        await m.createTable(decisions);
        await m.addColumn(goals, goals.goalCategory);
        await m.addColumn(goals, goals.downPaymentPctBp);
        await m.addColumn(goals, goals.educationEscalationRateBp);
        await m.addColumn(recurringRules, recurringRules.decisionId);
      }
      // v11 -> v12: emergency fund columns on accounts + life_profiles
      if (from < 12) {
        await m.addColumn(accounts, accounts.liquidityTier);
        await m.addColumn(accounts, accounts.isEmergencyFund);
        await m.addColumn(lifeProfiles, lifeProfiles.incomeStability);
        await m.addColumn(lifeProfiles, lifeProfiles.efTargetMonthsOverride);
      }
      // v12 -> v13: monthly_metrics table + sinkingFundSubType column on goals
      if (from < 13) {
        await m.createTable(monthlyMetrics);
        await m.addColumn(goals, goals.sinkingFundSubType);
      }
      // v13 -> v14: savings allocation rules table + opportunity fund / threshold columns on accounts
      if (from < 14) {
        await m.createTable(savingsAllocationRules);
        await m.addColumn(accounts, accounts.isOpportunityFund);
        await m.addColumn(accounts, accounts.opportunityFundTargetPaise);
        await m.addColumn(accounts, accounts.minimumBalancePaise);
      }
    },
    beforeOpen: (details) async {
      // Create indexes if they don't exist
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_transactions_family_date '
        'ON transactions (family_id, date)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_balance_snapshots_account_date '
        'ON balance_snapshots (account_id, snapshot_date)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_sync_changelog_synced_timestamp '
        'ON sync_changelog (synced, timestamp)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_audit_log_family_created '
        'ON audit_log (family_id, created_at)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_accounts_family '
        'ON accounts (family_id)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_life_profiles_user_family '
        'ON life_profiles (user_id, family_id)',
      );
    },
  );
}
