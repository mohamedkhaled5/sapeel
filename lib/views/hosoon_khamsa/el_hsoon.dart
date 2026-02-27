import 'package:flutter/material.dart';
import 'package:sapeel/views/home/home_screen.dart';
import 'package:sapeel/views/home/root_decider.dart';
import 'package:sapeel/views/hosoon_khamsa/app_storage.dart';
import 'package:sapeel/views/hosoon_khamsa/memorization_engine.dart';
import 'package:intl/intl.dart';

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
    _initAsync();
  }

  void _initAsync() async {
    await AppStorage.saveLastRoute('/dua');
    _loadProgress();
  }

  /// تحميل التقدم المحفوظ من التخزين المحلي
  void _loadProgress() async {
    try {
      final savedStartPage = await AppStorage.getStartPage();
      if (savedStartPage != null) {
        startPage = savedStartPage;
        final startDate = await AppStorage.getStartDate();
        if (startDate != null) {
          // حساب اليوم الحالي بناءً على تاريخ البدء
          final now = DateTime.now();
          final difference = now.difference(startDate).inDays;
          currentDay = difference + 1;
          if (currentDay < 1) currentDay = 1;
          if (currentDay > 604) currentDay = 604;
          // حفظ اليوم المحسوب
          await AppStorage.saveDay(currentDay);
        } else {
          currentDay = await AppStorage.getDay();
        }
        farBlockSize = await AppStorage.getFarBlockSize();
        weeklyBreakEnabled = await AppStorage.getWeeklyBreakEnabled();
        dailyStatus = await AppStorage.getDailyStatus(currentDay);
        if (mounted) setState(() {});
      } else {
        // إذا لم يتم العثور على صفحة بداية، فهذا يعني أن البرنامج لم يتم ضبطه بعد
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/setup');
        }
      }
    } catch (e) {
      debugPrint("Error loading progress: $e");
      // في حالة حدوث خطأ، نعود للشاشة الرئيسية لتجنب التعليق
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("حدث خطأ أثناء تحميل البيانات")),
        );
        Navigator.of(context).pop();
      }
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

class HsoonDaysIndexPage extends StatefulWidget {
  const HsoonDaysIndexPage({super.key});

  @override
  State<HsoonDaysIndexPage> createState() => _HsoonDaysIndexPageState();
}

class _HsoonDaysIndexPageState extends State<HsoonDaysIndexPage>
    with SingleTickerProviderStateMixin {
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

  late TabController _tabController;
  DateTime? startDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 21, vsync: this);
    _loadInitialData();
  }

  void _loadInitialData() async {
    startDate = await AppStorage.getStartDate();
    final day = await AppStorage.getDay();
    final monthIndex = (day - 1) ~/ 30;
    if (monthIndex < 21) {
      _tabController.index = monthIndex;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("فهرس الحصون"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: List.generate(21, (index) => Tab(text: "الشهر ${index + 1}")),
        ),
      ),
      body: FutureBuilder<Map<int, Map<String, bool>>>(
        future: AppStorage.getAllDaysStatus(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final allStatus = snapshot.data!;

          return TabBarView(
            controller: _tabController,
            children: List.generate(21, (monthIndex) {
              final startDay = (monthIndex * 30) + 1;
              final endDay = (startDay + 29 > 604) ? 604 : startDay + 29;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: (endDay - startDay + 1),
                itemBuilder: (context, index) {
                  final day = startDay + index;
                  final status = allStatus[day] ?? {};
                  final date = startDate?.add(Duration(days: day - 1));
                  final dateStr = date != null
                      ? DateFormat('EEEE, d MMMM', 'ar').format(date)
                      : "اليوم $day";

                  return _buildDayTile(context, day, dateStr, status);
                },
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildDayTile(
    BuildContext context,
    int day,
    String dateLabel,
    Map<String, bool> status,
  ) {
    final completedTasks = status.values.where((v) => v == true).length;
    final progress = completedTasks / 10.0;
    final isDone = completedTasks == 10;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () => Navigator.pop(context, day),
        leading: CircleAvatar(
          backgroundColor: isDone ? Colors.green : Colors.brown.shade100,
          foregroundColor: isDone ? Colors.white : Colors.brown.shade800,
          child: Text("$day"),
        ),
        title: Text(
          dateLabel,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                color: isDone ? Colors.green : Colors.orange,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "تم إنجاز $completedTasks من 10 مهام",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: Icon(
          isDone ? Icons.check_circle : Icons.chevron_right,
          color: isDone ? Colors.green : Colors.grey,
        ),
      ),
    );
  }
}
