class SurahDetail {
  final int number;
  final String nameAr;
  final String nameEn;
  final String nameTr;
  final String revelationPlace;
  final List<dynamic> ayahs;

  SurahDetail({
    required this.number,
    required this.nameAr,
    required this.nameEn,
    required this.nameTr,
    required this.revelationPlace,
    required this.ayahs,
  });

  factory SurahDetail.fromJson(Map<String, dynamic> json) {
    return SurahDetail(
      number: json["number"],
      nameAr: json["name"]["ar"],
      nameEn: json["name"]["en"],
      nameTr: json["name"]["transliteration"],
      revelationPlace: json["revelation_place"]["ar"],
      ayahs: json["verses"],
    );
  }
}
