import 'package:flutter/material.dart';
import 'models/soroban_model.dart';
import 'widgets/soroban_widget.dart';

void main() {
  runApp(const SorobanApp());
}

class SorobanApp extends StatelessWidget {
  const SorobanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Soroban',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B4513)), useMaterial3: true),
      home: const SorobanScreen(),
    );
  }
}

class SorobanScreen extends StatefulWidget {
  const SorobanScreen({super.key});

  @override
  State<SorobanScreen> createState() => _SorobanScreenState();
}

class _SorobanScreenState extends State<SorobanScreen> {
  late SorobanModel soroban;

  @override
  void initState() {
    super.initState();
    // Create a default soroban with 13 rods
    soroban = SorobanModel.create();
  }

  @override
  void dispose() {
    soroban.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Digital Soroban'), backgroundColor: const Color(0xFF8B4513), foregroundColor: Colors.white),
      body: Container(
        color: const Color(0xFFF5F5DC), // Beige background
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SorobanWidget(soroban: soroban),
          ),
        ),
      ),
    );
  }
}
