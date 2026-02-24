import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sapeel/views/home/home_screen.dart';
import 'package:sapeel/views/home/root_decider.dart';
import 'package:sapeel/views/hosoon_khamsa/el_hsoon.dart';
import 'package:sapeel/views/hosoon_khamsa/start_setup.dart';
import 'package:sapeel/views/quran_kareem/quran_screen.dart';
import 'package:sapeel/views/quran_kareem/surah_detail.dart';

void main() async {
  // التأكد من تهيئة بيئة Flutter قبل أي عمليات أخرى
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة قاعدة البيانات المحلية Hive
  await Hive.initFlutter();

  runApp(const QuranApp());
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sapeel - Quran & Islamic Sciences',

      // إدارة التنقل بين الصفحات باستخدام onGenerateRoute
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/surah_detail':
            final surahNumber = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => SurahDetailScreen(surahNumber: surahNumber),
            );

          case '/al_quran':
            return MaterialPageRoute(builder: (_) => const QuranScreen());

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(
            0xFF1B5E20,
          ), // اللون الأخضر العميق للهوية الإسلامية
        ),
      ),

      // الويدجت التي تقرر الشاشة الأولى بناءً على حالة المستخدم
      home: const RootDecider(),
    );
  }
}
