import 'package:flutter/material.dart';

class VaelApp extends StatelessWidget {
  const VaelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vael',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('Vael')),
      ),
    );
  }
}
