import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';

class PrayerService {
  static const boxName = "prayer_settings";

  /// قائمة بالمدن العربية الرئيسية (Offline Fallback)
  static final Map<String, Coordinates> cityCoordinates = {
    "القاهرة": Coordinates(30.0444, 31.2357),
    "مكة المكرمة": Coordinates(21.4225, 39.8262),
    "المدينة المنورة": Coordinates(24.4672, 39.6111),
    "الرياض": Coordinates(24.7136, 46.6753),
    "دبي": Coordinates(25.2048, 55.2708),
    "عمان": Coordinates(31.9454, 35.9284),
    "الدوحة": Coordinates(25.2854, 51.5310),
    "الكويت": Coordinates(29.3759, 47.9774),
    "المنامة": Coordinates(26.2285, 50.5860),
    "مسقط": Coordinates(23.5859, 58.4059),
    "بغداد": Coordinates(33.3152, 44.3661),
    "دمشق": Coordinates(33.5138, 36.2765),
    "بيروت": Coordinates(33.8938, 35.5018),
    "القدس": Coordinates(31.7683, 35.2137),
    "تونس": Coordinates(36.8065, 10.1815),
    "الجزائر": Coordinates(36.7538, 3.0588),
    "الرباط": Coordinates(34.0209, -6.8416),
    "طرابلس": Coordinates(32.8872, 13.1913),
    "صنعاء": Coordinates(15.3694, 44.1910),
  };

  /// حفظ إعدادات الصلاة
  static Future<void> saveSettings({
    CalculationMethod? method,
    Madhab? madhab,
    String? city,
    bool? autoLocation,
  }) async {
    final box = await Hive.openBox(boxName);
    if (method != null) await box.put("method", method.name);
    if (madhab != null) await box.put("madhab", madhab.name);
    if (city != null) await box.put("city", city);
    if (autoLocation != null) await box.put("autoLocation", autoLocation);
  }

  /// استرجاع إعدادات الصلاة
  static Future<Map<String, dynamic>> getSettings() async {
    final box = await Hive.openBox(boxName);
    return {
      "method": box.get("method", defaultValue: "egyptian"),
      "madhab": box.get("madhab", defaultValue: "shafi"),
      "city": box.get("city", defaultValue: "القاهرة"),
      "autoLocation": box.get("autoLocation", defaultValue: true),
    };
  }

  /// جلب أوقات الصلاة بناءً على الإعدادات الحالية
  static Future<PrayerTimes> getPrayerTimes() async {
    final settings = await getSettings();
    final bool autoLocation = settings["autoLocation"];

    Coordinates coords;

    if (autoLocation) {
      try {
        Position position = await _determinePosition();
        coords = Coordinates(position.latitude, position.longitude);
      } catch (e) {
        // لو فشل الـ GPS، نستخدم المدينة المختارة كـ fallback
        coords =
            cityCoordinates[settings["city"]] ?? cityCoordinates["القاهرة"]!;
      }
    } else {
      coords = cityCoordinates[settings["city"]] ?? cityCoordinates["القاهرة"]!;
    }

    final params = _getMethodFromName(settings["method"]).getParameters();
    params.madhab = _getMadhabFromName(settings["madhab"]);

    final dateComponents = DateComponents.from(DateTime.now());
    return PrayerTimes(coords, dateComponents, params);
  }

  static CalculationMethod _getMethodFromName(String name) {
    return CalculationMethod.values.firstWhere(
      (e) => e.name == name,
      orElse: () => CalculationMethod.egyptian,
    );
  }

  static Madhab _getMadhabFromName(String name) {
    return Madhab.values.firstWhere(
      (e) => e.name == name,
      orElse: () => Madhab.shafi,
    );
  }

  /// تحديد الصلاة القادمة والعد التنازلي
  static Duration getCountdown(PrayerTimes prayerTimes) {
    final nextPrayer = prayerTimes.nextPrayer();
    final nextPrayerTime = prayerTimes.timeForPrayer(nextPrayer);
    if (nextPrayerTime == null) return Duration.zero;
    return nextPrayerTime.difference(DateTime.now());
  }

  /// التأكد من صلاحيات الموقع
  static Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('خدمة الموقع غير مفعلة.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('صلاحية الموقع مرفوضة.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('صلاحية الموقع مرفوضة بشكل دائم.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );
  }
}
