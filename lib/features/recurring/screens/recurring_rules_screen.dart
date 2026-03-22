import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/utils/formatters.dart';
import '../providers/recurring_providers.dart';
import 'recurring_form_screen.dart';

/// Displays list of recurring rules with status indicators.
class RecurringRulesScreen extends ConsumerWidget {
  const RecurringRulesScreen({super.key, required this.familyId});

  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesAsync = ref.watch(recurringRulesProvider(familyId));

    return Scaffold(
      appBar: AppBar(title: const Text('Recurring Rules')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RecurringFormScreen(familyId: familyId),
          ),
        ),
        child: const Icon(Icons.add),
      ),
      body: rulesAsync.when(
        data: (rules) => rules.isEmpty
            ? const _EmptyBody()
            : _RulesList(rules: rules, ref: ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.repeat, size: 64),
          SizedBox(height: 16),
          Text('No recurring rules yet'),
          SizedBox(height: 8),
          Text('Automate SIPs, rent, salary, and more'),
        ],
      ),
    );
  }
}

class _RulesList extends StatelessWidget {
  const _RulesList({required this.rules, required this.ref});

  final List<RecurringRule> rules;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: rules.length,
      itemBuilder: (context, i) {
        final rule = rules[i];
        return RecurringRuleCard(
          name: rule.name,
          kind: rule.kind,
          amount: rule.amount,
          frequencyMonths: rule.frequencyMonths,
          isPaused: rule.isPaused,
          onTogglePause: () async {
            final dao = ref.read(recurringRuleDaoProvider);
            if (rule.isPaused) {
              await dao.resume(rule.id);
            } else {
              await dao.pause(rule.id);
            }
          },
        );
      },
    );
  }
}

/// Card for a single recurring rule.
class RecurringRuleCard extends StatelessWidget {
  const RecurringRuleCard({
    super.key,
    required this.name,
    required this.kind,
    required this.amount,
    required this.frequencyMonths,
    required this.isPaused,
    this.onTap,
    this.onTogglePause,
  });

  final String name;
  final String kind;
  final int amount;
  final double frequencyMonths;
  final bool isPaused;
  final VoidCallback? onTap;
  final VoidCallback? onTogglePause;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = ColorTokens.of(context);
    final isIncome = {'income', 'salary', 'dividend'}.contains(kind);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: isPaused
              ? theme.colorScheme.surfaceContainerHighest
              : (isIncome ? colors.income : colors.expense).withValues(
                  alpha: 0.15,
                ),
          child: Icon(
            _kindIcon(kind),
            color: isPaused
                ? theme.colorScheme.onSurfaceVariant
                : (isIncome ? colors.income : colors.expense),
          ),
        ),
        title: Text(
          name,
          style: isPaused
              ? TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  decoration: TextDecoration.lineThrough,
                )
              : null,
        ),
        subtitle: Text(
          '₹${formatIndianNumber(amount ~/ 100)} · ${_frequencyLabel(frequencyMonths)}',
        ),
        trailing: IconButton(
          icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
          onPressed: onTogglePause,
          tooltip: isPaused ? 'Resume' : 'Pause',
        ),
      ),
    );
  }

  IconData _kindIcon(String kind) {
    return switch (kind) {
      'salary' || 'income' => Icons.arrow_downward,
      'expense' => Icons.arrow_upward,
      'transfer' => Icons.swap_horiz,
      'emiPayment' => Icons.home,
      'insurancePremium' => Icons.shield,
      'dividend' => Icons.trending_up,
      _ => Icons.repeat,
    };
  }

  String _frequencyLabel(double months) {
    if (months == 0.5) return 'Biweekly';
    if (months == 1) return 'Monthly';
    if (months == 3) return 'Quarterly';
    if (months == 6) return 'Semi-annual';
    if (months == 12) return 'Annual';
    return 'Every ${months}m';
  }
}
