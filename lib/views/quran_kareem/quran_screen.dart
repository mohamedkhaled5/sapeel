import 'package:flutter/material.dart';
import 'package:sapeel/data/quran_api.dart';
import 'package:sapeel/model/surah_data_model.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sapeel/views/quran_kareem/surah_detail.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  late Future<List<SurahData>> surahs;

  @override
  void initState() {
    super.initState();
    surahs = fetchSurahs();
  }

  Future<List<SurahData>> fetchSurahs() async {
    final data = await QuranService.getSurahs();
    return data.map<SurahData>((json) => SurahData.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Al Quran")),
      body: FutureBuilder<List<SurahData>>(
        future: surahs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading data"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No surahs found"));
          }

          final surahList = snapshot.data!;

          return ListView.builder(
            itemCount: surahList.length,
            itemBuilder: (context, index) {
              final surah = surahList[index];

              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SurahDetailScreen(surahNumber: surah.number),
                    ),
                  );
                },

                title: Text(surah.nameAr, textDirection: TextDirection.rtl),
                subtitle: Row(
                  children: [
                    Text(
                      "${surah.nameTr} - ${surah.revelationPlace}",
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 4),

                    surah.revelationPlace == "مكية"
                        ? SvgPicture.asset(
                            "assets/icons/kaaba.svg",
                            width: 20,
                            height: 20,
                          )
                        : SvgPicture.asset(
                            "assets/icons/mosque.svg",
                            width: 20,
                            height: 20,
                          ),
                  ],
                ),

                trailing: CircleAvatar(child: Text(surah.number.toString())),
                // leading: CircleAvatar(child: Text(surah.number.toString())),
              );
            },
          );
        },
      ),
    );
  }
}
