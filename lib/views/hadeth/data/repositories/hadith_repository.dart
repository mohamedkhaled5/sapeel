import '../services/dorar_api_service.dart';
import '../models/hadith_models.dart';
import '../../domain/repositories/hadith_repository_interface.dart';

class HadithRepository implements IHadithRepository {
  final DorarApiService _apiService;
  
  // Memory Cache
  final Map<String, dynamic> _cache = {};

  HadithRepository({DorarApiService? apiService}) 
      : _apiService = apiService ?? DorarApiService();

  @override
  Future<APIHadithSearchResponse> searchApiHadith({
    required String value,
    int page = 1,
    bool removeHtml = true,
  }) async {
    final cacheKey = 'api_search_${value}_${page}_$removeHtml';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey];

    final result = await _apiService.searchApiHadith(
      value: value,
      page: page,
      removeHtml: removeHtml,
    );
    _cache[cacheKey] = result;
    return result;
  }

  @override
  Future<SiteHadithSearchResponse> searchSiteHadith({
    required String value,
    int page = 1,
    bool removeHtml = true,
    String? st,
    String? t,
    List<int>? d,
    List<int>? m,
    List<int>? s,
    List<int>? rawi,
  }) async {
    final cacheKey = 'site_search_${value}_${page}_${d?.join(",")}_${m?.join(",")}_${s?.join(",")}_${rawi?.join(",")}';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey];

    final result = await _apiService.searchSiteHadith(
      value: value,
      page: page,
      removeHtml: removeHtml,
      st: st,
      t: t,
      d: d,
      m: m,
      s: s,
      rawi: rawi,
    );
    _cache[cacheKey] = result;
    return result;
  }

  @override
  Future<SiteSingleHadithResponse> getHadithById(String id) => _apiService.getHadithById(id);

  @override
  Future<SiteSimilarHadithResponse> getSimilarHadith(String id) => _apiService.getSimilarHadith(id);

  @override
  Future<SiteAlternateHadithResponse> getAlternateHadith(String id) async => throw UnimplementedError();

  @override
  Future<SiteUsulHadithResponse> getUsulHadith(String id) async => throw UnimplementedError();
}
