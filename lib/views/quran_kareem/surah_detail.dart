import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sapeel/data/quran_api.dart';
import 'package:sapeel/data/mushaf_service.dart';
import 'package:sapeel/model/surah_detail_model.dart';
import 'package:sapeel/utils/quran_metadata.dart';

/// شاشة تفاصيل السورة: تدمج بين عرض المصحف (صور) وعرض الآيات (نص)
class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;

  const SurahDetailScreen({super.key, required this.surahNumber});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  // --- البيانات والحالة ---
  late Future<SurahDetail> surahFuture;
  bool isTextMode = true; // الافتراضي هو وضع النص (أوفلاين بالكامل)

  // --- حالة وضع الصور (المصحف) ---
  bool isLoadingMushaf = true;
  bool isDownloading = false;
  double downloadProgress = 0;
  String? mushafPath;
  late PageController _pageController;
  int currentPage = 1;
  int currentJuz = 1;
  String currentSurahName = "";

  @override
  void initState() {
    super.initState();
    // جلب بيانات السورة (الآن أوفلاين بالكامل)
    surahFuture = QuranService.getSurahDetail(widget.surahNumber);
    _checkMushafStatus();
  }

  /// التحقق من حالة تحميل المصحف
  Future<void> _checkMushafStatus() async {
    final downloaded = await MushafService.isDownloaded();
    if (downloaded) {
      mushafPath = await MushafService.getMushafPath();
      isTextMode = false; // لو الصور موجودة، نظهرها
    } else {
      isTextMode = true; // لو الصور مش موجودة، نظهر النص تلقائياً (أوفلاين)
    }
    if (mounted) {
      setState(() {
        isLoadingMushaf = false;
      });
    }
  }

  /// بدء تحميل المصحف باستخدام الخدمة المخصصة
  Future<void> _startDownload() async {
    setState(() {
      isDownloading = true;
      downloadProgress = 0;
    });

    try {
      await MushafService.downloadMushaf((p) {
        if (mounted) setState(() => downloadProgress = p);
      });
      mushafPath = await MushafService.getMushafPath();
      if (mounted) setState(() => isDownloading = false);
    } catch (e) {
      if (mounted) {
        setState(() => isDownloading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("خطأ أثناء التحميل: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SurahDetail>(
      future: surahFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text("خطأ")),
            body: Center(child: Text("فشل في تحميل السورة: ${snapshot.error}")),
          );
        }

        final surah = snapshot.data!;

        // إعداد البيانات الأولية عند تحميل السورة لأول مرة
        if (currentSurahName.isEmpty) {
          currentPage = surah.ayahs.first["page"];
          currentJuz = QuranMetadata.getJuzByPage(currentPage);
          currentSurahName = QuranMetadata.getSurahNameByPage(currentPage);
          _pageController = PageController(initialPage: currentPage - 1);
        }

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                // العودة لصفحة الفهرس
                Navigator.pop(context);
              },
            ),
            title: Column(
              children: [
                Text(
                  isTextMode ? surah.nameAr : currentSurahName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isTextMode)
                  Text(
                    "صفحة $currentPage | جزء $currentJuz",
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
            actions: [
              // زر التبديل بين الصور والنص
              IconButton(
                icon: Icon(isTextMode ? Icons.image : Icons.text_snippet),
                onPressed: () => setState(() => isTextMode = !isTextMode),
                tooltip: isTextMode ? "عرض الصور" : "عرض النص",
              ),
            ],
          ),
          body: isTextMode ? _buildTextView(surah) : _buildMushafView(),
        );
      },
    );
  }

  /// واجهة عرض النص (الآيات)
  Widget _buildTextView(SurahDetail surah) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: surah.ayahs.length,
      itemBuilder: (context, index) {
        final ayah = surah.ayahs[index];
        final text = ayah["text"]["ar"];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            "$text ﴿${index + 1}﴾",
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 22,
              height: 1.8,
              fontFamily: 'Amiri',
            ),
          ),
        );
      },
    );
  }

  /// واجهة عرض المصحف (الصور)
  Widget _buildMushafView() {
    if (isLoadingMushaf) {
      return const Center(child: CircularProgressIndicator());
    }

    // حالة عدم التحميل
    if (mushafPath == null) {
      return Center(
        child: isDownloading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("جاري تحميل المصحف..."),
                  const SizedBox(height: 20),
                  CircularProgressIndicator(value: downloadProgress),
                  const SizedBox(height: 10),
                  Text("${(downloadProgress * 100).toStringAsFixed(0)}%"),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.image_not_supported_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "وضع المصحف (الصور) يحتاج للتحميل لمرة واحدة فقط\nالنص متاح حالياً أوفلاين",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _startDownload,
                    icon: const Icon(Icons.download),
                    label: const Text("تحميل صور المصحف (150MB)"),
                  ),
                ],
              ),
      );
    }

    // عرض الصفحات
    return Directionality(
      textDirection: TextDirection.rtl,
      child: PageView.builder(
        controller: _pageController,
        itemCount: 604,
        onPageChanged: (i) {
          int newPage = i + 1;
          setState(() {
            currentPage = newPage;
            currentJuz = QuranMetadata.getJuzByPage(newPage);
            currentSurahName = QuranMetadata.getSurahNameByPage(newPage);
          });
        },
        itemBuilder: (context, i) {
          final pageNum = (i + 1).toString().padLeft(3, '0');
          return InteractiveViewer(
            child: Image.file(
              File("$mushafPath/$pageNum.png"),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Center(child: Text("خطأ في عرض الصفحة")),
            ),
          );
        },
      ),
    );
  }
}
