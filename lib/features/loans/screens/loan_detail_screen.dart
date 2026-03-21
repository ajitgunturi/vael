import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/financial/amortization.dart';
import '../../../core/financial/amortization_row.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/utils/formatters.dart';
import '../providers/loan_providers.dart';

/// Displays loan summary, EMI split, amortization table, and prepayment sim.
class LoanDetailScreen extends ConsumerWidget {
  const LoanDetailScreen({
    super.key,
    required this.accountId,
    required this.familyId,
  });

  final String accountId;
  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (accountId: accountId, familyId: familyId);
    final loanAsync = ref.watch(loanViewProvider(key));

    return Scaffold(
      appBar: AppBar(title: const Text('Loan Detail')),
      body: loanAsync.when(
        data: (data) {
          if (data == null) {
            return const Center(child: Text('Loan not found'));
          }
          return _LoanDetailBody(data: data);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _LoanDetailBody extends StatelessWidget {
  const _LoanDetailBody({required this.data});

  final LoanViewData data;

  @override
  Widget build(BuildContext context) {
    final loan = data.loan;
    final enrichment = data.enrichment;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SummaryCard(loan: loan, enrichment: enrichment),
        const SizedBox(height: 16),
        _EmiSplitCard(enrichment: enrichment),
        const SizedBox(height: 16),
        _AmortizationTable(schedule: data.schedule),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.loan, required this.enrichment});

  final dynamic loan;
  final AmortizationEnrichment enrichment;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Loan Summary',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _row(
              context,
              'Principal',
              '₹${formatIndianNumber(loan.principal ~/ 100)}',
            ),
            _row(
              context,
              'Interest Rate',
              '${(loan.annualRate * 100).toStringAsFixed(1)}%',
            ),
            _row(context, 'Tenure', '${loan.tenureMonths} months'),
            _row(
              context,
              'Outstanding',
              '₹${formatIndianNumber(loan.outstandingPrincipal ~/ 100)}',
            ),
            _row(
              context,
              'EMI',
              '₹${formatIndianNumber(loan.emiAmount ~/ 100)}',
            ),
            _row(
              context,
              'Remaining Tenure',
              '${enrichment.remainingTenure} months',
            ),
            _row(
              context,
              'Interest Remaining',
              '₹${formatIndianNumber(enrichment.totalInterestRemaining ~/ 100)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _EmiSplitCard extends StatelessWidget {
  const _EmiSplitCard({required this.enrichment});

  final AmortizationEnrichment enrichment;

  @override
  Widget build(BuildContext context) {
    final totalEmi = enrichment.nextPrincipal + enrichment.nextInterest;
    final principalPercent = totalEmi > 0
        ? enrichment.nextPrincipal / totalEmi
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Next EMI Split',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: principalPercent,
                minHeight: 12,
                backgroundColor: ColorTokens.negative.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation(ColorTokens.positive),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Principal: ₹${formatIndianNumber(enrichment.nextPrincipal ~/ 100)}',
                  style: const TextStyle(color: ColorTokens.positive),
                ),
                Text(
                  'Interest: ₹${formatIndianNumber(enrichment.nextInterest ~/ 100)}',
                  style: const TextStyle(color: ColorTokens.negative),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AmortizationTable extends StatefulWidget {
  const _AmortizationTable({required this.schedule});

  final List<AmortizationRow> schedule;

  static const int pageSize = 12;

  @override
  State<_AmortizationTable> createState() => _AmortizationTableState();
}

class _AmortizationTableState extends State<_AmortizationTable> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final showAll =
        _expanded || widget.schedule.length <= _AmortizationTable.pageSize;
    final visibleRows = showAll
        ? widget.schedule
        : widget.schedule.take(_AmortizationTable.pageSize).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amortization Schedule',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                columns: const [
                  DataColumn(label: Text('#')),
                  DataColumn(label: Text('EMI'), numeric: true),
                  DataColumn(label: Text('Principal'), numeric: true),
                  DataColumn(label: Text('Interest'), numeric: true),
                  DataColumn(label: Text('Outstanding'), numeric: true),
                ],
                rows: visibleRows.map((r) {
                  return DataRow(
                    cells: [
                      DataCell(Text('${r.month}')),
                      DataCell(Text('₹${formatIndianNumber(r.emi ~/ 100)}')),
                      DataCell(
                        Text('₹${formatIndianNumber(r.principal ~/ 100)}'),
                      ),
                      DataCell(
                        Text('₹${formatIndianNumber(r.interest ~/ 100)}'),
                      ),
                      DataCell(
                        Text('₹${formatIndianNumber(r.outstanding ~/ 100)}'),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            if (!showAll)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: TextButton(
                    onPressed: () => setState(() => _expanded = true),
                    child: const Text('Show More'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
