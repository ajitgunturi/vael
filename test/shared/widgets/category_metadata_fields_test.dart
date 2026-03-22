import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/shared/widgets/category_metadata_fields.dart';

void main() {
  Widget buildTestWidget({
    required String groupId,
    required String categoryName,
    Map<String, String> metadata = const {},
    ValueChanged<Map<String, String>>? onChanged,
  }) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CategoryMetadataFields(
              groupId: groupId,
              categoryName: categoryName,
              familyId: 'fam_test',
              metadata: metadata,
              onChanged: onChanged ?? (_) {},
            ),
          ),
        ),
      ),
    );
  }

  group('CategoryMetadataFields', () {
    testWidgets('shows investment type dropdown for INVESTMENTS group', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          groupId: 'INVESTMENTS',
          categoryName: 'SIP/Mutual Funds',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Investment Type'), findsOneWidget);
      expect(find.text('Provider'), findsOneWidget);
    });

    testWidgets('shows travel mode dropdown for Travel category', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          groupId: 'LUXURY_NON_ESSENTIAL',
          categoryName: 'Travel',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Travel Mode'), findsOneWidget);
    });

    testWidgets('shows movie name field for Movies category', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          groupId: 'LUXURY_NON_ESSENTIAL',
          categoryName: 'Movies & Entertainment',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Movie Name'), findsOneWidget);
      // Travel Mode should NOT appear (wrong category)
      expect(find.text('Travel Mode'), findsNothing);
    });

    testWidgets('shows medical fields for Medical Consultation category', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          groupId: 'ESSENTIAL',
          categoryName: 'Medical Consultation',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Medical Expense Type'), findsOneWidget);
      expect(find.text('Patient'), findsOneWidget);
    });

    testWidgets('shows nothing for group with no metadata fields', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(groupId: 'PHILANTHROPY', categoryName: 'Charity'),
      );
      await tester.pumpAndSettle();

      // Should render no metadata fields
      expect(find.byType(TextFormField), findsNothing);
      expect(find.byType(DropdownButton), findsNothing);
    });

    testWidgets('shows utility bill type for Utility Bills category', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          groupId: 'LIVING_EXPENSE',
          categoryName: 'Utility Bills',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Utility Bill Type'), findsOneWidget);
    });

    testWidgets('does not show utility bill type for Groceries category', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(groupId: 'LIVING_EXPENSE', categoryName: 'Groceries'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Utility Bill Type'), findsNothing);
      expect(find.text('Platform'), findsOneWidget);
    });
  });
}
