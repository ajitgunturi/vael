import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:vael/core/database/database.dart';

import 'simulator_test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('App Smoke Tests', () {
    testWidgets('should boot and render dashboard with navigation bar', (
      tester,
    ) async {
      await seedTestFamily(db);
      await tester.pumpWidget(SimulatorTestApp(db: db));
      await tester.pumpAndSettle();

      // Dashboard screen should render
      expect(find.text('Dashboard'), findsWidgets);

      // Bottom navigation bar should show all 5 destinations
      expect(find.text('Accounts'), findsOneWidget);
      expect(find.text('Transactions'), findsOneWidget);
      expect(find.text('Budget'), findsOneWidget);
      expect(find.text('Goals'), findsOneWidget);
    });

    testWidgets('should show net worth hero card on dashboard', (
      tester,
    ) async {
      await seedTestFamily(db);
      await tester.pumpWidget(SimulatorTestApp(db: db));
      await tester.pumpAndSettle();

      expect(find.text('Net Worth'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
    });

    testWidgets('should show zero net worth with no accounts', (
      tester,
    ) async {
      await seedTestFamily(db);
      await tester.pumpWidget(SimulatorTestApp(db: db));
      await tester.pumpAndSettle();

      // Net worth should be ₹0
      expect(find.textContaining('₹0'), findsWidgets);
    });

    testWidgets('should show quick action buttons on dashboard', (
      tester,
    ) async {
      await seedTestFamily(db);
      await tester.pumpWidget(SimulatorTestApp(db: db));
      await tester.pumpAndSettle();

      expect(find.text('Add Transaction'), findsOneWidget);
      expect(find.text('View Accounts'), findsOneWidget);
    });
  });
}
