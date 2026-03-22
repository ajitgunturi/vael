import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/session_providers.dart';
import 'shared/shell/home_shell.dart';
import 'shared/theme/app_theme.dart';

class VaelApp extends ConsumerWidget {
  const VaelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyId = ref.watch(sessionFamilyIdProvider);
    final userId = ref.watch(sessionUserIdProvider);

    return MaterialApp(
      title: 'Vael',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: familyId != null && userId != null
          ? HomeShell(familyId: familyId, userId: userId)
          : const Scaffold(body: Center(child: Text('Vael'))),
    );
  }
}
