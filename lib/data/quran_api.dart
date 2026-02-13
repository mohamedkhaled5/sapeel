import 'dart:convert';
import 'package:http/http.dart' as http;

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
}
