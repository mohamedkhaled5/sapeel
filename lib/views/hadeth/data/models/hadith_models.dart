import 'common_models.dart';

class APIHadithItem {
  final String hadith;
  final String rawi;
  final String mohdith;
  final String book;
  final String numberOrPage;
  final String grade;

  APIHadithItem({
    required this.hadith,
    required this.rawi,
    required this.mohdith,
    required this.book,
    required this.numberOrPage,
    required this.grade,
  });

  factory APIHadithItem.fromJson(Map<String, dynamic> json) {
    return APIHadithItem(
      hadith: json['hadith'] ?? '',
      rawi: json['rawi'] ?? '',
      mohdith: json['mohdith'] ?? '',
      book: json['book'] ?? '',
      numberOrPage: json['numberOrPage'] ?? '',
      grade: json['grade'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'hadith': hadith,
    'rawi': rawi,
    'mohdith': mohdith,
    'book': book,
    'numberOrPage': numberOrPage,
    'grade': grade,
  };
}

class SiteHadithItem {
  final String id;
  final String hadith;
  final String rawi;
  final String mohdith;
  final String book;
  final String numberOrPage;
  final String grade;
  final String? takhrij;
  final String? sharh;

  SiteHadithItem({
    required this.id,
    required this.hadith,
    required this.rawi,
    required this.mohdith,
    required this.book,
    required this.numberOrPage,
    required this.grade,
    this.takhrij,
    this.sharh,
  });

  factory SiteHadithItem.fromJson(Map<String, dynamic> json) {
    return SiteHadithItem(
      id: json['id']?.toString() ?? '',
      hadith: json['hadith'] ?? '',
      rawi: json['rawi'] ?? '',
      mohdith: json['mohdith'] ?? '',
      book: json['book'] ?? '',
      numberOrPage: json['numberOrPage'] ?? '',
      grade: json['grade'] ?? '',
      takhrij: json['takhrij'],
      sharh: json['sharh'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'hadith': hadith,
    'rawi': rawi,
    'mohdith': mohdith,
    'book': book,
    'numberOrPage': numberOrPage,
    'grade': grade,
    'takhrij': takhrij,
    'sharh': sharh,
  };
}

typedef APIHadithSearchResponse = SuccessWrapper<List<APIHadithItem>>;
typedef SiteHadithSearchResponse = SuccessWrapper<List<SiteHadithItem>>;
typedef SiteSingleHadithResponse = SuccessWrapper<SiteHadithItem>;
typedef SiteSimilarHadithResponse = SuccessWrapper<List<SiteHadithItem>>;
typedef SiteAlternateHadithResponse = SuccessWrapper<List<SiteHadithItem>>;
typedef SiteUsulHadithResponse = SuccessWrapper<List<SiteHadithItem>>;
