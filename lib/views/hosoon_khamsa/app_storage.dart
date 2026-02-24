import 'package:hive/hive.dart';

class AppStorage {
  static const boxName = "memorization_box";

  static Future saveStartPage(int page) async {
    final box = await Hive.openBox(boxName);
    await box.put("startPage", page);
  }

  static Future<int?> getStartPage() async {
    final box = await Hive.openBox(boxName);
    return box.get("startPage");
  }

  static Future saveDay(int day) async {
    final box = await Hive.openBox(boxName);
    await box.put("currentDay", day);
  }

  static Future<int> getDay() async {
    final box = await Hive.openBox(boxName);
    return box.get("currentDay", defaultValue: 1);
  }

  static Future saveDailyStatus(int day, Map<String, bool> data) async {
    final box = await Hive.openBox(boxName);
    await box.put("day_$day", data);
  }

  static Future<Map<String, bool>> getDailyStatus(int day) async {
    final box = await Hive.openBox(boxName);
    final data = box.get("day_$day");

    if (data == null) {
      return {
        "reading": false,
        "listening": false,
        "weekly": false,
        "night": false,
        "qabliy": false,
        "new": false,
        "near": false,
        "far": false,
        "farOverflow": false,
        "farSecondOverflow": false,
      };
    }

    return Map<String, bool>.from(data);
  }

  static Future saveFarBlockSize(int size) async {
    final box = await Hive.openBox(boxName);
    await box.put("farBlockSize", size);
  }

  static Future<int> getFarBlockSize() async {
    final box = await Hive.openBox(boxName);
    return box.get("farBlockSize", defaultValue: 40);
  }

  static Future reset() async {
    final box = await Hive.openBox(boxName);
    await box.clear();
  }

  static Future saveWeeklyBreakEnabled(bool value) async {
    final box = await Hive.openBox(boxName);
    await box.put("weeklyBreak", value);
  }

  static Future<bool> getWeeklyBreakEnabled() async {
    final box = await Hive.openBox(boxName);
    return box.get("weeklyBreak", defaultValue: false);
  }

  // --- حفظ المسارات (Navigation Tracking) ---

  static Future saveLastRoute(String routeName) async {
    final box = await Hive.openBox(boxName);
    await box.put("lastRoute", routeName);
  }

  static Future<String?> getLastRoute() async {
    final box = await Hive.openBox(boxName);
    return box.get("lastRoute");
  }

  static Future<bool> isFirstLaunch() async {
    final box = await Hive.openBox(boxName);
    final isFirst = box.get("isFirstLaunch", defaultValue: true);
    if (isFirst) {
      await box.put("isFirstLaunch", false);
    }
    return isFirst;
  }

  // --- الإحصائيات (Statistics) ---

  /// زيادة عداد الإكمال لفئة معينة
  static Future incrementStats(String category) async {
    final box = await Hive.openBox(boxName);
    int current = box.get("stats_count_$category", defaultValue: 0);
    await box.put("stats_count_$category", current + 1);
  }

  /// تقليل عداد الإكمال لفئة معينة (في حال إلغاء الـ check)
  static Future decrementStats(String category) async {
    final box = await Hive.openBox(boxName);
    int current = box.get("stats_count_$category", defaultValue: 0);
    if (current > 0) {
      await box.put("stats_count_$category", current - 1);
    }
  }

  /// الحصول على عدد المرات التي تم فيها إكمال جزء من فئة معينة
  static Future<int> getStats(String category) async {
    final box = await Hive.openBox(boxName);
    return box.get("stats_count_$category", defaultValue: 0);
  }

  /// الحصول على حالة جميع الأيام (للفهرس الملون)
  static Future<Map<int, Map<String, bool>>> getAllDaysStatus() async {
    final box = await Hive.openBox(boxName);
    Map<int, Map<String, bool>> allStatus = {};
    for (var key in box.keys) {
      if (key is String && key.startsWith("day_")) {
        final day = int.tryParse(key.split("_")[1]);
        if (day != null) {
          allStatus[day] = Map<String, bool>.from(box.get(key));
        }
      }
    }
    return allStatus;
  }
}
