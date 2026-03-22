import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/google_auth_service.dart';
import '../../../core/database/database.dart';
import '../../../core/providers/database_providers.dart';
import '../../../core/providers/session_providers.dart';
import '../../../shared/theme/spacing.dart';
import '../providers/onboarding_providers.dart';

/// Multi-step onboarding: Welcome → Sign In → Create Family → Done.
///
/// In debug mode, a "Skip (Dev Mode)" button bypasses Google Sign-In.
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

  String? _signedInEmail;
  String? _signedInDisplayName;
  String? _authError;
  bool _signingIn = false;

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
            1 => _SignInStep(
              signingIn: _signingIn,
              error: _authError,
              onSignIn: _handleGoogleSignIn,
              onSkipDev: kDebugMode ? _skipSignInDevMode : null,
            ),
            2 => _CreateFamilyStep(
              formKey: _formKey,
              controller: _familyNameController,
              email: _signedInEmail ?? 'dev@vael.app',
              onSubmit: _createFamily,
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _signingIn = true;
      _authError = null;
    });

    try {
      final authService = GoogleAuthService();
      final result = await authService.signIn();

      if (result == null) {
        // User cancelled
        setState(() {
          _signingIn = false;
          _authError = 'Sign-in was cancelled. Please try again.';
        });
        return;
      }

      setState(() {
        _signedInEmail = result.email;
        _signedInDisplayName = result.displayName;
        _signingIn = false;
      });
      ref.read(onboardingStepProvider.notifier).next();
    } catch (e) {
      setState(() {
        _signingIn = false;
        _authError = 'Sign-in failed: ${e.toString().split(':').last.trim()}';
      });
    }
  }

  void _skipSignInDevMode() {
    setState(() {
      _signedInEmail = 'dev@vael.app';
      _signedInDisplayName = 'Dev User';
    });
    ref.read(onboardingStepProvider.notifier).next();
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
            email: _signedInEmail ?? 'owner@vael.app',
            displayName: _signedInDisplayName ?? name,
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

class _SignInStep extends StatelessWidget {
  const _SignInStep({
    required this.signingIn,
    this.error,
    required this.onSignIn,
    this.onSkipDev,
  });

  final bool signingIn;
  final String? error;
  final VoidCallback onSignIn;
  final VoidCallback? onSkipDev;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: Spacing.lg),
          Text('Sign In', style: theme.textTheme.headlineSmall),
          const SizedBox(height: Spacing.sm),
          Text(
            'Sign in with Google to enable encrypted\ncloud backup via Google Drive',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.xl),
          if (signingIn)
            const CircularProgressIndicator()
          else
            SizedBox(
              width: 280,
              child: FilledButton.icon(
                onPressed: onSignIn,
                icon: const Icon(Icons.account_circle),
                label: const Text('Sign in with Google'),
              ),
            ),
          if (error != null) ...[
            const SizedBox(height: Spacing.md),
            Text(
              error!,
              style: TextStyle(color: theme.colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ],
          if (onSkipDev != null) ...[
            const SizedBox(height: Spacing.xl),
            TextButton(
              onPressed: onSkipDev,
              child: const Text('Skip (Dev Mode)'),
            ),
          ],
        ],
      ),
    );
  }
}

class _CreateFamilyStep extends StatelessWidget {
  const _CreateFamilyStep({
    required this.formKey,
    required this.controller,
    required this.email,
    required this.onSubmit,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final String email;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Create Your Family', style: theme.textTheme.headlineSmall),
            const SizedBox(height: Spacing.sm),
            Text(
              'Signed in as $email',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
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
