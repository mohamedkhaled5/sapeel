import 'common_models.dart';

class SharhItem {
  final String id;
  final String hadith;
  final String? sharh;
  final String? mohdith;
  final String? book;
  final String? grade;

  SharhItem({
    required this.id,
    required this.hadith,
    this.sharh,
    this.mohdith,
    this.book,
    this.grade,
  });

  factory SharhItem.fromJson(Map<String, dynamic> json) {
    return SharhItem(
      id: json['id']?.toString() ?? '',
      hadith: json['hadith'] ?? '',
      sharh: json['sharh'],
      mohdith: json['mohdith'],
      book: json['book'],
      grade: json['grade'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'hadith': hadith,
    'sharh': sharh,
    'mohdith': mohdith,
    'book': book,
    'grade': grade,
  };
}

typedef SharhResponse = SuccessWrapper<SharhItem>;
typedef SharhSearchResponse = SuccessWrapper<List<SharhItem>>;
