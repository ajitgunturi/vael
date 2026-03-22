import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/database.dart';
import 'core/providers/database_providers.dart';
import 'core/providers/session_providers.dart';

/// Dev-mode family/user constants for bootstrapping without onboarding.
const kDevFamilyId = 'dev_family';
const kDevUserId = 'dev_user';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: _AppRoot()));
}

/// Root widget that seeds dev data in debug mode before showing the app.
class _AppRoot extends ConsumerStatefulWidget {
  const _AppRoot();

  @override
  ConsumerState<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<_AppRoot> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      _seedDevData();
    } else {
      _ready = true;
    }
  }

  Future<void> _seedDevData() async {
    final db = ref.read(databaseProvider);

    // Family + User
    await db
        .into(db.families)
        .insertOnConflictUpdate(
          FamiliesCompanion.insert(
            id: kDevFamilyId,
            name: 'Dev Family',
            createdAt: DateTime(2025),
          ),
        );
    await db
        .into(db.users)
        .insertOnConflictUpdate(
          UsersCompanion.insert(
            id: kDevUserId,
            email: 'dev@vael.app',
            displayName: 'Dev User',
            role: 'admin',
            familyId: kDevFamilyId,
          ),
        );

    // Seed accounts so forms with account pickers work
    final existingAccounts = await (db.select(
      db.accounts,
    )..where((a) => a.familyId.equals(kDevFamilyId))).get();

    if (existingAccounts.isEmpty) {
      await db
          .into(db.accounts)
          .insert(
            AccountsCompanion.insert(
              id: 'acc_savings',
              name: 'HDFC Savings',
              type: 'savings',
              balance: 5000000, // ₹50,000
              visibility: 'shared',
              familyId: kDevFamilyId,
              userId: kDevUserId,
            ),
          );
      await db
          .into(db.accounts)
          .insert(
            AccountsCompanion.insert(
              id: 'acc_salary',
              name: 'ICICI Salary',
              type: 'savings',
              balance: 15000000, // ₹1,50,000
              visibility: 'shared',
              familyId: kDevFamilyId,
              userId: kDevUserId,
            ),
          );
      await db
          .into(db.accounts)
          .insert(
            AccountsCompanion.insert(
              id: 'acc_cc',
              name: 'HDFC Credit Card',
              type: 'creditCard',
              balance: -3500000, // ₹-35,000
              visibility: 'shared',
              familyId: kDevFamilyId,
              userId: kDevUserId,
            ),
          );
      await db
          .into(db.accounts)
          .insert(
            AccountsCompanion.insert(
              id: 'acc_home_loan',
              name: 'SBI Home Loan',
              type: 'homeLoan',
              balance: -350000000, // ₹-35,00,000
              visibility: 'shared',
              familyId: kDevFamilyId,
              userId: kDevUserId,
            ),
          );

      // Seed a loan detail for the home loan so LoanDetailScreen works
      await db
          .into(db.loanDetails)
          .insertOnConflictUpdate(
            LoanDetailsCompanion.insert(
              id: 'loan_home',
              accountId: 'acc_home_loan',
              principal: 500000000, // ₹50L
              annualRate: 0.085,
              tenureMonths: 240,
              emiAmount: 4339100, // ~₹43,391 EMI in paise
              outstandingPrincipal: 350000000,
              startDate: DateTime(2023, 6, 1),
              disbursementDate: Value(DateTime(2023, 6, 1)),
              familyId: kDevFamilyId,
            ),
          );
    }

    // Seed categories so budget grouping works
    final existingCategories = await db.select(db.categories).get();
    if (existingCategories.isEmpty) {
      const cats = [
        ('cat_groceries', 'Groceries', 'ESSENTIAL', 'expense'),
        ('cat_rent', 'Rent', 'ESSENTIAL', 'expense'),
        ('cat_utilities', 'Utilities', 'ESSENTIAL', 'expense'),
        ('cat_dining', 'Dining Out', 'NON_ESSENTIAL', 'expense'),
        ('cat_entertainment', 'Entertainment', 'NON_ESSENTIAL', 'expense'),
        ('cat_shopping', 'Shopping', 'NON_ESSENTIAL', 'expense'),
        ('cat_emi', 'EMI', 'HOME_EXPENSES', 'expense'),
        ('cat_maintenance', 'Maintenance', 'HOME_EXPENSES', 'expense'),
        ('cat_sip', 'SIP', 'INVESTMENTS', 'expense'),
        ('cat_insurance', 'Insurance', 'INVESTMENTS', 'expense'),
        ('cat_salary', 'Salary', 'INCOME', 'income'),
      ];
      for (final (id, name, group, type) in cats) {
        await db
            .into(db.categories)
            .insert(
              CategoriesCompanion.insert(
                id: id,
                name: name,
                groupName: group,
                type: type,
                familyId: kDevFamilyId,
              ),
            );
      }
    }

    ref.read(sessionFamilyIdProvider.notifier).set(kDevFamilyId);
    ref.read(sessionUserIdProvider.notifier).set(kDevUserId);
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return const VaelApp();
  }
}
