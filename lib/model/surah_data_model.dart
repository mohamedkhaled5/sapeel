class SurahData {
  final int number;
  final String nameAr;
  final String nameEn;
  final String nameTr;
  final String revelationPlace;
  SurahData({
    required this.number,
    required this.nameAr,
    required this.nameEn,
    required this.nameTr,
    required this.revelationPlace,
  });

  factory SurahData.fromJson(Map<String, dynamic> json) {
    return SurahData(
      number: json["number"],
      nameAr: json["name"]["ar"],
      nameEn: json["name"]["en"],
      nameTr: json["name"]["transliteration"],
      revelationPlace: json["revelation_place"]["ar"],
    );
  }
}
