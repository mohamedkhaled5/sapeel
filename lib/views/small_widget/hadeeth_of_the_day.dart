import 'package:flutter/material.dart';
import 'package:sapeel/views/hadeth/data/models/hadeeth_list_item.dart';
import 'package:sapeel/views/hadeth/data/services/hadeeth_api_service.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math';

import 'package:hive/hive.dart';
import 'dart:async';

class HadeethOfTheDay extends StatefulWidget {
  const HadeethOfTheDay({super.key});

  @override
  State<HadeethOfTheDay> createState() => _HadeethOfTheDayState();
}

class _HadeethOfTheDayState extends State<HadeethOfTheDay> {
  final HadeethApiService _apiService = HadeethApiService();
  HadeethListItem? randomHadeeth;
  bool isLoading = true;
  bool isFavorite = false;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadOrFetchHadeeth();
    // إعداد مؤقت للتحقق كل دقيقة إذا كان قد مر 5 ساعات
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAndRefreshHadeeth();
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadOrFetchHadeeth() async {
    final box = await Hive.openBox('daily_content');
    final lastUpdate = box.get('hadeeth_last_update', defaultValue: 0);
    final now = DateTime.now().millisecondsSinceEpoch;

    final cachedId = box.get('last_hadeeth_id');
    final cachedTitle = box.get('last_hadeeth_title');

    // إذا مر أكثر من 5 ساعات أو لا توجد بيانات كاش
    if (now - lastUpdate > 5 * 60 * 60 * 1000 || cachedId == null) {
      _loadRandomHadeeth();
    } else {
      setState(() {
        randomHadeeth = HadeethListItem(id: cachedId, title: cachedTitle);
        isLoading = false;
      });
    }
  }

  Future<void> _checkAndRefreshHadeeth() async {
    final box = await Hive.openBox('daily_content');
    final lastUpdate = box.get('hadeeth_last_update', defaultValue: 0);
    final now = DateTime.now().millisecondsSinceEpoch;

    if (now - lastUpdate > 5 * 60 * 60 * 1000) {
      _loadRandomHadeeth();
    }
  }

  Future<void> _loadRandomHadeeth() async {
    setState(() => isLoading = true);
    try {
      final categories = await _apiService.fetchCategories("ar");
      if (categories.isNotEmpty) {
        final randomCategory = categories[Random().nextInt(categories.length)];
        final hadeeths = await _apiService.fetchHadeethList(
          language: "ar",
          categoryId: randomCategory.id,
        );
        if (hadeeths.isNotEmpty) {
          final selectedHadeeth = hadeeths[Random().nextInt(hadeeths.length)];

          final box = await Hive.openBox('daily_content');
          await box.put('last_hadeeth_id', selectedHadeeth.id);
          await box.put('last_hadeeth_title', selectedHadeeth.title);
          await box.put(
            'hadeeth_last_update',
            DateTime.now().millisecondsSinceEpoch,
          );

          if (mounted) {
            setState(() {
              randomHadeeth = selectedHadeeth;
              isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      debugPrint("Error loading random hadeeth: $e");
    }
  }

  void _shareHadeeth() {
    if (randomHadeeth != null) {
      final String shareContent =
          "حديث نبوي:\n${randomHadeeth!.title}\n\nتطبيق سبيل";
      Share.share(shareContent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFFC9A227); // لون ذهبي للأحاديث لتمييزها

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: isDark ? Colors.grey[900] : const Color(0xFFF9F9F9),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white10 : primaryColor.withOpacity(0.1),
            ),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'حديث اليوم',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: _loadRandomHadeeth,
                    tooltip: "حديث آخر",
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (isLoading)
                const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (randomHadeeth != null)
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/hadeth_detail',
                      arguments: randomHadeeth!.id,
                    );
                  },
                  child: Column(
                    children: [
                      Text(
                        randomHadeeth!.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "اضغط لقراءة الحديث كاملاً وشرحه",
                        style: TextStyle(
                          fontSize: 12,
                          color: primaryColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Text("تعذر تحميل حديث عشوائي"),
              const SizedBox(height: 16),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: _shareHadeeth,
                    icon: const Icon(Icons.share_outlined),
                    tooltip: "مشاركة",
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() => isFavorite = !isFavorite);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFavorite
                                ? "تمت الإضافة للمفضلة"
                                : "تمت الإزالة من المفضلة",
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                    ),
                    tooltip: "إضافة للمفضلة",
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text("تم الحفظ")));
                    },
                    icon: const Icon(Icons.bookmark_border),
                    tooltip: "حفظ",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
