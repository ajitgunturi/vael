import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/financial/allocation_engine.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/theme/spacing.dart';

/// Age band definition for the glide path table.
class _AgeBand {
  final int start;
  final int end;
  final String label;

  const _AgeBand(this.start, this.end, this.label);
}

const _ageBands = [
  _AgeBand(20, 30, '20-30'),
  _AgeBand(30, 40, '30-40'),
  _AgeBand(40, 50, '40-50'),
  _AgeBand(50, 60, '50-60'),
  _AgeBand(60, 70, '60-70'),
  _AgeBand(70, 200, '70+'),
];

/// Editable DataTable for allocation targets across 6 age bands.
///
/// Each row has Equity, Debt, Gold, Cash columns with inline editing.
/// Row sum must equal 100 (displayed as percentage). The current user's
/// age band row is highlighted with primaryContainer background.
class GlidePathTable extends StatefulWidget {
  const GlidePathTable({
    super.key,
    required this.initialTargets,
    required this.currentUserAge,
    required this.onChanged,
  });

  /// Initial targets as overrides. May be empty (uses engine defaults).
  final List<AllocationTargetOverride> initialTargets;

  /// User's current age, used to highlight the active age band row.
  final int currentUserAge;

  /// Called whenever any cell value changes, with the full updated list.
  final ValueChanged<List<AllocationTargetOverride>> onChanged;

  @override
  State<GlidePathTable> createState() => _GlidePathTableState();
}

class _GlidePathTableState extends State<GlidePathTable> {
  // Stored as integer percentages (0-100) per band.
  late List<List<int>> _rows; // [bandIndex][0=equity,1=debt,2=gold,3=cash]
  int _editingRow = -1;
  int _editingCol = -1;
  final _editController = TextEditingController();
  final _editFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initRows();
    _editFocusNode.addListener(_onFocusChanged);
  }

  void _initRows() {
    _rows = List.generate(_ageBands.length, (i) {
      final band = _ageBands[i];
      // Check if we have a custom target for this band.
      final custom = widget.initialTargets.where(
        (t) => t.ageBandStart == band.start && t.ageBandEnd == band.end,
      );
      if (custom.isNotEmpty) {
        final t = custom.first;
        return [
          (t.equityBp / 100).round(),
          (t.debtBp / 100).round(),
          (t.goldBp / 100).round(),
          (t.cashBp / 100).round(),
        ];
      }
      return [0, 0, 0, 0]; // Will be filled by caller with defaults.
    });
  }

  /// Resets all rows to the given overrides.
  void resetTo(List<AllocationTargetOverride> targets) {
    setState(() {
      for (int i = 0; i < _ageBands.length; i++) {
        final band = _ageBands[i];
        final match = targets.where(
          (t) => t.ageBandStart == band.start && t.ageBandEnd == band.end,
        );
        if (match.isNotEmpty) {
          final t = match.first;
          _rows[i] = [
            (t.equityBp / 100).round(),
            (t.debtBp / 100).round(),
            (t.goldBp / 100).round(),
            (t.cashBp / 100).round(),
          ];
        }
      }
      _editingRow = -1;
      _editingCol = -1;
    });
    _emitChanged();
  }

  void _onFocusChanged() {
    if (!_editFocusNode.hasFocus && _editingRow >= 0) {
      _commitEdit();
    }
  }

  @override
  void dispose() {
    _editFocusNode.removeListener(_onFocusChanged);
    _editFocusNode.dispose();
    _editController.dispose();
    super.dispose();
  }

  void _startEdit(int row, int col) {
    setState(() {
      _editingRow = row;
      _editingCol = col;
      _editController.text = _rows[row][col].toString();
    });
    // Request focus after rebuild.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _editFocusNode.requestFocus();
      _editController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _editController.text.length,
      );
    });
  }

  void _commitEdit() {
    if (_editingRow < 0 || _editingCol < 0) return;
    final parsed = int.tryParse(_editController.text);
    if (parsed != null && parsed >= 0 && parsed <= 100) {
      setState(() {
        _rows[_editingRow][_editingCol] = parsed;
      });
    }
    setState(() {
      _editingRow = -1;
      _editingCol = -1;
    });
    _emitChanged();
  }

  void _emitChanged() {
    final overrides = <AllocationTargetOverride>[];
    for (int i = 0; i < _ageBands.length; i++) {
      final band = _ageBands[i];
      overrides.add(
        AllocationTargetOverride(
          ageBandStart: band.start,
          ageBandEnd: band.end,
          equityBp: _rows[i][0] * 100,
          debtBp: _rows[i][1] * 100,
          goldBp: _rows[i][2] * 100,
          cashBp: _rows[i][3] * 100,
        ),
      );
    }
    widget.onChanged(overrides);
  }

  int _rowSum(int row) => _rows[row].fold(0, (a, b) => a + b);

  bool _isCurrentBand(int row) {
    final band = _ageBands[row];
    return widget.currentUserAge >= band.start &&
        widget.currentUserAge < band.end;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = ColorTokens.of(context);
    const colLabels = ['Equity', 'Debt', 'Gold', 'Cash'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: Spacing.md,
        headingRowHeight: 40,
        dataRowMinHeight: 44,
        dataRowMaxHeight: 56,
        columns: [
          const DataColumn(label: Text('Age Band')),
          for (final label in colLabels) DataColumn(label: Text(label)),
          const DataColumn(label: Text('Sum')),
        ],
        rows: List.generate(_ageBands.length, (rowIndex) {
          final band = _ageBands[rowIndex];
          final isCurrent = _isCurrentBand(rowIndex);
          final sum = _rowSum(rowIndex);
          final isValid = sum == 100;

          return DataRow(
            color: isCurrent
                ? WidgetStateProperty.all(colors.primaryContainer)
                : null,
            cells: [
              DataCell(Text(band.label, style: theme.textTheme.titleMedium)),
              for (int col = 0; col < 4; col++)
                DataCell(
                  _editingRow == rowIndex && _editingCol == col
                      ? SizedBox(
                          width: 56,
                          child: TextFormField(
                            controller: _editController,
                            focusNode: _editFocusNode,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 8,
                              ),
                            ),
                            onFieldSubmitted: (_) => _commitEdit(),
                          ),
                        )
                      : Semantics(
                          label:
                              'Age ${band.label}, ${colLabels[col]}: ${_rows[rowIndex][col]}%. Tap to edit.',
                          child: Text(
                            '${_rows[rowIndex][col]}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                  onTap: () => _startEdit(rowIndex, col),
                ),
              DataCell(
                Text(
                  '$sum%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isValid ? colors.income : colors.expense,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
