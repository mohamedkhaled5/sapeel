import 'package:sapeel/views/hadeth/data/models/hadith_models.dart';

abstract class IHadithRepository {
  Future<APIHadithSearchResponse> searchApiHadith({
    required String value,
    int page = 1,
    bool removeHtml = true,
  });

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
  });

  Future<SiteSingleHadithResponse> getHadithById(String id);
  Future<SiteSimilarHadithResponse> getSimilarHadith(String id);
  Future<SiteAlternateHadithResponse> getAlternateHadith(String id);
  Future<SiteUsulHadithResponse> getUsulHadith(String id);
}
