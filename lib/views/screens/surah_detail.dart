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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: surah.ayahs.length,
            itemBuilder: (context, index) {
              final ayah = surah.ayahs[index] as Map<String, dynamic>;
              final text =
                  (ayah["text"] as Map<String, dynamic>)["ar"] as String;
              final ayahNumberInSurah = index + 1;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "﴾$text﴿ $ayahNumberInSurah",
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 20, height: 1.8),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
