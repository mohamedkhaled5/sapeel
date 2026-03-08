import 'package:flutter/material.dart';
import 'package:sapeel/views/home/home_screen.dart';
import 'package:sapeel/views/home/root_decider.dart';
import 'package:sapeel/views/hosoon_khamsa/app_storage.dart';
import 'package:sapeel/views/hosoon_khamsa/memorization_engine.dart';
import 'package:intl/intl.dart';
import 'package:sapeel/data/quran_repository.dart';
import 'package:sapeel/utils/quran_metadata.dart';

/// شاشة متابعة "الحصون الخمسة" للمراجعة والحفظ اليومي
class QuranFollowUpFlow extends StatefulWidget {
  const QuranFollowUpFlow({super.key});

  @override
  State<QuranFollowUpFlow> createState() => _QuranFollowUpFlowState();
}

class _QuranFollowUpFlowState extends State<QuranFollowUpFlow> {
  // --- المتغيرات والحالة ---
  final QuranRepository _quranRepo = QuranRepository();
  bool _isRepoLoaded = false;

  int startPage = 0;
  int currentDay = 1;
  int effectiveDay = 1;
  int farBlockSize = 40;
  Map<String, bool> dailyStatus = {};
  bool weeklyBreakEnabled = false;
  int? nearGoalPage;
  bool nearGoalReached = false;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  void _initAsync() async {
    try {
      await AppStorage.saveLastRoute('/dua');
      await _quranRepo.init();
      if (mounted) {
        setState(() {
          _isRepoLoaded = true;
        });
      }
      _loadProgress();
    } catch (e) {
      debugPrint("Error in _initAsync: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("تعذر تحميل البيانات")));
        setState(
          () => _isRepoLoaded = true,
        ); // تجاوز الخطأ للسماح للمستخدم بالتصرف
      }
    }
  }

  /// تحميل التقدم المحفوظ من التخزين المحلي
  void _loadProgress() async {
    try {
      final savedStartPage = await AppStorage.getStartPage();
      if (savedStartPage != null) {
        startPage = savedStartPage;

        // الاعتماد كلياً على اليوم المخزن يدوياً
        // لا يوجد تغيير تلقائي بناءً على التاريخ، التغيير يتم فقط عبر أزرار التنقل أو الفهرس
        currentDay = await AppStorage.getDay();

        if (currentDay < 1) currentDay = 1;
        if (currentDay > 604) currentDay = 604;

        farBlockSize = await AppStorage.getFarBlockSize();
        weeklyBreakEnabled = await AppStorage.getWeeklyBreakEnabled();
        dailyStatus = await AppStorage.getDailyStatus(currentDay);
        final carry = await AppStorage.getCarryOverForDay(currentDay);
        effectiveDay = carry ?? currentDay;
        nearGoalPage = await AppStorage.getNearGoalPage();
        nearGoalReached = await AppStorage.getNearGoalReached();
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
    final carry = await AppStorage.getCarryOverForDay(currentDay);
    effectiveDay = carry ?? currentDay;
    setState(() {});
  }

  /// العودة لليوم السابق
  void _lastDay() async {
    if (currentDay > 1) {
      currentDay--;
      await AppStorage.saveDay(currentDay);
      dailyStatus = await AppStorage.getDailyStatus(currentDay);
      final carry = await AppStorage.getCarryOverForDay(currentDay);
      effectiveDay = carry ?? currentDay;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // حالة الانتظار لحين تحميل البيانات
    if (startPage == 0 || !_isRepoLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // محرك حساب خطة الحفظ والمراجعة
    final engine = MemorizationEngine(
      startPage: startPage,
      dayNumber: effectiveDay,
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
          // زر الهدف القريب
          IconButton(
            icon: const Icon(Icons.flag),
            tooltip: "الهدف القريب",
            onPressed: _showNearGoalDialog,
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
                // تحديث اليوم وحفظه
                currentDay = selectedDay;
                await AppStorage.saveDay(currentDay);
                // إعادة تحميل بيانات اليوم الجديد
                dailyStatus = await AppStorage.getDailyStatus(currentDay);
                final carry = await AppStorage.getCarryOverForDay(currentDay);
                effectiveDay = carry ?? currentDay;
                if (mounted) setState(() {});
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
                  _buildReadingTile(engine),
                  _buildListeningTile(engine),
                  const Divider(height: 32),
                  _buildEnhancedTile(
                    "📅 التحضير الأسبوعي",
                    engine.weeklyPrep['start']!,
                    engine.weeklyPrep['end']!,
                    "weekly",
                  ),
                  if (engine.nightPrep != null)
                    _buildEnhancedTile(
                      "🌙 التحضير الليلي",
                      engine.nightPrep!,
                      engine.nightPrep!,
                      "night",
                    ),
                  if (engine.qabliy != null)
                    _buildEnhancedTile(
                      "⏳ التحضير القبلي",
                      engine.qabliy!,
                      engine.qabliy!,
                      "qabliy",
                    ),
                  if (engine.newPage != null)
                    _buildEnhancedTile(
                      "📝 الحفظ الجديد",
                      engine.newPage!,
                      engine.newPage!,
                      "new",
                    ),
                  if (engine.nearReview != null)
                    _buildEnhancedTile(
                      "🔁 مراجعة القريب",
                      engine.nearReview!['start']!,
                      engine.nearReview!['end']!,
                      "near",
                    ),
                  if (engine.farReview != null)
                    _buildEnhancedTile(
                      "📦 مراجعة البعيد (1)",
                      engine.farReview!['start']!,
                      engine.farReview!['end']!,
                      "far",
                    ),
                  if (engine.farOverflowReview != null)
                    _buildEnhancedTile(
                      "📦 (الثاني) مراجعة البعيد",
                      engine.farOverflowReview!['start']!,
                      engine.farOverflowReview!['end']!,
                      "far_overflow",
                    ),
                  if (engine.farSecondOverflowReview != null)
                    _buildEnhancedTile(
                      "📦 (الثالث) مراجعة البعيد",
                      engine.farSecondOverflowReview!['start']!,
                      engine.farSecondOverflowReview!['end']!,
                      "far_second_overflow",
                    ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _skipToday,
                icon: const Icon(Icons.skip_next),
                label: const Text("تخطي اليوم كاملًا"),
              ),
            ),
            // أزرار التنقل بين الأيام
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  /// بناء عنصر قائمة خاص بمهمة القراءة (جزءين يومياً) مع زر الانتقال
  Widget _buildReadingTile(MemorizationEngine engine) {
    final j1 = engine.readingJuz;
    final j2 = (j1 % 30) + 1;

    // الحصول على أرقام الصفحات من Metadata
    // juzStartPages هي قائمة من 30 عنصراً (من 0 إلى 29)
    final startP = QuranMetadata.juzStartPages[j1 - 1];

    // نهاية الجزء الثاني هي بداية الجزء الثالث ناقص 1
    // إذا كان الجزء الثاني هو 30، فالنهاية هي 604
    int endP;
    if (j2 == 30) {
      endP = 604;
    } else {
      endP = QuranMetadata.juzStartPages[j2] - 1;
    }

    return _buildEnhancedTile(
      "📖 القراءة",
      startP,
      endP,
      "reading",
      customSubtitle: "جزء $j1 & $j2",
    );
  }

  /// بناء عنصر قائمة خاص بمهمة الاستماع (حزب يومياً) مع زر الانتقال
  Widget _buildListeningTile(MemorizationEngine engine) {
    final h = engine.listeningHizb;
    final juzIndex = (h - 1) ~/ 2;
    final isSecondHizb = (h - 1) % 2 == 1;

    final startP_juz = QuranMetadata.juzStartPages[juzIndex];
    int startP;

    if (!isSecondHizb) {
      startP = startP_juz;
    } else {
      // الحزب الثاني من الجزء
      final nextJuzStart = (juzIndex + 1 < 30)
          ? QuranMetadata.juzStartPages[juzIndex + 1]
          : 605;
      startP = (startP_juz + nextJuzStart) ~/ 2;
    }

    // نهاية الحزب
    int endP;
    if (!isSecondHizb) {
      final nextJuzStart = (juzIndex + 1 < 30)
          ? QuranMetadata.juzStartPages[juzIndex + 1]
          : 605;
      endP = ((startP_juz + nextJuzStart) ~/ 2) - 1;
    } else {
      final nextJuzStart = (juzIndex + 1 < 30)
          ? QuranMetadata.juzStartPages[juzIndex + 1]
          : 605;
      endP = nextJuzStart - 1;
    }

    if (endP > 604) endP = 604;
    if (startP > 604) startP = 604;

    return _buildEnhancedTile(
      "🎧 الاستماع",
      startP,
      endP,
      "listening",
      customSubtitle: "حزب $h",
    );
  }

  /// بناء عنصر قائمة محسّن ببيانات السور والآيات وزر الانتقال
  Widget _buildEnhancedTile(
    String title,
    int startP,
    int endP,
    String statusKey, {
    String? customSubtitle,
  }) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    final surfaceVariant = theme.colorScheme.surfaceVariant;
    final isDone = dailyStatus[statusKey] ?? false;
    final metadata = _quranRepo.getRangeMetadata(startP, endP);
    final coversGoal =
        nearGoalPage != null &&
        nearGoalPage! >= startP &&
        nearGoalPage! <= endP;

    return Card(
      elevation: isDone ? 0 : 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDone
              ? Colors.green.withOpacity(0.2)
              : (coversGoal ? Colors.amber : Colors.transparent),
          width: coversGoal && !isDone ? 1.5 : 1.0,
        ),
      ),
      color: isDone ? Colors.green.withOpacity(0.05) : null,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CheckboxListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              title: Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (customSubtitle != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        customSubtitle,
                        style: TextStyle(
                          fontSize: 10,
                          color: onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  if (coversGoal) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade700),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.flag,
                            size: 12,
                            color: Colors.amber.shade800,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "هدف قريب",
                            style: TextStyle(
                              fontSize: 10,
                              color: onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    "📖 ${metadata['surahRange']}",
                    style: TextStyle(
                      color: onSurface,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        metadata['pageRange'],
                        style: TextStyle(fontSize: 11, color: onSurfaceVariant),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.mosque_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        metadata['jozzRange'],
                        style: TextStyle(fontSize: 11, color: onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/surah_detail',
                      arguments: {
                        'page': startP,
                        'endPage': endP,
                        'segmentLabel': title,
                      },
                    );
                  },
                  icon: const Icon(Icons.menu_book, size: 18),
                  label: const Text("الانتقال إلى المصحف"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade50,
                    foregroundColor: Colors.brown.shade800,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// أزرار التنقل (اليوم السابق / اليوم التالي)
  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: currentDay < 604 ? _nextDay : null,
            icon: const Icon(Icons.arrow_forward_ios),
            tooltip: "اليوم التالي",
          ),
          Text(
            "اليوم $currentDay",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: currentDay > 1 ? _lastDay : null,
            icon: const Icon(Icons.arrow_back_ios),
            tooltip: "اليوم السابق",
          ),
        ],
      ),
    );
  }

  /// حوار إعادة الضبط
  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("إعادة ضبط البرنامج"),
        content: const Text(
          "هل أنت متأكد من رغبتك في حذف كل التقدم والبدء من جديد؟",
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
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/setup',
                  (route) => false,
                );
              }
            },
            child: const Text("إعادة ضبط", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- الهدف القريب ---
  void _showNearGoalDialog() async {
    final currentGoal = await AppStorage.getNearGoalPage();
    final controller = TextEditingController(
      text: currentGoal != null ? "$currentGoal" : "",
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("تحديد هدف قريب"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "رقم الصفحة (1 - 604)",
            hintText: "مثال: 100",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await AppStorage.saveNearGoalPage(null);
              await AppStorage.saveNearGoalReached(false);
              setState(() {
                nearGoalPage = null;
                nearGoalReached = false;
              });
              if (mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("تم مسح الهدف القريب")),
                );
              }
            },
            child: const Text("مسح"),
          ),
          TextButton(
            onPressed: () async {
              final text = controller.text.trim();
              final page = int.tryParse(text);
              if (page != null && page >= 1 && page <= 604) {
                await AppStorage.saveNearGoalPage(page);
                await AppStorage.saveNearGoalReached(false);
                setState(() {
                  nearGoalPage = page;
                  nearGoalReached = false;
                });
                if (mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("تم تعيين الهدف القريب: الصفحة $page"),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("الرجاء إدخال رقم صفحة صحيح")),
                );
              }
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  // --- تخطي اليوم ---
  Future<void> _skipToday() async {
    if (currentDay >= 604) return;
    await AppStorage.setCarryOverForDay(currentDay + 1, effectiveDay);
    currentDay += 1;
    await AppStorage.saveDay(currentDay);
    dailyStatus = await AppStorage.getDailyStatus(currentDay);
    final carry = await AppStorage.getCarryOverForDay(currentDay);
    effectiveDay = carry ?? currentDay;
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "تم تخطي اليوم. ستُعرض مهام يوم $effectiveDay في يوم $currentDay",
          ),
        ),
      );
    }
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

// --- صفحة الإحصائيات (Stats Page) ---

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
              _buildStatCard("📖 القراءة", stats['reading'] ?? 0, 604, "جزء"),
              _buildStatCard(
                "🎧 الاستماع",
                stats['listening'] ?? 0,
                604,
                "حزب",
              ),
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
                "📦 (الثاني) مراجعة البعيد",
                stats['far_overflow'] ?? 0,
                604,
                "صفحة",
              ),
              _buildStatCard(
                "📦 (الثالث) مراجعة البعيد",
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
    final stats = <String, int>{};
    await Future.wait(
      keys.map((key) async {
        stats[key] = await AppStorage.getStats(key);
      }),
    );
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
                  "عدد الإنجازات: $completions",
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
