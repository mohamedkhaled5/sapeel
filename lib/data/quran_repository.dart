import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sapeel/model/quran_ayah.dart';

class QuranRepository {
  static final QuranRepository _instance = QuranRepository._internal();
  factory QuranRepository() => _instance;
  QuranRepository._internal();

  List<QuranAyah> _ayahs = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  Future<void> init() async {
    if (_isLoaded) return;
    try {
      final String jsonString = await rootBundle.loadString('assets/data/quran.json');
      final List<dynamic> jsonData = jsonDecode(jsonString);
      _ayahs = jsonData.map((json) => QuranAyah.fromJson(json)).toList();
      _isLoaded = true;
    } catch (e) {
      print("Error loading quran.json: $e");
    }
  }

  List<QuranAyah> getAyahsByPage(int page) {
    return _ayahs.where((a) => a.page == page).toList();
  }

  QuranAyah? getPageStartAyah(int page) {
    final pageAyahs = getAyahsByPage(page);
    if (pageAyahs.isEmpty) return null;
    return pageAyahs.first;
  }

  QuranAyah? getPageEndAyah(int page) {
    final pageAyahs = getAyahsByPage(page);
    if (pageAyahs.isEmpty) return null;
    return pageAyahs.last;
  }

  String getSurahNameByPage(int page) {
    return getPageStartAyah(page)?.suraNameAr ?? "-";
  }

  Map<String, dynamic> getRangeMetadata(int startPage, int endPage) {
    final startAyah = getPageStartAyah(startPage);
    final endAyah = getPageEndAyah(endPage);

    if (startAyah == null || endAyah == null) {
      return {
        "surahRange": "-",
        "pageRange": "من صفحة $startPage إلى $endPage",
        "jozzRange": "-",
      };
    }

    return {
      "surahRange": "من سورة ${startAyah.suraNameAr} آية ${startAyah.ayaNo}\nإلى سورة ${endAyah.suraNameAr} آية ${endAyah.ayaNo}",
      "pageRange": startPage == endPage ? "صفحة $startPage" : "من صفحة $startPage إلى $endPage",
      "jozzRange": startAyah.jozz == endAyah.jozz ? "جزء ${startAyah.jozz}" : "من جزء ${startAyah.jozz} إلى ${endAyah.jozz}",
    };
  }
}
