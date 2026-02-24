import 'package:flutter/material.dart';
import 'package:sapeel/views/hosoon_khamsa/app_storage.dart';
import 'package:sapeel/views/hosoon_khamsa/memorization_engine.dart';

class QuranFollowUpFlow extends StatefulWidget {
  const QuranFollowUpFlow({super.key});

  @override
  State<QuranFollowUpFlow> createState() => _QuranFollowUpFlowState();
}

class _QuranFollowUpFlowState extends State<QuranFollowUpFlow> {
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
    if (startPage == 0) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final engine = MemorizationEngine(
      startPage: startPage,
      dayNumber: currentDay,
    );

    return Scaffold(
      appBar: AppBar(title: Text("اليوم $currentDay")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildTile(
              "📖 القراءة",
              "جزء ${engine.readingJuz} & ${(engine.readingJuz) + 1}",
            ),

            _buildTile("🎧 الاستماع", "حزب ${engine.listeningHizb}"),

            _buildTile(
              "📅 التحضير الأسبوعي",
              "${engine.weeklyPrep['start']} - ${engine.weeklyPrep['end']}",
            ),

            _buildTile(
              "🌙 التحضير الليلي",
              engine.nightPrep?.toString() ?? "-",
            ),

            _buildTile("⏳ التحضير القبلي", engine.qabliy?.toString() ?? "-"),

            _buildTile("📝 الحفظ الجديد", engine.newPage?.toString() ?? "-"),

            _buildTile(
              "🔁 مراجعة القريب",
              engine.nearReview == null
                  ? "-"
                  : "${engine.nearReview!['start']} - ${engine.nearReview!['end']}",
            ),

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

  Widget _buildTile(String title, String value) {
    return Card(
      child: ListTile(title: Text(title), subtitle: Text(value)),
    );
  }
}
