import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/providers/category_providers.dart';

/// Dialog for adding a new category group.
class CategoryGroupFormDialog extends ConsumerStatefulWidget {
  const CategoryGroupFormDialog({super.key, required this.familyId});

  final String familyId;

  @override
  ConsumerState<CategoryGroupFormDialog> createState() =>
      _CategoryGroupFormDialogState();
}

class _CategoryGroupFormDialogState
    extends ConsumerState<CategoryGroupFormDialog> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Group'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Group Name',
            hintText: 'e.g. Pet Expenses',
          ),
          autofocus: true,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Name is required';
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Add')),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final id = name.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]+'), '_');

    final dao = ref.read(categoryGroupDaoProvider);

    // Get current max display order
    final groups = await dao.getAll(widget.familyId);
    final maxOrder = groups.isEmpty
        ? 0
        : groups.map((g) => g.displayOrder).reduce((a, b) => a > b ? a : b) + 1;

    await dao.insertGroup(
      CategoryGroupsCompanion(
        id: Value(id),
        name: Value(name),
        displayOrder: Value(maxOrder),
        familyId: Value(widget.familyId),
      ),
    );

    if (mounted) Navigator.of(context).pop();
  }
}
