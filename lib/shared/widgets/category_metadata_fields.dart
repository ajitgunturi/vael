import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/category_group_display.dart';

/// Renders context-sensitive metadata fields based on the selected
/// category's group and name.
///
/// All values are stored in the [metadata] map, keyed by the field's
/// JSON key (e.g. 'investmentType', 'travelMode').
class CategoryMetadataFields extends ConsumerWidget {
  const CategoryMetadataFields({
    super.key,
    required this.groupId,
    required this.categoryName,
    required this.familyId,
    required this.metadata,
    required this.onChanged,
  });

  final String groupId;
  final String categoryName;
  final String familyId;
  final Map<String, String> metadata;
  final ValueChanged<Map<String, String>> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fields = CategoryGroupDisplay.fieldsFor(groupId, categoryName);
    if (fields.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final field in fields) ...[
          const SizedBox(height: 12),
          _buildField(context, ref, field),
        ],
      ],
    );
  }

  Widget _buildField(
    BuildContext context,
    WidgetRef ref,
    MetadataFieldDef field,
  ) {
    switch (field.type) {
      case MetadataFieldType.dropdown:
        return _buildDropdown(field);
      case MetadataFieldType.text:
        return _buildTextField(field);
      case MetadataFieldType.investmentPicker:
        return _buildInvestmentPicker(context, ref, field);
      case MetadataFieldType.loanPicker:
        return _buildLoanPicker(context, ref, field);
    }
  }

  Widget _buildDropdown(MetadataFieldDef field) {
    final currentValue = metadata[field.key];
    final options = field.options ?? [];

    return InputDecorator(
      decoration: InputDecoration(
        labelText: field.label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: options.contains(currentValue) ? currentValue : null,
          isExpanded: true,
          isDense: true,
          hint: Text('Select ${field.label.toLowerCase()}'),
          items: options
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: (v) {
            final updated = Map<String, String>.from(metadata);
            if (v != null) {
              updated[field.key] = v;
            } else {
              updated.remove(field.key);
            }
            onChanged(updated);
          },
        ),
      ),
    );
  }

  Widget _buildTextField(MetadataFieldDef field) {
    return TextFormField(
      initialValue: metadata[field.key],
      decoration: InputDecoration(labelText: field.label, isDense: true),
      onChanged: (v) {
        final updated = Map<String, String>.from(metadata);
        if (v.isNotEmpty) {
          updated[field.key] = v;
        } else {
          updated.remove(field.key);
        }
        onChanged(updated);
      },
    );
  }

  Widget _buildInvestmentPicker(
    BuildContext context,
    WidgetRef ref,
    MetadataFieldDef field,
  ) {
    // TODO: upgrade to entity picker when investment providers are wired
    return _buildTextField(field);
  }

  Widget _buildLoanPicker(
    BuildContext context,
    WidgetRef ref,
    MetadataFieldDef field,
  ) {
    // TODO: upgrade to entity picker when loan providers are wired
    return _buildTextField(field);
  }
}
