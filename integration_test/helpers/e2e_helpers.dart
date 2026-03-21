import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';

import 'package:vael/core/database/database.dart';
import 'package:vael/core/financial/balance_rules.dart';
import 'package:vael/shared/utils/formatters.dart';

export '../simulator_test_app.dart' show seedTestFamily, kTestFamilyId, kTestUserId, SimulatorTestApp;

/// Hard ceiling for any single E2E test. Prevents CI from hanging
/// if a provider never emits or an animation loop is unbreakable.
const kTestTimeout = Timeout(Duration(seconds: 30));

/// Pumps frames for [duration] then tries to settle with a short timeout.
/// Unlike raw `pumpAndSettle`, this won't hang on infinite animations
/// (CircularProgressIndicator, shimmer, etc.) — it gives async providers
/// time to resolve, then pumps remaining frames with a bounded settle.
Future<void> settle(WidgetTester tester, [Duration duration = const Duration(milliseconds: 500)]) async {
  await tester.pump(duration);
  // Try a short settle — if animations are still running this will
  // timeout quickly rather than hanging for minutes.
  try {
    await tester.pumpAndSettle(const Duration(milliseconds: 100), EnginePhase.sendSemanticsUpdate, const Duration(seconds: 5));
  } catch (_) {
    // Settle timed out (infinite animation present) — one final pump.
    await tester.pump();
  }
}

/// Navigate to a tab by tapping its label. Works on both BottomNavigationBar
/// (phone) and NavigationRail (tablet/iPad).
///
/// Uses `.first` to prefer the navigation element over any AppBar title match.
Future<void> navigateToTab(WidgetTester tester, String label) async {
  final finder = find.text(label);
  await tester.tap(finder.first);
  await settle(tester);
}

/// Asserts that the formatted amount for [paise] appears in the widget tree.
void expectFormattedAmount(int paise, {Matcher? matcher}) {
  final rupees = paise.abs() ~/ 100;
  final formatted = formatIndianNumber(rupees);
  expect(find.textContaining(formatted), matcher ?? findsWidgets);
}

/// Seed an account row.
Future<void> seedAccount(
  AppDatabase db, {
  required String id,
  required String name,
  required String type,
  required int balance,
  String visibility = 'shared',
  String? userId,
  String? familyId,
}) async {
  final fid = familyId ?? 'sim_family';
  final uid = userId ?? 'user_sim_family';
  await db.into(db.accounts).insert(AccountsCompanion(
    id: Value(id),
    name: Value(name),
    type: Value(type),
    balance: Value(balance),
    visibility: Value(visibility),
    familyId: Value(fid),
    userId: Value(uid),
  ));
}

/// Seed a transaction AND apply the balance cascade atomically.
Future<void> seedTransaction(
  AppDatabase db, {
  required String id,
  required int amount,
  required DateTime date,
  required String kind,
  required String accountId,
  String? toAccountId,
  String? description,
  String? categoryId,
  String? familyId,
}) async {
  final fid = familyId ?? 'sim_family';
  await db.into(db.transactions).insert(TransactionsCompanion(
    id: Value(id),
    amount: Value(amount),
    date: Value(date),
    kind: Value(kind),
    description: Value(description),
    accountId: Value(accountId),
    toAccountId: Value(toAccountId),
    categoryId: Value(categoryId),
    familyId: Value(fid),
  ));
  // Apply balance cascade
  await BalanceService(db).applyTransaction(
    kind: kind,
    amount: amount,
    fromAccountId: accountId,
    toAccountId: toAccountId,
  );
}

/// Seed a transaction row WITHOUT balance cascade (for seeding historical data).
Future<void> seedTransactionOnly(
  AppDatabase db, {
  required String id,
  required int amount,
  required DateTime date,
  required String kind,
  required String accountId,
  String? toAccountId,
  String? description,
  String? categoryId,
  String? familyId,
}) async {
  final fid = familyId ?? 'sim_family';
  await db.into(db.transactions).insert(TransactionsCompanion(
    id: Value(id),
    amount: Value(amount),
    date: Value(date),
    kind: Value(kind),
    description: Value(description),
    accountId: Value(accountId),
    toAccountId: Value(toAccountId),
    categoryId: Value(categoryId),
    familyId: Value(fid),
  ));
}

/// Seed a category row.
Future<void> seedCategory(
  AppDatabase db, {
  required String id,
  required String name,
  required String groupName,
  String type = 'EXPENSE',
  String? familyId,
}) async {
  final fid = familyId ?? 'sim_family';
  await db.into(db.categories).insert(CategoriesCompanion(
    id: Value(id),
    name: Value(name),
    groupName: Value(groupName),
    type: Value(type),
    familyId: Value(fid),
  ));
}

/// Seed a budget row.
Future<void> seedBudget(
  AppDatabase db, {
  required String id,
  required String categoryGroup,
  required int limitAmount,
  required int year,
  required int month,
  String? familyId,
}) async {
  final fid = familyId ?? 'sim_family';
  await db.into(db.budgets).insert(BudgetsCompanion(
    id: Value(id),
    familyId: Value(fid),
    categoryGroup: Value(categoryGroup),
    limitAmount: Value(limitAmount),
    year: Value(year),
    month: Value(month),
  ));
}

/// Seed a goal row.
Future<void> seedGoal(
  AppDatabase db, {
  required String id,
  required String name,
  required int targetAmount,
  required DateTime targetDate,
  int currentSavings = 0,
  String status = 'active',
  String? familyId,
}) async {
  final fid = familyId ?? 'sim_family';
  await db.into(db.goals).insert(GoalsCompanion(
    id: Value(id),
    name: Value(name),
    targetAmount: Value(targetAmount),
    targetDate: Value(targetDate),
    currentSavings: Value(currentSavings),
    status: Value(status),
    familyId: Value(fid),
    createdAt: Value(DateTime.now()),
  ));
}

/// Seed a loan detail row.
Future<void> seedLoanDetail(
  AppDatabase db, {
  required String id,
  required String accountId,
  required int principal,
  required double annualRate,
  required int tenureMonths,
  required int outstandingPrincipal,
  required int emiAmount,
  required DateTime startDate,
  String? familyId,
}) async {
  final fid = familyId ?? 'sim_family';
  await db.into(db.loanDetails).insert(LoanDetailsCompanion(
    id: Value(id),
    accountId: Value(accountId),
    principal: Value(principal),
    annualRate: Value(annualRate),
    tenureMonths: Value(tenureMonths),
    outstandingPrincipal: Value(outstandingPrincipal),
    emiAmount: Value(emiAmount),
    startDate: Value(startDate),
    familyId: Value(fid),
  ));
}
