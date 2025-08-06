import 'package:flutter/material.dart';
import 'lib/models/soroban_model.dart';
import 'lib/widgets/soroban_widget.dart';

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Test Soroban Bead Movement', home: const TestScreen());
  }
}

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  late SorobanModel soroban;

  @override
  void initState() {
    super.initState();
    soroban = SorobanModel.create();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Bead Movement'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                soroban.resetAllRods();
              });
            },
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Total Value: ${soroban.totalValue}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(child: SorobanWidget(soroban: soroban)),
            const SizedBox(height: 20),
            const Text('Tap beads to move them up/down', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
