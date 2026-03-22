import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database.dart';
import '../../../core/models/category_group_display.dart';
import '../../../core/providers/category_providers.dart';

/// Dialog for adding or editing a category.
class CategoryFormDialog extends ConsumerStatefulWidget {
  const CategoryFormDialog({
    super.key,
    required this.familyId,
    this.existingCategory,
  });

  final String familyId;
  final Category? existingCategory;

  @override
  ConsumerState<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends ConsumerState<CategoryFormDialog> {
  late final TextEditingController _nameController;
  late String _selectedGroupId;
  late String _selectedType;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingCategory?.name ?? '',
    );
    _selectedGroupId = widget.existingCategory?.groupName ?? 'ESSENTIAL';
    _selectedType = widget.existingCategory?.type ?? 'EXPENSE';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(categoryGroupsProvider(widget.familyId));
    final isEditing = widget.existingCategory != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Category' : 'Add Category'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Category Name'),
                autofocus: true,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              groupsAsync.when(
                data: (groups) => DropdownButtonFormField<String>(
                  value: groups.any((g) => g.id == _selectedGroupId)
                      ? _selectedGroupId
                      : groups.firstOrNull?.id,
                  decoration: const InputDecoration(labelText: 'Group'),
                  items: groups
                      .map(
                        (g) => DropdownMenuItem(
                          value: g.id,
                          child: Text(CategoryGroupDisplay.nameOf(g.id)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedGroupId = v);
                  },
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error loading groups: $e'),
              ),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'EXPENSE', label: Text('Expense')),
                  ButtonSegment(value: 'INCOME', label: Text('Income')),
                ],
                selected: {_selectedType},
                onSelectionChanged: (s) {
                  setState(() => _selectedType = s.first);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final dao = ref.read(categoryDaoProvider);
    final name = _nameController.text.trim();

    if (widget.existingCategory != null) {
      await dao.updateCategory(
        CategoriesCompanion(
          id: Value(widget.existingCategory!.id),
          name: Value(name),
          groupName: Value(_selectedGroupId),
          type: Value(_selectedType),
          familyId: Value(widget.familyId),
        ),
      );
    } else {
      final slug = name
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
          .replaceAll(RegExp(r'^_|_$'), '');
      await dao.insertCategory(
        CategoriesCompanion.insert(
          id: 'user_cat_${const Uuid().v4().substring(0, 8)}_$slug',
          name: name,
          groupName: _selectedGroupId,
          type: _selectedType,
          familyId: widget.familyId,
        ),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }
}
