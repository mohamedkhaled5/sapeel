import 'package:flutter/material.dart';
import 'package:sapeel/views/home/home_screen.dart';
import 'package:sapeel/views/home/root_decider.dart';
import 'package:sapeel/views/hosoon_khamsa/app_storage.dart';
import 'package:sapeel/views/hosoon_khamsa/memorization_engine.dart';

/// شاشة متابعة "الحصون الخمسة" للمراجعة والحفظ اليومي
class QuranFollowUpFlow extends StatefulWidget {
  const QuranFollowUpFlow({super.key});

  @override
  State<QuranFollowUpFlow> createState() => _QuranFollowUpFlowState();
}

class _QuranFollowUpFlowState extends State<QuranFollowUpFlow> {
  // --- المتغيرات والحالة ---
  int startPage = 0;
  int currentDay = 1;
  int farBlockSize = 40;
  Map<String, bool> dailyStatus = {};
  bool weeklyBreakEnabled = false;

  @override
  void initState() {
    super.initState();
    AppStorage.saveLastRoute('/dua');
    _loadProgress();
  }

  /// تحميل التقدم المحفوظ من التخزين المحلي
  void _loadProgress() async {
    final savedStartPage = await AppStorage.getStartPage();
    if (savedStartPage != null) {
      startPage = savedStartPage;
      currentDay = await AppStorage.getDay();
      farBlockSize = await AppStorage.getFarBlockSize();
      weeklyBreakEnabled = await AppStorage.getWeeklyBreakEnabled();
      dailyStatus = await AppStorage.getDailyStatus(currentDay);
      if (mounted) setState(() {});
    }
  }

  /// الانتقال لليوم التالي
  void _nextDay() async {
    if (currentDay >= 604) return;
    currentDay++;
    await AppStorage.saveDay(currentDay);
    dailyStatus = await AppStorage.getDailyStatus(currentDay);
    setState(() {});
  }

  /// العودة لليوم السابق
  void _lastDay() async {
    if (currentDay > 1) {
      currentDay--;
      await AppStorage.saveDay(currentDay);
      dailyStatus = await AppStorage.getDailyStatus(currentDay);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // حالة الانتظار لحين تحميل البيانات
    if (startPage == 0) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // محرك حساب خطة الحفظ والمراجعة
    final engine = MemorizationEngine(
      startPage: startPage,
      dayNumber: currentDay,
      farBlockSize: farBlockSize,
      weeklyBreakEnabled: weeklyBreakEnabled,
    );

    return Scaffold(
      appBar: AppBar(
        // زر الرجوع للصفحة الرئيسية
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
        title: Text("اليوم $currentDay"),
        centerTitle: true,
        actions: [
          // زر الإحصائيات
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: "الإحصائيات",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HsoonStatsPage()),
              );
            },
          ),
          // زر فهرس الأيام
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: "فهرس الأيام",
            onPressed: () async {
              final selectedDay = await Navigator.push<int>(
                context,
                MaterialPageRoute(builder: (_) => const HsoonDaysIndexPage()),
              );
              if (selectedDay != null) {
                currentDay = selectedDay;
                await AppStorage.saveDay(currentDay);
                _loadProgress();
              }
            },
          ),
          // زر إعادة الضبط (البدء من جديد)
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: "إعادة ضبط البرنامج",
            onPressed: () => _showResetDialog(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildTile(
                    "📖 القراءة",
                    "جزء ${engine.readingJuz} & ${(engine.readingJuz) + 1}",
                    "reading",
                  ),
                  _buildTile(
                    "🎧 الاستماع",
                    "حزب ${engine.listeningHizb}",
                    "listening",
                  ),
                  _buildTile(
                    "📅 التحضير الأسبوعي",
                    "${engine.weeklyPrep['start']} - ${engine.weeklyPrep['end']}",
                    "weekly",
                  ),
                  _buildTile(
                    "🌙 التحضير الليلي",
                    engine.nightPrep?.toString() ?? "-",
                    "night",
                  ),
                  _buildTile(
                    "⏳ التحضير القبلي",
                    engine.qabliy?.toString() ?? "-",
                    "qabliy",
                  ),
                  _buildTile(
                    "📝 الحفظ الجديد",
                    engine.newPage?.toString() ?? "-",
                    "new",
                  ),
                  _buildTile(
                    "🔁 مراجعة القريب",
                    engine.nearReview == null
                        ? "-"
                        : "${engine.nearReview!['start']} - ${engine.nearReview!['end']}",
                    "near",
                  ),
                  _buildTile(
                    "📦 مراجعة البعيد",
                    engine.farReview == null
                        ? "-"
                        : "${engine.farReview!['start']} - ${engine.farReview!['end']}",
                    "far",
                  ),
                  _buildTile(
                    "📦 (الثاني) مراجعة البعيد",
                    engine.farOverflowReview == null
                        ? "-"
                        : "${engine.farOverflowReview!['start']} - ${engine.farOverflowReview!['end']}",
                    "far_overflow",
                  ),
                  _buildTile(
                    "📦 (الثالث) مراجعة البعيد",
                    engine.farSecondOverflowReview == null
                        ? "-"
                        : "${engine.farSecondOverflowReview!['start']} - ${engine.farSecondOverflowReview!['end']}",
                    "far_second_overflow",
                  ),
                ],
              ),
            ),
            // أزرار التنقل بين الأيام
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  /// بناء عنصر قائمة للمهمة اليومية
  Widget _buildTile(String title, String subtitle, String statusKey) {
    final isDone = dailyStatus[statusKey] ?? false;
    return Card(
      elevation: isDone ? 0 : 2,
      color: isDone ? Colors.green.withOpacity(0.05) : null,
      child: CheckboxListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        value: isDone,
        onChanged: (val) async {
          if (val == true) {
            await AppStorage.incrementStats(statusKey);
          } else {
            await AppStorage.decrementStats(statusKey);
          }
          setState(() => dailyStatus[statusKey] = val!);
          await AppStorage.saveDailyStatus(currentDay, dailyStatus);
        },
      ),
    );
  }

  /// بناء أزرار التنقل بين الأيام
  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: _lastDay,
            icon: const Icon(Icons.chevron_left),
            label: const Text("اليوم السابق"),
          ),
          ElevatedButton.icon(
            onPressed: _nextDay,
            icon: const Icon(Icons.chevron_right),
            label: const Text("اليوم التالي"),
          ),
        ],
      ),
    );
  }

  /// إظهار حوار تأكيد إعادة الضبط
  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("إعادة ضبط البرنامج"),
        content: const Text(
          "هل أنت متأكد من رغبتك في مسح كل التقدم والبدء من جديد؟",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () async {
              await AppStorage.reset();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const RootDecider()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              "تأكيد المسح",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// --- صفحة الإحصائيات (Statistics Page) ---

class HsoonStatsPage extends StatelessWidget {
  const HsoonStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إحصائيات الختم")),
      body: FutureBuilder<Map<String, int>>(
        future: _loadAllStats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final stats = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatCard("📖 القراءة", stats['reading'] ?? 0, 15, "جزء"),
              _buildStatCard("🎧 الاستماع", stats['listening'] ?? 0, 60, "حزب"),
              _buildStatCard(
                "📅 التحضير الأسبوعي",
                stats['weekly'] ?? 0,
                604,
                "صفحة",
              ),
              _buildStatCard(
                "🌙 التحضير الليلي",
                stats['night'] ?? 0,
                604,
                "صفحة",
              ),
              _buildStatCard(
                "⏳ التحضير القبلي",
                stats['qabliy'] ?? 0,
                604,
                "صفحة",
              ),
              _buildStatCard("📝 الحفظ الجديد", stats['new'] ?? 0, 604, "صفحة"),
              _buildStatCard(
                "🔁 مراجعة القريب",
                stats['near'] ?? 0,
                604,
                "صفحة",
              ),
              _buildStatCard(
                "📦 مراجعة البعيد (1)",
                stats['far'] ?? 0,
                604,
                "صفحة",
              ),
              _buildStatCard(
                "📦 مراجعة البعيد (2)",
                stats['far_overflow'] ?? 0,
                604,
                "صفحة",
              ),
              _buildStatCard(
                "📦 مراجعة البعيد (3)",
                stats['far_second_overflow'] ?? 0,
                604,
                "صفحة",
              ),
            ],
          );
        },
      ),
    );
  }

  Future<Map<String, int>> _loadAllStats() async {
    Map<String, int> stats = {};
    final keys = [
      'reading',
      'listening',
      'weekly',
      'night',
      'qabliy',
      'new',
      'near',
      'far',
      'far_overflow',
      'far_second_overflow',
    ];
    for (var key in keys) {
      stats[key] = await AppStorage.getStats(key);
    }
    return stats;
  }

  Widget _buildStatCard(String title, int count, int cycle, String unit) {
    final completions = count ~/ cycle;
    final progress = (count % cycle) / cycle;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "عدد الختمات: $completions",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              color: Colors.green,
              minHeight: 10,
            ),
            const SizedBox(height: 4),
            Text(
              "التقدم الحالي: $count / $cycle ($unit)",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// --- صفحة فهرس الأيام (Days Index Page) ---

class HsoonDaysIndexPage extends StatelessWidget {
  const HsoonDaysIndexPage({super.key});

  static const taskKeys = [
    'reading',
    'listening',
    'weekly',
    'night',
    'qabliy',
    'new',
    'near',
    'far',
    'far_overflow',
    'far_second_overflow',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("فهرس أيام الحصون")),
      body: FutureBuilder<Map<int, Map<String, bool>>>(
        future: AppStorage.getAllDaysStatus(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final allStatus = snapshot.data!;

          // تقسيم الأيام لمجموعات كل مجموعة 30 يوماً
          const daysPerGroup = 30;
          const totalDays = 604;
          final groupCount = (totalDays / daysPerGroup).ceil();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: groupCount,
            itemBuilder: (context, groupIndex) {
              final startDay = (groupIndex * daysPerGroup) + 1;
              final endDay = (startDay + daysPerGroup - 1 > totalDays)
                  ? totalDays
                  : startDay + daysPerGroup - 1;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "الأيام: $startDay - $endDay",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                    itemCount: (endDay - startDay + 1),
                    itemBuilder: (context, index) {
                      final day = startDay + index;
                      final status = allStatus[day] ?? {};
                      return _buildDaySquare(context, day, status);
                    },
                  ),
                  const Divider(height: 32),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDaySquare(
    BuildContext context,
    int day,
    Map<String, bool> status,
  ) {
    final completedTasks = status.values.where((v) => v == true).length;
    final isAllDone = completedTasks == 10;

    return InkWell(
      onTap: () => Navigator.pop(context, day),
      child: Container(
        decoration: BoxDecoration(
          color: isAllDone ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[400]!),
          boxShadow: [
            if (status.isNotEmpty)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Stack(
          children: [
            // عرض اليوم في المنتصف
            Center(
              child: Text(
                "$day",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isAllDone ? Colors.white : Colors.black87,
                ),
              ),
            ),
            // لو اليوم مش كامل، نعرض الـ 10 مربعات الصغيرة للحالة
            if (!isAllDone && status.isNotEmpty)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 1,
                          mainAxisSpacing: 1,
                        ),
                    itemCount: 10,
                    itemBuilder: (ctx, i) {
                      final key = taskKeys[i];
                      final isTaskDone = status[key] ?? false;
                      return Container(
                        decoration: BoxDecoration(
                          color: isTaskDone
                              ? Colors.green.withOpacity(0.5)
                              : Colors.red.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      );
                    },
                  ),
                ),
              ),
            // لو اليوم لسه مبدأش خالص (status فاضي) يفضل رمادي خفيف
            if (status.isEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
