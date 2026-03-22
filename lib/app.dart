import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/lock_providers.dart';
import 'core/providers/session_providers.dart';
import 'features/auth/screens/lock_screen.dart';
import 'features/onboarding/screens/onboarding_flow.dart';
import 'shared/shell/home_shell.dart';
import 'shared/theme/app_theme.dart';
import 'shared/theme/theme_mode_provider.dart';

class VaelApp extends ConsumerWidget {
  const VaelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyId = ref.watch(sessionFamilyIdProvider);
    final userId = ref.watch(sessionUserIdProvider);
    final themeModeAsync = ref.watch(themeModeProvider);
    final themeMode = switch (themeModeAsync) {
      AsyncData(:final value) => value,
      _ => ThemeMode.system,
    };

    return MaterialApp(
      title: 'Vael',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: _buildHome(ref, familyId, userId),
    );
  }

  Widget _buildHome(WidgetRef ref, String? familyId, String? userId) {
    if (familyId == null || userId == null) {
      return const OnboardingFlow();
    }

    final hasPassphrase = ref.watch(hasPassphraseProvider);
    final isLocked = ref.watch(lockStateProvider);

    // While checking secure storage, show nothing (fast async read).
    final passphraseSet = switch (hasPassphrase) {
      AsyncData(:final value) => value,
      _ => false,
    };

    if (passphraseSet && isLocked) {
      return LockScreen(
        onUnlocked: () => ref.read(lockStateProvider.notifier).unlock(),
      );
    }

    return HomeShell(familyId: familyId, userId: userId);
  }
}
