/// Maps legacy category names to their canonical group identifiers.
///
/// Used as a fallback when a transaction's category group is missing
/// or set to 'MISSING'. See `docs/INTENT.md` for group definitions.
class CategoryGroupMapper {
  CategoryGroupMapper._();

  static const _legacyMap = {
    'Food': 'ESSENTIAL',
    'Groceries': 'ESSENTIAL',
    'Rent': 'ESSENTIAL',
    'Utilities': 'ESSENTIAL',
    'Transport': 'ESSENTIAL',
    'Entertainment': 'NON_ESSENTIAL',
    'Shopping': 'NON_ESSENTIAL',
    'Dining': 'NON_ESSENTIAL',
    'Travel': 'NON_ESSENTIAL',
    'EMI': 'HOME_EXPENSES',
    'Maintenance': 'HOME_EXPENSES',
    'SIP': 'INVESTMENTS',
    'Insurance': 'INVESTMENTS',
    'Mutual Funds': 'INVESTMENTS',
  };

  /// Resolves a category group name, falling back to the legacy map
  /// when [groupName] is null, empty, or 'MISSING'.
  static String resolve(String? groupName, String? categoryName) {
    if (groupName != null && groupName.isNotEmpty && groupName != 'MISSING') {
      return groupName;
    }
    if (categoryName != null) {
      return _legacyMap[categoryName] ?? 'MISSING';
    }
    return 'MISSING';
  }
}
