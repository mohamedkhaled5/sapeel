import 'package:flutter/material.dart';
import 'package:sapeel/data/quran_api.dart';
import 'package:sapeel/model/surah_detail_model.dart';

class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;

  const SurahDetailScreen({super.key, required this.surahNumber});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  late Future<SurahDetail> surahFuture;

  @override
  void initState() {
    super.initState();
    surahFuture = QuranService.getSurahDetail(widget.surahNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Surah Details")),
      body: FutureBuilder<SurahDetail>(
        future: surahFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading surah"));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No surah data"));
          }

          final surah = snapshot.data!;

          final fullSurahText = surah.ayahs
              .asMap()
              .entries
              .map((entry) {
                final index = entry.key;
                final ayah = entry.value as Map<String, dynamic>;
                final text =
                    (ayah["text"] as Map<String, dynamic>)["ar"] as String;

                return "$text ﴿${index + 1}﴾";
              })
              .join(" ");

          return Container(
            color: const Color(0xFFF8F5EC), // لون ورق مصحف خفيف
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  // اسم السورة
                  Text(
                    surah.nameAr,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Amiri",
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // البسملة (مش بتظهر في التوبة)
                  if (surah.number != 9)
                    const Text(
                      "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                      style: TextStyle(fontSize: 24, fontFamily: "Amiri"),
                      textAlign: TextAlign.center,
                    ),

                  const SizedBox(height: 24),

                  // نص السورة
                  Text(
                    fullSurahText,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 24,
                      height: 2.2,
                      fontFamily: "Amiri",
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
