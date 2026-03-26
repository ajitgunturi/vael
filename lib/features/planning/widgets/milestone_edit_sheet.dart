import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database.dart' show NetWorthMilestonesCompanion;
import '../../../shared/theme/color_tokens.dart';
import '../../../shared/theme/spacing.dart';
import '../providers/milestone_provider.dart';

/// Bottom sheet for editing a milestone's custom target amount.
class MilestoneEditSheet extends ConsumerStatefulWidget {
  const MilestoneEditSheet({
    super.key,
    required this.age,
    required this.currentProjectionPaise,
    required this.currentTargetPaise,
    required this.userId,
    required this.familyId,
    required this.lifeProfileId,
    this.milestoneId,
  });

  final int age;
  final int currentProjectionPaise;
  final int currentTargetPaise;
  final String userId;
  final String familyId;
  final String lifeProfileId;
  final String? milestoneId;

  @override
  ConsumerState<MilestoneEditSheet> createState() => _MilestoneEditSheetState();
}

class _MilestoneEditSheetState extends ConsumerState<MilestoneEditSheet> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    // Pre-fill with current target in rupees.
    final rupees = widget.currentTargetPaise ~/ 100;
    _controller = TextEditingController(text: rupees.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _useProjectedAmount() {
    final rupees = widget.currentProjectionPaise ~/ 100;
    _controller.text = rupees.toString();
    setState(() => _errorText = null);
  }

  Future<void> _save() async {
    final parsed = int.tryParse(_controller.text);
    if (parsed == null || parsed <= 0) {
      setState(() => _errorText = 'Enter a valid amount');
      return;
    }

    final dao = ref.read(netWorthMilestoneDaoProvider);
    final now = DateTime.now();
    final id = widget.milestoneId ?? const Uuid().v4();

    await dao.upsertMilestone(
      NetWorthMilestonesCompanion(
        id: Value(id),
        userId: Value(widget.userId),
        familyId: Value(widget.familyId),
        lifeProfileId: Value(widget.lifeProfileId),
        targetAge: Value(widget.age),
        targetAmountPaise: Value(parsed * 100),
        isCustomTarget: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = ColorTokens.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: Spacing.md,
        right: Spacing.md,
        top: Spacing.md,
        bottom: MediaQuery.viewInsetsOf(context).bottom + Spacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: Spacing.lg),

          // Title
          Text(
            'Set Target for Age ${widget.age}',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: Spacing.sm),

          // Hint
          Text(
            'Current projection: ${_formatCompact(widget.currentProjectionPaise)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.lg),

          // Amount input
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              prefixText: 'Rs ',
              labelText: 'Target amount (rupees)',
              errorText: _errorText,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: Spacing.sm),

          // Use projected amount
          TextButton(
            onPressed: _useProjectedAmount,
            child: const Text('Use projected amount'),
          ),
          const SizedBox(height: Spacing.md),

          // Save button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              child: const Text('Save Target'),
            ),
          ),
          const SizedBox(height: Spacing.md),
        ],
      ),
    );
  }

  String _formatCompact(int paise) {
    final rupees = paise.abs() / 100;
    if (rupees >= 10000000) {
      final cr = rupees / 10000000;
      return 'Rs ${cr >= 10 ? cr.toStringAsFixed(1) : cr.toStringAsFixed(2)} Cr';
    } else if (rupees >= 100000) {
      final l = rupees / 100000;
      return 'Rs ${l >= 10 ? l.toStringAsFixed(1) : l.toStringAsFixed(2)} L';
    }
    return 'Rs ${rupees.toStringAsFixed(0)}';
  }
}
