import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/financial/statement_parser.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/utils/formatters.dart';

/// Statement import flow: paste CSV → preview → review → commit.
class StatementImportScreen extends ConsumerStatefulWidget {
  const StatementImportScreen({super.key, required this.familyId});

  final String familyId;

  @override
  ConsumerState<StatementImportScreen> createState() =>
      _StatementImportScreenState();
}

class _StatementImportScreenState extends ConsumerState<StatementImportScreen> {
  final _csvController = TextEditingController();
  ParseResult? _parseResult;
  final Set<int> _selectedIndices = {};

  @override
  void dispose() {
    _csvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Statement')),
      body: _parseResult == null ? _buildInputStep() : _buildReviewStep(),
    );
  }

  Widget _buildInputStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Paste your bank statement CSV below',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Supported: HDFC, SBI, ICICI, or generic CSV',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: _csvController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Date,Narration,Value Dat,...',
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _preview,
            icon: const Icon(Icons.preview),
            label: const Text('Preview'),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    final result = _parseResult!;
    final txns = result.transactions;

    return Column(
      children: [
        _ImportSummaryBar(
          format: result.format,
          total: txns.length,
          selected: _selectedIndices.length,
          skipped: result.skippedRows,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: txns.length,
            itemBuilder: (context, i) {
              final tx = txns[i];
              final selected = _selectedIndices.contains(i);

              return CheckboxListTile(
                value: selected,
                onChanged: (v) {
                  setState(() {
                    if (v == true) {
                      _selectedIndices.add(i);
                    } else {
                      _selectedIndices.remove(i);
                    }
                  });
                },
                title: Text(tx.description),
                subtitle: Text(
                  '${tx.date.day}/${tx.date.month}/${tx.date.year} · ${tx.inferredCategory ?? 'Uncategorized'}',
                ),
                secondary: Builder(
                  builder: (ctx) {
                    final colors = ColorTokens.of(ctx);
                    return Text(
                      '${tx.isDebit ? '-' : '+'}₹${formatIndianNumber(tx.amount ~/ 100)}',
                      style: TextStyle(
                        color: tx.isDebit ? colors.expense : colors.income,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              OutlinedButton(
                onPressed: () => setState(() => _parseResult = null),
                child: const Text('Back'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _selectedIndices.isNotEmpty ? _commit : null,
                  icon: const Icon(Icons.check),
                  label: Text('Import ${_selectedIndices.length} transactions'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _preview() {
    final csv = _csvController.text.trim();
    if (csv.isEmpty) return;

    final result = StatementParser.parse(csv);
    setState(() {
      _parseResult = result;
      // Select all by default
      _selectedIndices.addAll(
        List.generate(result.transactions.length, (i) => i),
      );
    });
  }

  void _commit() {
    // Will be wired to DAO in integration
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Imported ${_selectedIndices.length} transactions'),
      ),
    );
    Navigator.of(context).pop();
  }
}

class _ImportSummaryBar extends StatelessWidget {
  const _ImportSummaryBar({
    required this.format,
    required this.total,
    required this.selected,
    required this.skipped,
  });

  final BankFormat format;
  final int total;
  final int selected;
  final int skipped;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatName = switch (format) {
      BankFormat.hdfc => 'HDFC',
      BankFormat.sbi => 'SBI',
      BankFormat.icici => 'ICICI',
      BankFormat.generic => 'Generic CSV',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Icon(
            Icons.description,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            '$formatName · $total parsed',
            style: theme.textTheme.labelLarge,
          ),
          if (skipped > 0) ...[
            const SizedBox(width: 8),
            Text(
              '· $skipped skipped',
              style: theme.textTheme.labelSmall?.copyWith(
                color: ColorTokens.of(context).expense,
              ),
            ),
          ],
          const Spacer(),
          Text('$selected selected', style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}
