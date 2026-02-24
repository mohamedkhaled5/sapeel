import 'package:flutter/material.dart';
import 'package:sapeel/views/hosoon_khamsa/app_storage.dart';

class StartSetupScreen extends StatefulWidget {
  const StartSetupScreen({super.key});

  @override
  State<StartSetupScreen> createState() => _StartSetupScreenState();
}

class _StartSetupScreenState extends State<StartSetupScreen> {
  final controller = TextEditingController();
  int selectedFarSize = 40;
  bool weeklyBreakEnabled = false;

  @override
  void initState() {
    super.initState();
    AppStorage.saveLastRoute('/setup');
  }

  void start() async {
    final page = int.tryParse(controller.text);
    if (page == null) return;

    await AppStorage.saveStartPage(page);
    await AppStorage.saveFarBlockSize(selectedFarSize);
    await AppStorage.saveWeeklyBreakEnabled(weeklyBreakEnabled); // 👈 أضف ده
    await AppStorage.saveDay(1);

    if (mounted) {
      Navigator.pushReplacementNamed(context, "/dua");
    }
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("مراجعة البعيد أسبوعيًا: "),
                const SizedBox(width: 10),
                DropdownButton<int>(
                  value: selectedFarSize,
                  items: const [
                    DropdownMenuItem(value: 40, child: Text("40 صفحة")),
                    DropdownMenuItem(value: 20, child: Text("20 صفحة")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedFarSize = value!;
                    });
                  },
                ),
              ],
            ),
            SwitchListTile(
              title: const Text(
                "إيقاف مراجعة البعيد لباقي الأسبوع بعد الانتهاء",
              ),
              value: weeklyBreakEnabled,
              onChanged: (val) {
                setState(() {
                  weeklyBreakEnabled = val;
                });
              },
            ),
            ElevatedButton(onPressed: start, child: const Text("ابدأ")),
          ],
        ),
      ),
    );
  }
}
