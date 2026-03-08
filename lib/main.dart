import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sapeel/views/hadeth/views/hadeth_data_screen.dart';
import 'package:sapeel/views/hadeth/views/hadeth_list_screen.dart';
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
import 'package:sapeel/data/theme_service.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);
late final ThemeService themeService;

void main() async {
  // التأكد من تهيئة بيئة Flutter قبل أي عمليات أخرى
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة قاعدة البيانات المحلية Hive
  await Hive.initFlutter();
  await ThemeService.init();
  themeService = ThemeService();
  themeNotifier.value = themeService.themeMode;

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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Sapeel - Quran & Islamic Sciences',
          themeMode: themeMode,

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
                if (settings.arguments is Map<String, dynamic>) {
                  final args = settings.arguments as Map<String, dynamic>;
                  if (args.containsKey('page')) {
                    final page = args['page'] as int;
                    final endPage = args['endPage'] as int?;
                    final segmentLabel = args['segmentLabel'] as String?;
                    return MaterialPageRoute(
                      builder: (_) => SurahDetailScreen(
                        surahNumber: 1,
                        initialPage: page,
                        segmentStartPage: page,
                        segmentEndPage: endPage,
                        segmentLabel: segmentLabel,
                      ),
                    );
                  }
                }
                if (settings.arguments is int) {
                  final arg = settings.arguments as int;
                  // لو جاي من الفهرس التقليدي (رقم سورة)
                  return MaterialPageRoute(
                    builder: (_) => SurahDetailScreen(surahNumber: arg),
                  );
                }
                return MaterialPageRoute(builder: (_) => const HomeScreen());

              case '/al_quran':
                return MaterialPageRoute(builder: (_) => const QuranScreen());

              case '/dua':
                return MaterialPageRoute(
                  builder: (_) => const QuranFollowUpFlow(),
                );

              case '/prayer_times':
                return MaterialPageRoute(builder: (_) => const PrayerScreen());

              case '/setup':
                return MaterialPageRoute(
                  builder: (_) => const StartSetupScreen(),
                );

              case '/qibla':
                return MaterialPageRoute(builder: (_) => const QiblaScreen());

              case '/hadeth':
                return MaterialPageRoute(builder: (_) => const HadeethScreen());

              case '/islamic_library':
                return MaterialPageRoute(
                  builder: (_) => const IslamicLibraryScreen(),
                );

              case '/hadeth_list':
                if (settings.arguments is Map<String, dynamic>) {
                  final args = settings.arguments as Map<String, dynamic>;
                  if (args.containsKey('id') && args.containsKey('title')) {
                    final id = args['id'] as String;
                    final title = args['title'] as String;
                    return MaterialPageRoute(
                      builder: (_) => HadethListScreen(
                        categoryId: id,
                        categoryTitle: title,
                      ),
                    );
                  }
                }
              // return MaterialPageRoute(builder: (_) => const HadethListScreen());
              case '/hadeth_detail':
                if (settings.arguments is String) {
                  final id = settings.arguments as String;
                  return MaterialPageRoute(
                    builder: (_) => HadethDetailScreen(hadeethId: id),
                  );
                }
                return MaterialPageRoute(builder: (_) => const HomeScreen());
              default:
                return MaterialPageRoute(builder: (_) => const HomeScreen());
            }
          },

          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1B5E20),
              brightness: Brightness.light,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1B5E20),
              foregroundColor: Colors.white,
              centerTitle: true,
            ),
          ),

          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1B5E20),
              brightness: Brightness.dark,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0F2D0F),
              foregroundColor: Colors.white,
              centerTitle: true,
            ),
            scaffoldBackgroundColor: const Color(0xFF0A0A0A),
          ),

          // الويدجت التي تقرر الشاشة الأولى بناءً على حالة المستخدم
          home: const RootDecider(),
        );
      },
    );
  }
}
