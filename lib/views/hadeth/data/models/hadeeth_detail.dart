import 'word_meaning.dart';

class HadeethDetail {
  final String id;
  final String title;
  final String hadeeth;
  final String? attribution;
  final String? grade;
  final String? explanation;
  final List<String>? hints;
  final List<String>? categories;
  final List<String>? translations;
  final List<WordMeaning>? wordsMeanings;
  final String? reference;

  HadeethDetail({
    required this.id,
    required this.title,
    required this.hadeeth,
    this.attribution,
    this.grade,
    this.explanation,
    this.hints,
    this.categories,
    this.translations,
    this.wordsMeanings,
    this.reference,
  });

  factory HadeethDetail.fromJson(Map<String, dynamic> json) {
    return HadeethDetail(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      hadeeth: json['hadeeth'] ?? '',
      attribution: json['attribution'],
      grade: json['grade'],
      explanation: json['explanation'],
      hints: json['hints'] != null ? List<String>.from(json['hints']) : null,
      categories: json['categories'] != null
          ? List<String>.from(json['categories'].map((e) => e.toString()))
          : null,
      translations: json['translations'] != null
          ? List<String>.from(json['translations'])
          : null,
      wordsMeanings: json['words_meanings'] != null
          ? (json['words_meanings'] as List)
                .map((e) => WordMeaning.fromJson(e))
                .toList()
          : null,
      reference: json['reference'],
    );
  }
}
