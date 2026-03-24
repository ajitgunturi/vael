import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/daos/account_dao.dart';
import '../../../core/providers/database_providers.dart';
import '../../../shared/theme/spacing.dart';
import '../providers/cash_flow_providers.dart';

/// Bottom sheet for configuring per-account minimum balance thresholds.
///
/// Accessible from the cash flow screen's tune icon. Users enter threshold
/// values in rupees (converted to/from paise for storage).
class ThresholdConfigSheet extends ConsumerStatefulWidget {
  const ThresholdConfigSheet({super.key, required this.familyId});

  final String familyId;

  @override
  ConsumerState<ThresholdConfigSheet> createState() =>
      _ThresholdConfigSheetState();
}

class _ThresholdConfigSheetState extends ConsumerState<ThresholdConfigSheet> {
  Map<String, int>? _thresholds;
  Map<String, TextEditingController> _controllers = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadThresholds();
  }

  Future<void> _loadThresholds() async {
    final db = ref.read(databaseProvider);
    final accountDao = AccountDao(db);
    final thresholds = await accountDao.getThresholds(widget.familyId);
    if (mounted) {
      setState(() {
        _thresholds = thresholds;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String accountId) {
    if (!_controllers.containsKey(accountId)) {
      final paise = _thresholds?[accountId];
      final text = paise != null ? (paise ~/ 100).toString() : '';
      _controllers[accountId] = TextEditingController(text: text);
    }
    return _controllers[accountId]!;
  }

  Future<void> _save(String accountId, String value) async {
    final db = ref.read(databaseProvider);
    final accountDao = AccountDao(db);
    final trimmed = value.trim();
    final rupees = trimmed.isEmpty ? null : int.tryParse(trimmed);
    final paise = rupees != null ? rupees * 100 : null;
    await accountDao.setMinimumBalance(accountId, paise);
    if (mounted) {
      setState(() {
        if (paise != null) {
          _thresholds?[accountId] = paise;
        } else {
          _thresholds?.remove(accountId);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accountNamesAsync = ref.watch(accountNamesProvider(widget.familyId));

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: Spacing.md,
        right: Spacing.md,
        top: Spacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Minimum Balance Thresholds',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'Set minimum balance alerts per account',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: Spacing.md),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            accountNamesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (names) => _buildAccountList(names),
            ),
          const SizedBox(height: Spacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ),
          const SizedBox(height: Spacing.md),
        ],
      ),
    );
  }

  Widget _buildAccountList(Map<String, String> names) {
    if (names.isEmpty) {
      return const Text('No accounts configured');
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: names.length,
      separatorBuilder: (_, __) => const SizedBox(height: Spacing.sm),
      itemBuilder: (context, index) {
        final accountId = names.keys.elementAt(index);
        final accountName = names[accountId]!;
        final controller = _controllerFor(accountId);
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(accountName),
                  Text(
                    _thresholds?.containsKey(accountId) == true
                        ? 'Rs ${(_thresholds![accountId]! ~/ 100)}'
                        : 'Not set',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixText: 'Rs ',
                  hintText: '0',
                  isDense: true,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () => _save(accountId, controller.text),
            ),
          ],
        );
      },
    );
  }
}
