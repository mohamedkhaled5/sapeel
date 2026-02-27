import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sapeel/views/islamic_library/islamic_library_screen.dart';
import 'package:sapeel/views/hadeth/hadeth_screen.dart';
import 'package:sapeel/views/home/home_screen.dart';
import 'package:sapeel/views/home/root_decider.dart';
import 'package:sapeel/views/hosoon_khamsa/el_hsoon.dart';
import 'package:sapeel/views/hosoon_khamsa/start_setup.dart';
import 'package:sapeel/views/quran_kareem/quran_screen.dart';
import 'package:sapeel/views/quran_kareem/surah_detail.dart';
import 'package:sapeel/views/qibla/qibla_screen.dart';
import 'package:sapeel/views/prayer/prayer_screen.dart';
import 'package:sapeel/data/adhan_notification_service.dart';

void main() async {
  // التأكد من تهيئة بيئة Flutter قبل أي عمليات أخرى
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة قاعدة البيانات المحلية Hive
  await Hive.initFlutter();

  // تهيئة بيانات التنسيق المحلي للغة العربية
  await initializeDateFormatting('ar', null);

  // تهيئة خدمة التنبيهات
  await AdhanNotificationService.initialize();

  runApp(const QuranApp());
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sapeel - Quran & Islamic Sciences',

      // إعدادات اللغة والتوطين
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'SA'), // العربية
        Locale('en', 'US'), // الإنجليزية
      ],
      locale: const Locale('ar', 'SA'), // اللغة الافتراضية
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

          case '/prayer_times':
            return MaterialPageRoute(builder: (_) => const PrayerScreen());

          case '/setup':
            return MaterialPageRoute(builder: (_) => const StartSetupScreen());

          case '/qibla':
            return MaterialPageRoute(builder: (_) => const QiblaScreen());

          case '/hadeth':
            return MaterialPageRoute(builder: (_) => const HadeethScreen());

          case '/islamic_library':
            return MaterialPageRoute(
              builder: (_) => const IslamicLibraryScreen(),
            );

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
