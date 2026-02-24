import 'package:flutter/material.dart';
import 'package:sapeel/views/hosoon_khamsa/app_storage.dart';

class StartSetupScreen extends StatefulWidget {
  const StartSetupScreen({super.key});

  @override
  State<StartSetupScreen> createState() => _StartSetupScreenState();
}

class _StartSetupScreenState extends State<StartSetupScreen> {
  final controller = TextEditingController();

  void start() async {
    final page = int.tryParse(controller.text);
    if (page == null) return;

    await AppStorage.saveStartPage(page);
    await AppStorage.saveDay(1);

    Navigator.pushReplacementNamed(context, "/dashboard");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("اختر صفحة البداية", style: TextStyle(fontSize: 22)),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: start, child: const Text("ابدأ")),
          ],
        ),
      ),
    );
  }
}
