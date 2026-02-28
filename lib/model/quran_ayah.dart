class QuranAyah {
  final int suraNo;
  final String suraNameAr;
  final int jozz;
  final int page;
  final int ayaNo;
  final String text;
  final String textEmlaey;

  QuranAyah({
    required this.suraNo,
    required this.suraNameAr,
    required this.jozz,
    required this.page,
    required this.ayaNo,
    required this.text,
    required this.textEmlaey,
  });

  factory QuranAyah.fromJson(Map<String, dynamic> json) {
    return QuranAyah(
      suraNo: json['sura_no'],
      suraNameAr: json['sura_name_ar'],
      jozz: json['jozz'],
      page: json['page'],
      ayaNo: json['aya_no'],
      text: json['aya_text'],
      textEmlaey: json['aya_text_emlaey'],
    );
  }
}
