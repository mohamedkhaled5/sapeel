import 'package:flutter/material.dart';
import 'package:sapeel/data/quran_api.dart';
import 'package:sapeel/model/surah_data_model.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sapeel/views/home/home_screen.dart';
import 'package:sapeel/views/quran_kareem/surah_detail.dart';

import 'package:sapeel/views/hosoon_khamsa/app_storage.dart';

/// شاشة الفهرس لعرض قائمة سور القرآن الكريم
class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  // المستقبل الذي سيحمل قائمة السور
  late Future<List<SurahData>> surahs;

  @override
  void initState() {
    super.initState();
    AppStorage.saveLastRoute('/al_quran');
    // جلب البيانات أوفلاين بالكامل
    surahs = fetchSurahs();
  }

  /// دالة لجلب البيانات أوفلاين
  Future<List<SurahData>> fetchSurahs() async {
    final data = await QuranService.getSurahs();
    return data.map<SurahData>((json) => SurahData.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
        title: const Text(
          "القرآن الكريم",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<SurahData>>(
        future: surahs,
        builder: (context, snapshot) {
          // حالة الانتظار (التحميل)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // حالة حدوث خطأ
          else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    "خطأ في تحميل البيانات",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // جلب المستقبل أولاً خارج setState
                      final Future<List<SurahData>> newSurahs = fetchSurahs();
                      setState(() {
                        surahs = newSurahs;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("إعادة المحاولة"),
                  ),
                ],
              ),
            );
          }
          // حالة عدم وجود بيانات
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("لم يتم العثور على سور"));
          }

          final surahList = snapshot.data!;

          // عرض قائمة السور
          return ListView.builder(
            itemCount: surahList.length,
            itemBuilder: (context, index) {
              final surah = surahList[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  onTap: () {
                    // الانتقال لصفحة تفاصيل السورة (المصحف)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SurahDetailScreen(surahNumber: surah.number),
                      ),
                    );
                  },
                  // اسم السورة بالعربي
                  title: Text(
                    surah.nameAr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  // معلومات إضافية (الترجمة ومكان النزول)
                  subtitle: Row(
                    children: [
                      Text(
                        "${surah.nameTr} - ${surah.revelationPlace}",
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 8),
                      // أيقونة مكان النزول (مكية/مدنية)
                      _buildRevelationIcon(surah.revelationPlace),
                    ],
                  ),
                  // رقم السورة في دائرة
                  trailing: CircleAvatar(
                    backgroundColor: const Color(0xFF1B5E20).withOpacity(0.1),
                    child: Text(
                      surah.number.toString(),
                      style: const TextStyle(
                        color: Color(0xFF1B5E20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// ويدجت لبناء أيقونة مكان النزول
  Widget _buildRevelationIcon(String place) {
    final isMeccan = place == "مكية";
    return SvgPicture.asset(
      isMeccan ? "assets/icons/kaaba.svg" : "assets/icons/mosque.svg",
      width: 18,
      height: 18,
      colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
    );
  }
}
