import 'package:flutter/material.dart';
import 'screens/calculator_screen.dart';

void main() {
  runApp(const VoiceCalculatorApp());
}

class VoiceCalculatorApp extends StatelessWidget {
  const VoiceCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Голосовой калькулятор',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CalculatorScreen(),
    );
  }
}