import 'package:flutter/material.dart';
import 'package:sapeel/data/quran_api.dart';
import 'package:sapeel/model/surah_detail_model.dart';
import 'package:sapeel/views/screens/mushaf_screen.dart';

class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;

  const SurahDetailScreen({super.key, required this.surahNumber});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  late Future<SurahDetail> surahFuture;
  bool _navigated = false; // علشان مايفتحش أكتر من مرة

  @override
  void initState() {
    super.initState();
    surahFuture = QuranService.getSurahDetail(widget.surahNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<SurahDetail>(
        future: surahFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Error loading surah"));
          }

          final surah = snapshot.data!;
          final int firstPage = surah.ayahs.first["page"];

          // 👇 نعمل انتقال تلقائي مرة واحدة بس
          if (!_navigated) {
            _navigated = true;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => MushafScreen(
                    initialPage: firstPage,
                    verses: surah.ayahs,
                    // surahName: surah.nameAr,
                    initialJuz: surah.ayahs.first["juz"],
                  ),
                ),
              );
            });
          }

          return const SizedBox(); // شاشة فاضية لحين الانتقال
        },
      ),
    );
  }
}
