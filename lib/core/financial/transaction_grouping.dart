import 'package:intl/intl.dart';

/// Pure-logic utilities for grouping and filtering transactions by date.
///
/// All methods are static and take plain Dart types so they can be unit-tested
/// without Flutter widget infrastructure.
class TransactionGrouping {
  TransactionGrouping._();

  /// Groups [dates] into an ordered map keyed by display label:
  /// "Today", "Yesterday", "dd MMM", or "dd MMM yyyy" (previous years).
  ///
  /// Input order is preserved within each group (caller is responsible for
  /// pre-sorting — typically date-descending from the provider).
  static Map<String, List<DateTime>> groupByDate(
    List<DateTime> dates, {
    required DateTime referenceDate,
  }) {
    final result = <String, List<DateTime>>{};
    final todayDate = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    );
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));
    final sameYearFmt = DateFormat('dd MMM');
    final otherYearFmt = DateFormat('dd MMM yyyy');

    for (final dt in dates) {
      final dateOnly = DateTime(dt.year, dt.month, dt.day);
      final String label;

      if (dateOnly == todayDate) {
        label = 'Today';
      } else if (dateOnly == yesterdayDate) {
        label = 'Yesterday';
      } else if (dt.year == referenceDate.year) {
        label = sameYearFmt.format(dt);
      } else {
        label = otherYearFmt.format(dt);
      }

      (result[label] ??= []).add(dt);
    }

    return result;
  }

  /// Filters [descriptions] by case-insensitive substring match on [query].
  /// Returns all items when [query] is empty.
  static List<String> matchesSearch(List<String> descriptions, String query) {
    if (query.isEmpty) return descriptions;
    final lower = query.toLowerCase();
    return descriptions.where((d) => d.toLowerCase().contains(lower)).toList();
  }
}
