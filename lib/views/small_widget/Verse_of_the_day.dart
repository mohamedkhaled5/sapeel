import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:share_plus/share_plus.dart';
import 'dart:math';
import 'dart:async';
import 'package:hive/hive.dart';

class VerseOfTheDay extends StatefulWidget {
  const VerseOfTheDay({super.key});

  @override
  State<VerseOfTheDay> createState() => _VerseOfTheDayState();
}

class _VerseOfTheDayState extends State<VerseOfTheDay> {
  int surahNumber = 1;
  int ayahNumber = 1;
  bool _isLoading = true;
  bool isFavorite = false;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadOrGenerateVerse();
    // إعداد مؤقت للتحقق كل دقيقة إذا كان قد مر 5 ساعات
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAndRefreshVerse();
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadOrGenerateVerse() async {
    setState(() => _isLoading = true);
    final box = await Hive.openBox('daily_content');
    final lastUpdate = box.get('verse_last_update', defaultValue: 0);
    final now = DateTime.now().millisecondsSinceEpoch;

    // إذا مر أكثر من 5 ساعات (5 * 60 * 60 * 1000 مللي ثانية)
    if (now - lastUpdate > 5 * 60 * 60 * 1000) {
      _generateRandomVerse();
    } else {
      if (mounted) {
        setState(() {
          surahNumber = box.get('last_surah', defaultValue: 1);
          ayahNumber = box.get('last_ayah', defaultValue: 1);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkAndRefreshVerse() async {
    final box = await Hive.openBox('daily_content');
    final lastUpdate = box.get('verse_last_update', defaultValue: 0);
    final now = DateTime.now().millisecondsSinceEpoch;

    if (now - lastUpdate > 5 * 60 * 60 * 1000) {
      _generateRandomVerse();
    }
  }

  void _generateRandomVerse() async {
    if (mounted && !_isLoading) setState(() => _isLoading = true);

    final random = Random();
    final newSurahNumber = random.nextInt(114) + 1;
    int verseCount = quran.getVerseCount(newSurahNumber);
    final newAyahNumber = random.nextInt(verseCount) + 1;

    final box = await Hive.openBox('daily_content');
    await box.put('last_surah', newSurahNumber);
    await box.put('last_ayah', newAyahNumber);
    await box.put('verse_last_update', DateTime.now().millisecondsSinceEpoch);

    if (mounted) {
      setState(() {
        surahNumber = newSurahNumber;
        ayahNumber = newAyahNumber;
        _isLoading = false;
      });
    }
  }

  void _shareVerse() {
    final String verseText = quran.getVerse(
      surahNumber,
      ayahNumber,
      verseEndSymbol: true,
    );
    final String surahName = quran.getSurahNameArabic(surahNumber);
    final String shareContent =
        "﴿$verseText﴾\n\n[سورة $surahName : آية $ayahNumber]\nتطبيق سبيل";
    Share.share(shareContent);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF1B5E20);

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
          child: _isLoading
              ? const SizedBox(
                  height: 150,
                  child: Center(child: CircularProgressIndicator()),
                )
              : Column(
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
                            'آية اليوم',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 20),
                          onPressed: _generateRandomVerse,
                          tooltip: "آية أخرى",
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      quran.getVerse(
                        surahNumber,
                        ayahNumber,
                        verseEndSymbol: true,
                      ),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Amiri',
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'سورة ${quran.getSurahNameArabic(surahNumber)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '| الآية $ayahNumber',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white60 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: _shareVerse,
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("تم الحفظ")),
                            );
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
