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

  static Future reset() async {
    final box = await Hive.openBox(boxName);
    await box.clear();
  }
}
