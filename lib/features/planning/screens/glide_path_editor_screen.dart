import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database.dart' as db;
import '../../../core/financial/allocation_engine.dart';
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/theme/spacing.dart';
import '../providers/allocation_provider.dart';
import '../widgets/glide_path_table.dart';

/// Age band definitions matching the glide path table.
const _ageBands = [
  (start: 20, end: 30),
  (start: 30, end: 40),
  (start: 40, end: 50),
  (start: 50, end: 60),
  (start: 60, end: 70),
  (start: 70, end: 200),
];

/// Editor screen for customizing allocation targets per age band.
///
/// Shows a table of 6 age bands with editable equity/debt/gold/cash
/// percentages, row-sum validation, save and reset-to-defaults.
class GlidePathEditorScreen extends ConsumerStatefulWidget {
  const GlidePathEditorScreen({
    super.key,
    required this.lifeProfileId,
    required this.riskProfile,
    required this.userAge,
  });

  final String lifeProfileId;
  final String riskProfile;
  final int userAge;

  @override
  ConsumerState<GlidePathEditorScreen> createState() =>
      _GlidePathEditorScreenState();
}

class _GlidePathEditorScreenState extends ConsumerState<GlidePathEditorScreen> {
  final _tableKey = GlobalKey<State>();
  List<AllocationTargetOverride> _currentOverrides = [];
  bool _allRowsValid = true;

  @override
  void initState() {
    super.initState();
    _currentOverrides = _defaultOverrides();
  }

  List<AllocationTargetOverride> _defaultOverrides() {
    return _ageBands.map((band) {
      final target = AllocationEngine.targetForAge(
        age: band.start,
        riskProfile: widget.riskProfile,
      );
      return AllocationTargetOverride(
        ageBandStart: band.start,
        ageBandEnd: band.end,
        equityBp: target.equityBp,
        debtBp: target.debtBp,
        goldBp: target.goldBp,
        cashBp: target.cashBp,
      );
    }).toList();
  }

  void _onTableChanged(List<AllocationTargetOverride> overrides) {
    setState(() {
      _currentOverrides = overrides;
      _allRowsValid = overrides.every(
        (o) => o.equityBp + o.debtBp + o.goldBp + o.cashBp == 10000,
      );
    });
  }

  Future<void> _save() async {
    final dao = ref.read(allocationTargetDaoProvider);
    final uuid = const Uuid();
    final now = DateTime.now();

    final companions = _currentOverrides.map((o) {
      return db.AllocationTargetsCompanion.insert(
        id: uuid.v4(),
        lifeProfileId: widget.lifeProfileId,
        ageBandStart: o.ageBandStart,
        ageBandEnd: o.ageBandEnd,
        equityBp: o.equityBp,
        debtBp: o.debtBp,
        goldBp: o.goldBp,
        cashBp: o.cashBp,
        createdAt: now,
      );
    }).toList();

    await dao.replaceAllForProfile(widget.lifeProfileId, companions);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Targets saved')));
      Navigator.of(context).pop();
    }
  }

  void _showResetDialog() {
    final colors = ColorTokens.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Allocation Targets?'),
        content: Text(
          'This will reset all targets to ${widget.riskProfile} defaults.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep Targets'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colors.expense),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _currentOverrides = _defaultOverrides();
              });
            },
            child: const Text('Reset Targets'),
          ),
        ],
      ),
    );
  }

  IconData _profileIcon() {
    return switch (widget.riskProfile) {
      'conservative' => Icons.shield_outlined,
      'aggressive' => Icons.rocket_launch_outlined,
      _ => Icons.balance,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Load custom targets from DB to pre-fill table.
    final customAsync = ref.watch(
      customAllocationTargetsProvider(widget.lifeProfileId),
    );
    final dbTargets = customAsync.whenOrNull(
      data: (targets) => targets
          .map(
            (t) => AllocationTargetOverride(
              ageBandStart: t.ageBandStart,
              ageBandEnd: t.ageBandEnd,
              equityBp: t.equityBp,
              debtBp: t.debtBp,
              goldBp: t.goldBp,
              cashBp: t.cashBp,
            ),
          )
          .toList(),
    );

    // Use DB targets if available, otherwise defaults.
    final initialTargets = dbTargets != null && dbTargets.isNotEmpty
        ? dbTargets
        : _currentOverrides;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Allocation Targets'),
        actions: [
          TextButton(
            onPressed: _showResetDialog,
            child: const Text('Reset to Defaults'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Risk profile badge
                Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    avatar: Icon(_profileIcon(), size: 18),
                    label: Text(
                      widget.riskProfile[0].toUpperCase() +
                          widget.riskProfile.substring(1),
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.md),
                // Glide path table
                GlidePathTable(
                  key: _tableKey,
                  initialTargets: initialTargets,
                  currentUserAge: widget.userAge,
                  onChanged: _onTableChanged,
                ),
                const SizedBox(height: Spacing.lg),
                // Save button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _allRowsValid ? _save : null,
                    child: const Text('Save Targets'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
