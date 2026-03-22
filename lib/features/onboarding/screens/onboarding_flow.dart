import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/providers/database_providers.dart';
import '../../../core/providers/session_providers.dart';
import '../../../shared/theme/spacing.dart';
import '../providers/onboarding_providers.dart';

/// Multi-step onboarding: Welcome → Create Family → Done.
///
/// On completion, seeds family+user in DB and sets session providers
/// so VaelApp transitions to HomeShell.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _familyNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _familyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = ref.watch(onboardingStepProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: switch (step) {
            0 => _WelcomeStep(
              onNext: () => ref.read(onboardingStepProvider.notifier).next(),
            ),
            1 => _CreateFamilyStep(
              formKey: _formKey,
              controller: _familyNameController,
              onSubmit: _createFamily,
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ),
    );
  }

  Future<void> _createFamily() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _familyNameController.text.trim();
    final familyId = 'fam_${DateTime.now().millisecondsSinceEpoch}';
    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';

    final db = ref.read(databaseProvider);
    await db
        .into(db.families)
        .insert(
          FamiliesCompanion.insert(
            id: familyId,
            name: name,
            createdAt: DateTime.now(),
          ),
        );
    await db
        .into(db.users)
        .insert(
          UsersCompanion.insert(
            id: userId,
            email: 'owner@vael.app',
            displayName: name,
            role: 'admin',
            familyId: familyId,
          ),
        );

    ref.read(sessionFamilyIdProvider.notifier).set(familyId);
    ref.read(sessionUserIdProvider.notifier).set(userId);
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: Spacing.lg),
          Text(
            'Welcome to Vael',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'Your family\'s private financial companion',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.xl),
          FilledButton(onPressed: onNext, child: const Text('Get Started')),
        ],
      ),
    );
  }
}

class _CreateFamilyStep extends StatelessWidget {
  const _CreateFamilyStep({
    required this.formKey,
    required this.controller,
    required this.onSubmit,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create Your Family',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: Spacing.md),
            TextFormField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Family Name'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter a family name'
                  : null,
            ),
            const SizedBox(height: Spacing.lg),
            FilledButton(
              onPressed: onSubmit,
              child: const Text('Create Family'),
            ),
          ],
        ),
      ),
    );
  }
}
