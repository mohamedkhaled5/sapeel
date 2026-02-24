import 'package:flutter/material.dart';
import 'package:sapeel/views/hosoon_khamsa/app_storage.dart';
import 'package:sapeel/views/hosoon_khamsa/memorization_engine.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int startPage = 0;
  int currentDay = 1;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    startPage = (await AppStorage.getStartPage())!;
    currentDay = await AppStorage.getDay();
    setState(() {});
  }

  void nextDay() async {
    currentDay++;
    await AppStorage.saveDay(currentDay);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final engine = MemorizationEngine(
      startPage: startPage,
      dayNumber: currentDay,
    );

    return Scaffold(
      appBar: AppBar(title: Text("اليوم $currentDay")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("الحفظ الجديد: ${engine.newPage ?? "-"}"),
            Text("التحضير القبلي: ${engine.qabliy ?? "-"}"),
            Text("التحضير الليلي: ${engine.nightPrep ?? "-"}"),
            Text(
              "الأسبوعي: ${engine.weeklyPrep['start']} - ${engine.weeklyPrep['end']}",
            ),
            Text(
              "المراجعة القريبة: ${engine.nearReview?['start']} - ${engine.nearReview?['end']}",
            ),
            Text("القراءة: جزء ${engine.readingJuz} "),
            Text("الاستماع: حزب ${engine.listeningHizb}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: nextDay,
              child: const Text("إنهاء اليوم"),
            ),
          ],
        ),
      ),
    );
  }
}
