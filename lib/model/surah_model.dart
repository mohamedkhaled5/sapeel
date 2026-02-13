class Surah {
  final int number;
  final String nameAr;
  final String nameEn;

  Surah({required this.number, required this.nameAr, required this.nameEn});

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json["number"],
      nameAr: json["name"]["ar"],
      nameEn: json["name"]["en"],
    );
  }
}
