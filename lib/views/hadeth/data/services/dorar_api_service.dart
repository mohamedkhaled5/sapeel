import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/hadith_models.dart';
import '../models/sharh_models.dart';
import '../models/lookup_models.dart';
import '../models/common_models.dart';

class DorarApiException implements Exception {
  final String message;
  final int? statusCode;

  DorarApiException(this.message, {this.statusCode});

  @override
  String toString() => 'DorarApiException: $message (Status: $statusCode)';
}

class DorarApiService {
  static final String _baseUrl = Platform.isAndroid
      ? 'http://10.0.2.2:5000'
      : 'http://localhost:5000';

  Future<T> _get<T>(
    String path,
    Map<String, dynamic> queryParams,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl$path',
      ).replace(queryParameters: _buildQueryParams(queryParams));

      final response = await http.get(uri).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return fromJson(decoded);
      } else {
        throw DorarApiException(
          'خطأ من السيرفر',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw DorarApiException(
        'تعذر الاتصال بالسيرفر، تأكد من تشغيل Node.js API',
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, String> _buildQueryParams(Map<String, dynamic> params) {
    final Map<String, String> query = {};
    params.forEach((key, value) {
      if (value != null) {
        if (value is List) {
          for (var i = 0; i < value.length; i++) {
            query['$key[$i]'] = value[i].toString();
          }
        } else {
          query[key] = value.toString();
        }
      }
    });
    return query;
  }

  // --- Hadith Endpoints ---

  Future<APIHadithSearchResponse> searchApiHadith({
    required String value,
    int page = 1,
    bool removeHtml = true,
  }) {
    return _get(
      '/v1/api/hadith/search',
      {'value': value, 'page': page, 'removehtml': removeHtml},
      (json) => APIHadithSearchResponse.fromJson(
        json,
        (data) => (data as List).map((i) => APIHadithItem.fromJson(i)).toList(),
      ),
    );
  }

  Future<SiteHadithSearchResponse> searchSiteHadith({
    required String value,
    int page = 1,
    bool removeHtml = true,
    String? st, // w, a, p
    String? t, // *, 0, 1, 2, 3
    List<int>? d, // degrees
    List<int>? m, // mohdith
    List<int>? s, // book
    List<int>? rawi,
  }) {
    return _get(
      '/v1/site/hadith/search',
      {
        'value': value,
        'page': page,
        'removehtml': removeHtml,
        'st': st,
        't': t,
        'd': d,
        'm': m,
        's': s,
        'rawi': rawi,
      },
      (json) => SiteHadithSearchResponse.fromJson(
        json,
        (data) =>
            (data as List).map((i) => SiteHadithItem.fromJson(i)).toList(),
      ),
    );
  }

  Future<SiteSingleHadithResponse> getHadithById(String id) {
    return _get(
      '/v1/site/hadith/$id',
      {},
      (json) => SiteSingleHadithResponse.fromJson(
        json,
        (data) => SiteHadithItem.fromJson(data),
      ),
    );
  }

  Future<SiteSimilarHadithResponse> getSimilarHadith(String id) {
    return _get(
      '/v1/site/hadith/similar/$id',
      {},
      (json) => SiteSimilarHadithResponse.fromJson(
        json,
        (data) =>
            (data as List).map((i) => SiteHadithItem.fromJson(i)).toList(),
      ),
    );
  }

  // --- Sharh Endpoints ---

  Future<SharhSearchResponse> searchSharh({
    required String value,
    int page = 1,
  }) {
    return _get(
      '/v1/site/sharh/search',
      {'value': value, 'page': page},
      (json) => SharhSearchResponse.fromJson(
        json,
        (data) => (data as List).map((i) => SharhItem.fromJson(i)).toList(),
      ),
    );
  }

  Future<SharhResponse> getSharhById(String id) {
    return _get(
      '/v1/site/sharh/$id',
      {},
      (json) =>
          SharhResponse.fromJson(json, (data) => SharhItem.fromJson(data)),
    );
  }

  // --- Data Lookups ---

  Future<DataResponse> getBooks() => _get(
    '/v1/data/book',
    {},
    (json) => DataResponse.fromJson(
      json,
      (data) => (data as List).map((i) => LookupItem.fromJson(i)).toList(),
    ),
  );

  Future<DataResponse> getDegrees() => _get(
    '/v1/data/degree',
    {},
    (json) => DataResponse.fromJson(
      json,
      (data) => (data as List).map((i) => LookupItem.fromJson(i)).toList(),
    ),
  );

  Future<DataResponse> getMohdithList() => _get(
    '/v1/data/mohdith',
    {},
    (json) => DataResponse.fromJson(
      json,
      (data) => (data as List).map((i) => LookupItem.fromJson(i)).toList(),
    ),
  );

  Future<DataResponse> getRawiList() => _get(
    '/v1/data/rawi',
    {},
    (json) => DataResponse.fromJson(
      json,
      (data) => (data as List).map((i) => LookupItem.fromJson(i)).toList(),
    ),
  );
}
