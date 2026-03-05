import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeService {
  static const String _boxName = 'settings';
  static const String _key = 'isDarkMode';

  final _box = Hive.box(_boxName);

  bool get isDarkMode => _box.get(_key, defaultValue: false);

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleTheme() async {
    await _box.put(_key, !isDarkMode);
  }

  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }
}
