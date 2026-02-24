import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sapeel/views/hosoon_khamsa/app_storage.dart';

import 'package:sapeel/views/hosoon_khamsa/el_hsoon.dart';
import 'package:sapeel/views/hosoon_khamsa/start_setup.dart';
import 'package:sapeel/views/quran_kareem/surah_detail.dart';
import 'package:sapeel/views/small_widget/Verse_of_the_day.dart';
import 'package:sapeel/views/small_widget/build_header.dart';
import 'package:sapeel/views/small_widget/category_grid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter(); // ✅ تهيئة Hive

  runApp(const QuranApp());
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sapeel - Quran & Islamic Sciences',

      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/surah_detail':
            final surahNumber = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => SurahDetailScreen(surahNumber: surahNumber),
            );

          case '/dua':
            return MaterialPageRoute(builder: (_) => const QuranFollowUpFlow());

          case '/setup':
            return MaterialPageRoute(builder: (_) => const StartSetupScreen());

          default:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
        }
      },

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E20)),
      ),

      home: const RootDecider(), // 👈 أهم نقطة
    );
  }
}

////////////////////////////////////////////////////////////

class RootDecider extends StatefulWidget {
  const RootDecider({super.key});

  @override
  State<RootDecider> createState() => _RootDeciderState();
}

class _RootDeciderState extends State<RootDecider> {
  int? startPage;

  @override
  void initState() {
    super.initState();
    check();
  }

  void check() async {
    startPage = await AppStorage.getStartPage();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (startPage == null) {
      return const StartSetupScreen(); // 👈 أول مرة
    }

    return const HomeScreen(); // 👈 لو متسجل
  }
}

////////////////////////////////////////////////////////////

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
            buildHeader(context),
            buildCategoryGrid(context),
            buildVerseOfTheDay(context),
          ],
        ),
      ),
    );
  }
}
