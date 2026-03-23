import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/financial/emergency_fund_engine.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/money.dart';
import '../../../core/providers/database_providers.dart';
import '../../../shared/theme/spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/emergency_fund_provider.dart';
import '../providers/life_profile_provider.dart';
import '../widgets/ef_progress_ring.dart';
import '../widgets/liquidity_tier_chip.dart';

/// Emergency Fund detail screen.
///
/// Sections: progress ring hero, target configuration, linked accounts,
/// and liquidity tier summary (balance-only, TIER-02).
class EmergencyFundScreen extends ConsumerStatefulWidget {
  const EmergencyFundScreen({
    super.key,
    required this.familyId,
    required this.userId,
  });

  final String familyId;
  final String userId;

  @override
  ConsumerState<EmergencyFundScreen> createState() =>
      _EmergencyFundScreenState();
}

class _EmergencyFundScreenState extends ConsumerState<EmergencyFundScreen> {
  int? _localTargetMonths;
  String? _localIncomeStability;

  @override
  Widget build(BuildContext context) {
    final efStateAsync = ref.watch(
      emergencyFundStateProvider((
        userId: widget.userId,
        familyId: widget.familyId,
      )),
    );
    final efAccountsAsync = ref.watch(efAccountsProvider(widget.familyId));
    final tierAccountsAsync = ref.watch(tierAccountsProvider(widget.familyId));
    final profileAsync = ref.watch(
      lifeProfileProvider((userId: widget.userId, familyId: widget.familyId)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Fund')),
      body: efStateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (efState) {
          final efAccounts = efAccountsAsync.whenOrNull(data: (d) => d) ?? [];
          final tierAccounts =
              tierAccountsAsync.whenOrNull(data: (d) => d) ?? [];
          final tierSummary = ref.read(tierSummaryProvider(tierAccounts));
          final profile = profileAsync.whenOrNull(data: (p) => p);
          final incomeStability =
              _localIncomeStability ??
              profile?.incomeStability ??
              'salariedStable';
          final targetMonths = _localTargetMonths ?? efState.targetMonths;

          return ListView(
            padding: const EdgeInsets.all(Spacing.md),
            children: [
              // Section A: Progress Ring Hero
              _buildProgressHero(context, efState, targetMonths),
              const SizedBox(height: Spacing.lg),

              // Section B: Target Configuration
              _buildTargetConfig(
                context,
                efState,
                targetMonths,
                incomeStability,
              ),
              const SizedBox(height: Spacing.lg),

              // Section C: Linked Accounts
              _buildLinkedAccounts(context, efAccounts),
              const SizedBox(height: Spacing.lg),

              // Section D: Liquidity Tier Summary
              _buildTierSummary(context, tierSummary, tierAccounts, efState),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section A: Progress Ring Hero
  // ---------------------------------------------------------------------------

  Widget _buildProgressHero(
    BuildContext context,
    EmergencyFundState efState,
    int targetMonths,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Center(
          child: EfProgressRing(
            coverageMonths: efState.coverageMonths,
            targetMonths: targetMonths,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          '${efState.coverageMonths.toStringAsFixed(1)} / $targetMonths months covered',
          style: theme.textTheme.titleMedium,
        ),
        Text(
          'Target: ${Money(efState.targetAmountPaise).formatted}',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
        if (efState.monthsOfData < 6)
          Padding(
            padding: const EdgeInsets.only(top: Spacing.xs),
            child: Text(
              'Based on ${efState.monthsOfData} months of data - accuracy improves over time',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        if (efState.hasOverride)
          Padding(
            padding: const EdgeInsets.only(top: Spacing.xs),
            child: Text(
              'Suggested: ${efState.suggestedTargetMonths} months',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Section B: Target Configuration
  // ---------------------------------------------------------------------------

  Widget _buildTargetConfig(
    BuildContext context,
    EmergencyFundState efState,
    int targetMonths,
    String incomeStability,
  ) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Target Months', style: theme.textTheme.titleSmall),
            const SizedBox(height: Spacing.sm),
            Row(
              children: [
                IconButton(
                  onPressed: targetMonths > 1
                      ? () => setState(
                          () => _localTargetMonths = targetMonths - 1,
                        )
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$targetMonths', style: theme.textTheme.headlineSmall),
                IconButton(
                  onPressed: targetMonths < 24
                      ? () => setState(
                          () => _localTargetMonths = targetMonths + 1,
                        )
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            Text(
              'Suggested: ${efState.suggestedTargetMonths} months',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            Text(
              'Monthly essentials: ${Money(efState.monthlyEssentialPaise).formatted}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: Spacing.sm),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Income Stability',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              initialValue: incomeStability,
              items: IncomeStability.values.map((s) {
                return DropdownMenuItem(
                  value: s.name,
                  child: Text(_incomeStabilityLabel(s.name)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _localIncomeStability = value);
                }
              },
            ),
            const SizedBox(height: Spacing.md),
            FilledButton(
              onPressed: () => _saveTargetConfig(incomeStability),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTargetConfig(String incomeStability) async {
    final dao = ref.read(lifeProfileDaoProvider);
    final profile = await dao.getForUser(widget.userId, widget.familyId);
    if (profile == null) return;

    await dao.upsertProfile(
      LifeProfilesCompanion(
        id: Value(profile.id),
        userId: Value(widget.userId),
        familyId: Value(widget.familyId),
        dateOfBirth: Value(profile.dateOfBirth),
        createdAt: Value(profile.createdAt),
        updatedAt: Value(DateTime.now()),
        incomeStability: Value(incomeStability),
        efTargetMonthsOverride: Value(_localTargetMonths),
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Target updated')));
    }
  }

  // ---------------------------------------------------------------------------
  // Section C: Linked Accounts
  // ---------------------------------------------------------------------------

  Widget _buildLinkedAccounts(BuildContext context, List<Account> efAccounts) {
    final theme = Theme.of(context);
    if (efAccounts.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Linked Accounts', style: theme.textTheme.titleSmall),
              const Spacer(),
              TextButton(
                onPressed: () => _openAccountSelector(context),
                child: const Text('Edit'),
              ),
            ],
          ),
          EmptyState(
            icon: Icons.shield_outlined,
            title: 'No accounts linked yet',
            actionLabel: 'Link Accounts',
            onAction: () => _openAccountSelector(context),
          ),
        ],
      );
    }

    final totalBalance = efAccounts.fold<int>(0, (sum, a) => sum + a.balance);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Linked Accounts', style: theme.textTheme.titleSmall),
            const Spacer(),
            TextButton(
              onPressed: () => _openAccountSelector(context),
              child: const Text('Edit'),
            ),
          ],
        ),
        ...efAccounts.map(
          (account) => ListTile(
            leading: const Icon(Icons.shield),
            title: Text(account.name),
            subtitle: Text(account.type),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (account.liquidityTier != null)
                  LiquidityTierChip(
                    tier: account.liquidityTier!,
                    onTap: () => _showTierPicker(context, account),
                  )
                else
                  TextButton(
                    onPressed: () => _showTierPicker(context, account),
                    child: const Text('Set tier'),
                  ),
                const SizedBox(width: Spacing.xs),
                Text(Money(account.balance).formatted),
              ],
            ),
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: theme.textTheme.titleSmall),
              Text(
                Money(totalBalance).formatted,
                style: theme.textTheme.titleSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Section D: Liquidity Tier Summary
  // ---------------------------------------------------------------------------

  Widget _buildTierSummary(
    BuildContext context,
    Map<String, int> tierSummary,
    List<Account> tierAccounts,
    EmergencyFundState efState,
  ) {
    final theme = Theme.of(context);
    final suggested = EmergencyFundEngine.suggestTierDistribution(
      targetMonths: efState.targetMonths,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cash by Liquidity', style: theme.textTheme.titleSmall),
        const SizedBox(height: Spacing.sm),
        if (tierSummary.isEmpty)
          Text(
            'No tier data yet. Assign tiers to linked accounts.',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          )
        else
          ...tierSummary.entries.map((entry) {
            final count = tierAccounts
                .where((a) => a.liquidityTier == entry.key)
                .length;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  LiquidityTierChip(tier: entry.key),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      Money(entry.value).formatted,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    '$count account${count == 1 ? '' : 's'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: Spacing.sm),
        Text(
          'Suggested split: ${suggested['instant']}mo instant, '
          '${suggested['shortTerm']}mo short-term, '
          '${suggested['longTerm']}mo long-term',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Account Selector Bottom Sheet
  // ---------------------------------------------------------------------------

  void _openAccountSelector(BuildContext context) {
    final familyId = widget.familyId;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (ctx, scrollController) => _AccountSelectorSheet(
          familyId: familyId,
          scrollController: scrollController,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tier Picker Dialog
  // ---------------------------------------------------------------------------

  void _showTierPicker(BuildContext context, Account account) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Set tier for ${account.name}'),
        children: [
          for (final tier in ['instant', 'shortTerm', 'longTerm'])
            SimpleDialogOption(
              onPressed: () {
                ref.read(accountDaoProvider).setLiquidityTier(account.id, tier);
                Navigator.pop(ctx);
              },
              child: Text(_tierLabel(tier)),
            ),
          SimpleDialogOption(
            onPressed: () {
              ref.read(accountDaoProvider).setLiquidityTier(account.id, null);
              Navigator.pop(ctx);
            },
            child: const Text('None'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _incomeStabilityLabel(String name) {
    return switch (name) {
      'salariedStable' => 'Salaried (Stable)',
      'salariedVariable' => 'Salaried (Variable)',
      'freelance' => 'Freelance',
      'selfEmployed' => 'Self-Employed',
      _ => name,
    };
  }

  String _tierLabel(String tier) {
    return switch (tier) {
      'instant' => 'Instant',
      'shortTerm' => 'Short-term',
      'longTerm' => 'Long-term',
      _ => tier,
    };
  }
}

// ---------------------------------------------------------------------------
// Account Selector Sheet (used in bottom sheet)
// ---------------------------------------------------------------------------

class _AccountSelectorSheet extends ConsumerWidget {
  const _AccountSelectorSheet({
    required this.familyId,
    required this.scrollController,
  });

  final String familyId;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(_allAccountsProvider(familyId));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Row(
            children: [
              Text(
                'Select EF Accounts',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: accountsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (accounts) => ListView.builder(
              controller: scrollController,
              itemCount: accounts.length,
              itemBuilder: (ctx, i) {
                final account = accounts[i];
                return CheckboxListTile(
                  title: Text(account.name),
                  subtitle: Text(
                    '${account.type} - ${Money(account.balance).formatted}',
                  ),
                  value: account.isEmergencyFund,
                  onChanged: (checked) {
                    ref
                        .read(accountDaoProvider)
                        .setEmergencyFund(account.id, checked ?? false);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Provider watching all non-deleted accounts for the selector sheet.
final _allAccountsProvider = StreamProvider.family<List<Account>, String>((
  ref,
  familyId,
) {
  return ref.watch(accountDaoProvider).watchAll(familyId);
});
