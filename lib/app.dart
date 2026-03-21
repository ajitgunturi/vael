import 'package:flutter/material.dart';

import 'shared/theme/app_theme.dart';

class VaelApp extends StatelessWidget {
  const VaelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vael',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const Scaffold(
        body: Center(child: Text('Vael')),
      ),
    );
  }
}
