import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sapeel/model/surah_detail_model.dart';

class QuranService {
  static const String baseUrl = "https://quran.i8x.net/api";

  static Future<List<dynamic>> getSurahs() async {
    final response = await http.get(Uri.parse("$baseUrl/surahs"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["result"];
    } else {
      throw Exception("Failed to load surahs");
    }
  }

  static Future<SurahDetail> getSurahDetail(int surahNumber) async {
    final response = await http.get(Uri.parse("$baseUrl/surah/$surahNumber"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return SurahDetail.fromJson(data["result"]);
    } else {
      throw Exception("Failed to load surah detail");
    }
  }
}
