import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';
import '../../core/models/category_group_display.dart';
import '../../core/providers/category_providers.dart';

/// Bottom sheet picker for selecting a category.
///
/// Categories are grouped by their group name and displayed as
/// collapsible sections. A search bar filters by category name.
/// Returns the selected [Category] via `Navigator.pop`.
class CategoryPicker extends ConsumerStatefulWidget {
  const CategoryPicker({
    super.key,
    required this.familyId,
    this.filterType,
    this.selectedCategoryId,
  });

  final String familyId;

  /// Filter to 'INCOME' or 'EXPENSE' categories only.
  final String? filterType;

  /// Currently selected category ID (highlighted in the list).
  final String? selectedCategoryId;

  /// Shows the picker as a modal bottom sheet and returns the selected category.
  static Future<Category?> show(
    BuildContext context, {
    required String familyId,
    String? filterType,
    String? selectedCategoryId,
  }) {
    return showModalBottomSheet<Category>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => CategoryPicker(
          familyId: familyId,
          filterType: filterType,
          selectedCategoryId: selectedCategoryId,
        ),
      ),
    );
  }

  @override
  ConsumerState<CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends ConsumerState<CategoryPicker> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupsAsync = ref.watch(categoryGroupsProvider(widget.familyId));
    final categoriesAsync = ref.watch(
      categoriesByGroupProvider(widget.familyId),
    );

    return Column(
      children: [
        // Handle
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withAlpha(80),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Select Category', style: theme.textTheme.titleMedium),
        ),
        const SizedBox(height: 8),
        // Search
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search categories...',
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (v) => setState(() => _search = v.toLowerCase()),
          ),
        ),
        const SizedBox(height: 8),
        // Clear selection option
        ListTile(
          dense: true,
          leading: Icon(Icons.clear, color: theme.colorScheme.onSurfaceVariant),
          title: const Text('No Category'),
          selected: widget.selectedCategoryId == null,
          onTap: () => Navigator.of(context).pop(null),
        ),
        const Divider(height: 1),
        // Category list
        Expanded(
          child: categoriesAsync.when(
            data: (categoriesByGroup) {
              return groupsAsync.when(
                data: (groups) =>
                    _buildGroupedList(groups, categoriesByGroup, theme),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupedList(
    List<CategoryGroup> groups,
    Map<String, List<Category>> categoriesByGroup,
    ThemeData theme,
  ) {
    // Filter groups that have matching categories
    final filteredGroups = <CategoryGroup>[];
    final filteredCats = <String, List<Category>>{};

    for (final group in groups) {
      final cats = categoriesByGroup[group.id] ?? [];
      final matching = cats.where((c) {
        if (widget.filterType != null && c.type != widget.filterType) {
          return false;
        }
        if (_search.isNotEmpty && !c.name.toLowerCase().contains(_search)) {
          return false;
        }
        return true;
      }).toList();

      if (matching.isNotEmpty) {
        filteredGroups.add(group);
        filteredCats[group.id] = matching;
      }
    }

    if (filteredGroups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            _search.isNotEmpty
                ? 'No categories match "$_search"'
                : 'No categories available',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredGroups.length,
      itemBuilder: (context, index) {
        final group = filteredGroups[index];
        final cats = filteredCats[group.id]!;

        return ExpansionTile(
          title: Text(
            CategoryGroupDisplay.nameOf(group.id),
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          subtitle: Text(
            '${cats.length} categor${cats.length == 1 ? 'y' : 'ies'}',
            style: theme.textTheme.bodySmall,
          ),
          initiallyExpanded: _search.isNotEmpty || filteredGroups.length <= 3,
          children: cats.map((cat) {
            final isSelected = cat.id == widget.selectedCategoryId;
            return ListTile(
              dense: true,
              leading: Icon(
                Icons.label_outline,
                size: 20,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              title: Text(
                cat.name,
                style: isSelected
                    ? TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      )
                    : null,
              ),
              trailing: isSelected
                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                  : null,
              onTap: () => Navigator.of(context).pop(cat),
            );
          }).toList(),
        );
      },
    );
  }
}
