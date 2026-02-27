import 'package:quran/quran.dart' as quran;
import 'package:sapeel/model/surah_detail_model.dart';

/// خدمة التعامل مع بيانات القرآن الكريم (أوفلاين بالكامل)
class QuranService {
  /// جلب قائمة جميع السور
  static Future<List<dynamic>> getSurahs() async {
    List<Map<String, dynamic>> surahs = [];
    for (int i = 1; i <= 114; i++) {
      surahs.add({
        "number": i,
        "name": {
          "ar": quran.getSurahNameArabic(i),
          "en": quran.getSurahName(i),
          "transliteration": quran.getSurahName(i),
        },
        "revelation_place": {
          "ar": quran.getPlaceOfRevelation(i) == "Makkah" ? "مكية" : "مدنية",
        },
      });
    }
    return surahs;
  }

  /// جلب تفاصيل سورة محددة (الآيات، الصفحات، إلخ)
  /// [surahNumber] رقم السورة المطلوب جلبها
  static Future<SurahDetail> getSurahDetail(int surahNumber) async {
    List<Map<String, dynamic>> verses = [];
    int verseCount = quran.getVerseCount(surahNumber);

    for (int i = 1; i <= verseCount; i++) {
      verses.add({
        "number": i,
        "text": {"ar": quran.getVerse(surahNumber, i, verseEndSymbol: false)},
        "page": quran.getPageNumber(surahNumber, i),
      });
    }

    return SurahDetail(
      number: surahNumber,
      nameAr: quran.getSurahNameArabic(surahNumber),
      nameEn: quran.getSurahName(surahNumber),
      nameTr: quran.getSurahName(surahNumber),
      revelationPlace: quran.getPlaceOfRevelation(surahNumber) == "Makkah"
          ? "مكية"
          : "مدنية",
      ayahs: verses,
    );
  }
}
