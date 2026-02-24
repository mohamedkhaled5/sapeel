import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sapeel/model/surah_detail_model.dart';

/// خدمة التعامل مع API القرآن الكريم
class QuranService {
  // الرابط الأساسي للـ API
  static const String baseUrl = "https://quran.i8x.net/api";

  /// جلب قائمة جميع السور
  static Future<List<dynamic>> getSurahs() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/surahs"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["result"];
      } else {
        throw Exception("فشل في تحميل السور: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("خطأ في الاتصال بالإنترنت: $e");
    }
  }

  /// جلب تفاصيل سورة محددة (الآيات، الصفحات، إلخ)
  /// [surahNumber] رقم السورة المطلوب جلبها
  static Future<SurahDetail> getSurahDetail(int surahNumber) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/surah/$surahNumber"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SurahDetail.fromJson(data["result"]);
      } else {
        throw Exception("فشل في تحميل تفاصيل السورة: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("خطأ في الاتصال بالإنترنت: $e");
    }
  }
}
