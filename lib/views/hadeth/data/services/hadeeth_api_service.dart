import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/category_model.dart';
import '../models/hadeeth_list_item.dart';
import '../models/hadeeth_detail.dart';

class HadeethApiService {
  static const String baseUrl = "https://hadeethenc.com/api/v1";

  /// =============================
  /// 1️⃣ Fetch Categories
  /// =============================
  Future<List<CategoryModel>> fetchCategories(String language) async {
    final response = await http.get(
      Uri.parse("$baseUrl/categories/list/?language=$language"),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => CategoryModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load categories");
    }
  }

  /// =============================
  /// 2️⃣ Fetch Hadeeth List
  /// =============================
  Future<List<HadeethListItem>> fetchHadeethList({
    required String language,
    required String categoryId,
  }) async {
    final response = await http.get(
      Uri.parse(
        "$baseUrl/hadeeths/list/?language=$language&category_id=$categoryId",
      ),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      final List data = decoded['data']; // 👈 هنا التصحيح

      return data.map((e) => HadeethListItem.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load hadeeth list");
    }
  }

  /// =============================
  /// 3️⃣ Fetch Hadeeth Detail
  /// =============================
  Future<HadeethDetail> fetchHadeethDetail({
    required String id,
    required String language,
  }) async {
    final response = await http.get(
      Uri.parse("$baseUrl/hadeeths/one/?language=$language&id=$id"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return HadeethDetail.fromJson(data);
    } else {
      throw Exception("Failed to load hadeeth detail");
    }
  }
}
