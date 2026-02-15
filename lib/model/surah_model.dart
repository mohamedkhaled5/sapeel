class Surah {
  final int number;
  final String nameAr;
  final String nameEn;
  final String nameTr;
  final String revelationPlace;
  Surah({
    required this.number,
    required this.nameAr,
    required this.nameEn,
    required this.nameTr,
    required this.revelationPlace,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json["number"],
      nameAr: json["name"]["ar"],
      nameEn: json["name"]["en"],
      nameTr: json["name"]["transliteration"],
      revelationPlace: json["revelation_place"]["ar"],
    );
  }
}
