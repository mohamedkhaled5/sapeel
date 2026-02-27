import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  DateTime selectedDate = DateTime.now();
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    AppStorage.saveLastRoute('/setup');
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        // سيتم استخدام اللغة العربية تلقائياً بناءً على إعدادات MaterialApp
      );
      if (picked != null && picked != selectedDate) {
        setState(() {
          selectedDate = picked;
        });
      }
    } catch (e) {
      debugPrint("Error picking date: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تعذر فتح اختيار التاريخ")),
        );
      }
    }
  }

  void start() async {
    final pageStr = controller.text.trim();
    if (pageStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى إدخال رقم صفحة البداية")),
      );
      return;
    }

    final page = int.tryParse(pageStr);
    if (page == null || page < 1 || page > 604) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى إدخال رقم صفحة صحيح (1-604)")),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      debugPrint("Saving setup data...");
      await AppStorage.saveStartPage(page);
      await AppStorage.saveFarBlockSize(selectedFarSize);
      await AppStorage.saveWeeklyBreakEnabled(weeklyBreakEnabled);
      await AppStorage.saveStartDate(selectedDate);
      await AppStorage.saveDay(1);

      debugPrint("Data saved, navigating to /dua");
      if (mounted) {
        Navigator.of(context).pushReplacementNamed("/dua");
      }
    } catch (e) {
      debugPrint("Error in start(): $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("حدث خطأ أثناء الحفظ: $e")));
        setState(() => isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إعداد البرنامج")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.settings_suggest, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              "ابدأ رحلتك مع الحصون الخمسة",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // صفحة البداية
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "صفحة البداية (من المصحف)",
                hintText: "مثلاً: 1",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.menu_book),
              ),
            ),
            const SizedBox(height: 20),

            // مراجعة البعيد
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("حجم مراجعة البعيد: "),
                        DropdownButton<int>(
                          value: selectedFarSize,
                          items: const [
                            DropdownMenuItem(value: 40, child: Text("40 صفحة")),
                            DropdownMenuItem(value: 20, child: Text("20 صفحة")),
                          ],
                          onChanged: isSaving
                              ? null
                              : (value) {
                                  setState(() {
                                    selectedFarSize = value!;
                                  });
                                },
                        ),
                      ],
                    ),
                    const Divider(),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        "إيقاف مراجعة البعيد لباقي الأسبوع بعد الانتهاء",
                        style: TextStyle(fontSize: 14),
                      ),
                      value: weeklyBreakEnabled,
                      onChanged: isSaving
                          ? null
                          : (val) {
                              setState(() {
                                weeklyBreakEnabled = val;
                              });
                            },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // تاريخ البدء
            InkWell(
              onTap: isSaving ? null : () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.green),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "تاريخ البدء",
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          DateFormat('yyyy/MM/dd').format(selectedDate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (!isSaving)
                      const Text("تغيير", style: TextStyle(color: Colors.blue)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isSaving ? null : start,
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "ابدأ البرنامج الآن",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
