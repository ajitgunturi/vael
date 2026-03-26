import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/financial/investment_valuation.dart';
import '../../../core/providers/session_providers.dart';
import '../../../shared/theme/color_tokens.dart' show ColorTokens;
import '../../../shared/utils/formatters.dart';
import '../../planning/widgets/allocation_banner.dart';
import '../providers/investment_providers.dart';
import 'investment_form_screen.dart';

/// Displays investment portfolio with bucket cards and summary.
class InvestmentPortfolioScreen extends ConsumerWidget {
  const InvestmentPortfolioScreen({super.key, required this.familyId});

  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdingsAsync = ref.watch(investmentHoldingsProvider(familyId));
    final userId = ref.watch(sessionUserIdProvider) ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Investments')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => InvestmentFormScreen(familyId: familyId),
          ),
        ),
        child: const Icon(Icons.add),
      ),
      body: holdingsAsync.when(
        data: (holdings) => holdings.isEmpty
            ? const _EmptyBody()
            : _PortfolioList(
                holdings: holdings,
                familyId: familyId,
                userId: userId,
              ),
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
          Icon(Icons.pie_chart_outline, size: 64),
          SizedBox(height: 16),
          Text('No investment buckets yet'),
          SizedBox(height: 8),
          Text('Tap + to add your first bucket'),
        ],
      ),
    );
  }
}

class _PortfolioList extends StatelessWidget {
  const _PortfolioList({
    required this.holdings,
    required this.familyId,
    required this.userId,
  });

  final List<InvestmentHolding> holdings;
  final String familyId;
  final String userId;

  @override
  Widget build(BuildContext context) {
    // Compute summary
    final totalInvested = holdings.fold<int>(
      0,
      (sum, h) => sum + h.investedAmount,
    );
    final totalCurrent = holdings.fold<int>(
      0,
      (sum, h) => sum + h.currentValue,
    );

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        // NAV-07: Allocation banner at top of portfolio
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AllocationBanner(
            familyId: familyId,
            userId: userId,
            userAge: 30, // Default; banner will use provider for actual age
          ),
        ),
        PortfolioSummaryCard(
          summary: PortfolioSummary(
            totalInvested: totalInvested,
            totalCurrentValue: totalCurrent,
            totalGain: totalCurrent - totalInvested,
            overallReturnPercent: totalInvested > 0
                ? ((totalCurrent - totalInvested) / totalInvested * 100)
                : 0.0,
          ),
        ),
        for (final h in holdings)
          BucketCard(
            name: h.name,
            bucketType: h.bucketType,
            investedAmount: h.investedAmount,
            currentValue: h.currentValue,
            returnRate: h.expectedReturnRate,
          ),
      ],
    );
  }
}

/// Summary card showing total portfolio value and returns.
class PortfolioSummaryCard extends StatelessWidget {
  const PortfolioSummaryCard({super.key, required this.summary});

  final PortfolioSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = ColorTokens.of(context);
    final gainColor = summary.totalGain >= 0 ? colors.income : colors.expense;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portfolio Value',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '₹${formatIndianNumber(summary.totalCurrentValue ~/ 100)}',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _MetricChip(
                  label: 'Invested',
                  value: '₹${formatIndianNumber(summary.totalInvested ~/ 100)}',
                ),
                const SizedBox(width: 12),
                _MetricChip(
                  label: 'Returns',
                  value:
                      '${summary.overallReturnPercent >= 0 ? '+' : ''}${summary.overallReturnPercent.toStringAsFixed(1)}%',
                  color: gainColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(value, style: theme.textTheme.titleMedium?.copyWith(color: color)),
      ],
    );
  }
}

/// Card for a single investment bucket.
class BucketCard extends StatelessWidget {
  const BucketCard({
    super.key,
    required this.name,
    required this.bucketType,
    required this.investedAmount,
    required this.currentValue,
    required this.returnRate,
    this.onTap,
  });

  final String name;
  final String bucketType;
  final int investedAmount;
  final int currentValue;
  final double returnRate;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = ColorTokens.of(context);
    final gain = currentValue - investedAmount;
    final gainPct = investedAmount > 0 ? (gain / investedAmount * 100) : 0.0;
    final gainColor = gain >= 0 ? colors.income : colors.expense;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(child: Icon(_bucketIcon(bucketType))),
        title: Text(name),
        subtitle: Text(
          '₹${formatIndianNumber(currentValue ~/ 100)} · ${gainPct >= 0 ? '+' : ''}${gainPct.toStringAsFixed(1)}%',
          style: TextStyle(color: gainColor),
        ),
        trailing: Text(
          '${(returnRate * 100).toStringAsFixed(0)}% p.a.',
          style: theme.textTheme.labelSmall,
        ),
      ),
    );
  }

  IconData _bucketIcon(String type) {
    return switch (type) {
      'mutualFunds' => Icons.auto_graph,
      'stocks' => Icons.candlestick_chart,
      'ppf' || 'epf' => Icons.savings,
      'nps' => Icons.elderly,
      'fixedDeposit' => Icons.lock_clock,
      'bonds' => Icons.receipt_long,
      'policy' => Icons.shield,
      _ => Icons.account_balance,
    };
  }
}
