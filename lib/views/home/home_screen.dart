import 'package:flutter/material.dart';
import 'package:sapeel/main.dart'; // Import to access themeNotifier and themeService
import 'package:sapeel/views/small_widget/verse_of_the_day.dart';
import 'package:sapeel/views/small_widget/hadeeth_of_the_day.dart';
import 'package:sapeel/views/small_widget/dynamic_header.dart';
import 'package:sapeel/views/small_widget/category_grid.dart';
import 'package:sapeel/views/small_widget/prayer_mini_widget.dart';

import 'package:sapeel/views/hosoon_khamsa/app_storage.dart';

/// الشاشة الرئيسية للتطبيق التي تعرض الهيدر والشبكة والتنبيهات
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    AppStorage.saveLastRoute('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sapeel',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, child) {
              return IconButton(
                icon: Icon(
                  mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                  color: Colors.white,
                ),
                onPressed: () async {
                  await themeService.toggleTheme();
                  themeNotifier.value = themeService.themeMode;
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // الهيدر الترحيبي الديناميكي
            const DynamicHeader(),
            // ويدجت الصلاة القادمة
            const PrayerMiniWidget(),
            // شبكة التصنيفات (قرآن، حديث، إلخ)
            buildCategoryGrid(context),
            // آية اليوم
            const VerseOfTheDay(),
            // حديث اليوم
            const HadeethOfTheDay(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
