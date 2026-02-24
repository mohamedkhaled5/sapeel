import 'package:flutter/material.dart';
import 'package:sapeel/views/small_widget/verse_of_the_day.dart';
import 'package:sapeel/views/small_widget/build_header.dart';
import 'package:sapeel/views/small_widget/category_grid.dart';

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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // الهيدر الترحيبي
            buildHeader(context),
            // شبكة التصنيفات (قرآن، حديث، إلخ)
            buildCategoryGrid(context),
            // آية اليوم
            buildVerseOfTheDay(context),
          ],
        ),
      ),
    );
  }
}
