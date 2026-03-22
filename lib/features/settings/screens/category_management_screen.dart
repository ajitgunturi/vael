import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/category_group_display.dart';
import '../../../core/providers/category_providers.dart';
import '../../../core/database/database.dart';
import 'category_form_dialog.dart';
import 'category_group_form_dialog.dart';

/// CRUD screen for managing category groups and categories.
class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key, required this.familyId});

  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(categoryGroupsProvider(familyId));
    final categoriesAsync = ref.watch(categoriesByGroupProvider(familyId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'add_group') {
                _showAddGroupDialog(context, ref);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'add_group',
                child: ListTile(
                  leading: Icon(Icons.create_new_folder_outlined),
                  title: Text('Add Group'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: groupsAsync.when(
        data: (groups) => categoriesAsync.when(
          data: (categoriesByGroup) =>
              _buildBody(context, ref, groups, categoriesByGroup),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    List<CategoryGroup> groups,
    Map<String, List<Category>> categoriesByGroup,
  ) {
    if (groups.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No category groups. Tap menu to add a group.'),
        ),
      );
    }

    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        final cats = categoriesByGroup[group.id] ?? [];

        return ExpansionTile(
          key: ValueKey(group.id),
          title: Text(
            CategoryGroupDisplay.nameOf(group.id),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          subtitle: Text(
            '${cats.length} categor${cats.length == 1 ? 'y' : 'ies'}',
          ),
          initiallyExpanded: false,
          children: [
            ...cats.map(
              (cat) => _CategoryTile(category: cat, familyId: familyId),
            ),
            if (cats.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No categories in this group',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => CategoryFormDialog(familyId: familyId),
    );
  }

  void _showAddGroupDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => CategoryGroupFormDialog(familyId: familyId),
    );
  }
}

class _CategoryTile extends ConsumerWidget {
  const _CategoryTile({required this.category, required this.familyId});

  final Category category;
  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ListTile(
      dense: true,
      leading: Icon(
        Icons.label_outline,
        size: 20,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(category.name),
      subtitle: Text(
        category.type,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: PopupMenuButton<String>(
        icon: Icon(
          Icons.more_vert,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        onSelected: (value) {
          if (value == 'edit') {
            _editCategory(context);
          } else if (value == 'delete') {
            _deleteCategory(context, ref);
          }
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'edit', child: Text('Edit')),
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    );
  }

  void _editCategory(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) =>
          CategoryFormDialog(familyId: familyId, existingCategory: category),
    );
  }

  Future<void> _deleteCategory(BuildContext context, WidgetRef ref) async {
    final dao = ref.read(categoryDaoProvider);
    final hasTransactions = await dao.hasTransactions(category.id);

    if (!context.mounted) return;

    if (hasTransactions) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '"${category.name}" is used by transactions and cannot be deleted.',
          ),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await dao.deleteCategory(category.id);
    }
  }
}
