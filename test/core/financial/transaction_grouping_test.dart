import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/financial/transaction_grouping.dart';

void main() {
  group('TransactionGrouping', () {
    final now = DateTime(2025, 3, 15); // Saturday

    test('groups today transactions under "Today"', () {
      final dates = [
        DateTime(2025, 3, 15, 10, 30),
        DateTime(2025, 3, 15, 14, 0),
      ];
      final groups = TransactionGrouping.groupByDate(dates, referenceDate: now);
      expect(groups.keys.first, 'Today');
      expect(groups['Today'], hasLength(2));
    });

    test('groups yesterday transactions under "Yesterday"', () {
      final dates = [DateTime(2025, 3, 14, 9, 0)];
      final groups = TransactionGrouping.groupByDate(dates, referenceDate: now);
      expect(groups.keys.first, 'Yesterday');
    });

    test('groups older dates under "dd MMM" format', () {
      final dates = [DateTime(2025, 3, 10, 12, 0), DateTime(2025, 2, 28, 8, 0)];
      final groups = TransactionGrouping.groupByDate(dates, referenceDate: now);
      expect(groups.keys, containsAll(['10 Mar', '28 Feb']));
    });

    test('preserves order within groups', () {
      final dates = [
        DateTime(2025, 3, 15, 14, 0), // today, later
        DateTime(2025, 3, 15, 10, 0), // today, earlier
      ];
      final groups = TransactionGrouping.groupByDate(dates, referenceDate: now);
      final todayGroup = groups['Today']!;
      // Input order preserved (already sorted desc from provider)
      expect(todayGroup[0], dates[0]);
      expect(todayGroup[1], dates[1]);
    });

    test('returns empty map for empty input', () {
      final groups = TransactionGrouping.groupByDate(
        <DateTime>[],
        referenceDate: now,
      );
      expect(groups, isEmpty);
    });

    test('uses current year dates without year suffix', () {
      final dates = [DateTime(2025, 1, 5)];
      final groups = TransactionGrouping.groupByDate(dates, referenceDate: now);
      expect(groups.keys.first, '05 Jan');
    });

    test('adds year suffix for previous year dates', () {
      final dates = [DateTime(2024, 12, 25)];
      final groups = TransactionGrouping.groupByDate(dates, referenceDate: now);
      expect(groups.keys.first, '25 Dec 2024');
    });
  });

  group('TransactionGrouping.filterBySearch', () {
    test('filters by description substring case-insensitively', () {
      final descriptions = ['March Salary', 'Groceries', 'Netflix'];
      final results = TransactionGrouping.matchesSearch(descriptions, 'groc');
      expect(results, ['Groceries']);
    });

    test('returns all when query is empty', () {
      final descriptions = ['A', 'B'];
      final results = TransactionGrouping.matchesSearch(descriptions, '');
      expect(results, hasLength(2));
    });
  });
}
