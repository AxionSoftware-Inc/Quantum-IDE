import 'package:flutter/material.dart';
import 'layout/main_layout.dart';

void main() {
  runApp(const QuantumIDE());
}

class QuantumIDE extends StatelessWidget {
  const QuantumIDE({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quantum IDE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MainLayout(),
    );
  }
}