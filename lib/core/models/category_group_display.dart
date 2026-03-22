/// Display names and metadata field schemas for category groups.
///
/// Group IDs are DB-stored strings (e.g. 'HOME_EXPENSES'). This file
/// provides human-readable names and defines which context-sensitive
/// metadata fields each group supports on the transaction form.
class CategoryGroupDisplay {
  CategoryGroupDisplay._();

  /// Maps group ID → human-readable display name.
  static const displayNames = <String, String>{
    'ASSETS': 'Assets',
    'LIABILITIES': 'Liabilities',
    'HOME_EXPENSES': 'Home Expenses',
    'LIVING_EXPENSE': 'Living Expense',
    'ESSENTIAL': 'Essential',
    'LUXURY_ESSENTIAL': 'Luxury Essential',
    'LUXURY_NON_ESSENTIAL': 'Luxury Non-Essential',
    'PHILANTHROPY': 'Philanthropy',
    'SELF_IMPROVEMENT': 'Self-Improvement',
    'INVESTMENTS': 'Investments',
    'NON_ESSENTIAL': 'Non-Essential',
    'MISSING': 'Uncategorized',
  };

  /// Returns display name for a group ID, falling back to the ID itself
  /// for user-created groups.
  static String nameOf(String groupId) =>
      displayNames[groupId] ?? groupId.replaceAll('_', ' ');

  /// Metadata field definitions keyed by group ID.
  ///
  /// Each field has a [key] (stored in transaction metadata JSON),
  /// a [label] for the form, a [type] ('dropdown', 'text', 'entity'),
  /// and optional [options] for dropdowns.
  static const metadataFields = <String, List<MetadataFieldDef>>{
    'INVESTMENTS': [
      MetadataFieldDef(
        key: 'investmentType',
        label: 'Investment Type',
        type: MetadataFieldType.dropdown,
        options: [
          'Mutual Funds',
          'Stocks',
          'Fixed Deposit',
          'PPF',
          'NPS',
          'Policies',
          'Digital Gold',
          'EPF',
        ],
      ),
      MetadataFieldDef(
        key: 'provider',
        label: 'Provider',
        type: MetadataFieldType.text,
      ),
      MetadataFieldDef(
        key: 'linkedHoldingId',
        label: 'Linked Investment',
        type: MetadataFieldType.investmentPicker,
      ),
    ],
    'ASSETS': [
      MetadataFieldDef(
        key: 'investmentType',
        label: 'Asset Type',
        type: MetadataFieldType.dropdown,
        options: [
          'Savings',
          'Fixed Deposit',
          'Mutual Funds',
          'Stocks',
          'Gold',
          'Real Estate',
          'PPF',
          'NPS',
          'EPF',
        ],
      ),
    ],
    'LIABILITIES': [
      MetadataFieldDef(
        key: 'linkedLoanId',
        label: 'Linked Loan',
        type: MetadataFieldType.loanPicker,
      ),
    ],
    'ESSENTIAL': [
      MetadataFieldDef(
        key: 'medicalExpenseType',
        label: 'Medical Expense Type',
        type: MetadataFieldType.dropdown,
        options: ['Diagnostics and Tests', 'Medicines', 'Medical Program'],
        applicableCategories: ['Medical Consultation', 'Medicines'],
      ),
      MetadataFieldDef(
        key: 'patient',
        label: 'Patient',
        type: MetadataFieldType.text,
        applicableCategories: [
          'Medical Consultation',
          'Medicines',
          'Medical Test',
        ],
      ),
    ],
    'LIVING_EXPENSE': [
      MetadataFieldDef(
        key: 'utilityBillType',
        label: 'Utility Bill Type',
        type: MetadataFieldType.dropdown,
        options: ['Internet', 'Phone', 'Car Wash', 'DTH/Cable'],
        applicableCategories: ['Utility Bills'],
      ),
      MetadataFieldDef(
        key: 'quickCommercePlatform',
        label: 'Platform',
        type: MetadataFieldType.text,
        applicableCategories: ['Groceries', 'Snacks', 'Beverages'],
      ),
    ],
    'LUXURY_ESSENTIAL': [
      MetadataFieldDef(
        key: 'vehicle',
        label: 'Vehicle',
        type: MetadataFieldType.text,
        applicableCategories: ['Vehicle Fuel', 'Vehicle Service'],
      ),
      MetadataFieldDef(
        key: 'provider',
        label: 'Provider',
        type: MetadataFieldType.text,
        applicableCategories: ['Subscriptions'],
      ),
    ],
    'LUXURY_NON_ESSENTIAL': [
      MetadataFieldDef(
        key: 'travelMode',
        label: 'Travel Mode',
        type: MetadataFieldType.dropdown,
        options: ['Flight', 'Train', 'Cab', 'Hotel', 'Resort', 'Bus'],
        applicableCategories: ['Travel'],
      ),
      MetadataFieldDef(
        key: 'movieName',
        label: 'Movie Name',
        type: MetadataFieldType.text,
        applicableCategories: ['Movies & Entertainment'],
      ),
    ],
    'HOME_EXPENSES': [
      MetadataFieldDef(
        key: 'maintenanceType',
        label: 'Maintenance Type',
        type: MetadataFieldType.dropdown,
        options: ['Home', 'Society'],
        applicableCategories: ['Home Maintenance', 'Society Maintenance'],
      ),
    ],
  };

  /// Returns applicable metadata fields for a given [groupId] and
  /// optional [categoryName]. Fields with [applicableCategories] are
  /// only returned if the category name matches.
  static List<MetadataFieldDef> fieldsFor(
    String groupId, [
    String? categoryName,
  ]) {
    final allFields = metadataFields[groupId];
    if (allFields == null) return const [];
    if (categoryName == null) return allFields;
    return allFields
        .where(
          (f) =>
              f.applicableCategories == null ||
              f.applicableCategories!.contains(categoryName),
        )
        .toList();
  }
}

/// Type of input for a metadata field on the transaction form.
enum MetadataFieldType { dropdown, text, investmentPicker, loanPicker }

/// Defines a context-sensitive metadata field for the transaction form.
class MetadataFieldDef {
  const MetadataFieldDef({
    required this.key,
    required this.label,
    required this.type,
    this.options,
    this.applicableCategories,
  });

  /// JSON key stored in transaction metadata.
  final String key;

  /// Human-readable label for the form field.
  final String label;

  /// Input type.
  final MetadataFieldType type;

  /// Dropdown options (only for [MetadataFieldType.dropdown]).
  final List<String>? options;

  /// If non-null, this field only appears when the selected category
  /// name is in this list. If null, the field appears for all
  /// categories in the group.
  final List<String>? applicableCategories;
}
