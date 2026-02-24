import 'package:flutter/material.dart';
import 'package:sapeel/views/home/home_screen.dart';
import 'package:sapeel/views/hosoon_khamsa/app_storage.dart';
import 'package:sapeel/views/hosoon_khamsa/el_hsoon.dart';
import 'package:sapeel/views/hosoon_khamsa/start_setup.dart';
import 'package:sapeel/views/quran_kareem/quran_screen.dart';

/// ويدجت لتحديد الوجهة الأولى للمستخدم عند فتح التطبيق
class RootDecider extends StatefulWidget {
  const RootDecider({super.key});

  @override
  State<RootDecider> createState() => _RootDeciderState();
}

class _RootDeciderState extends State<RootDecider> {
  bool? isFirst;
  String? lastRoute;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initLogic();
  }

  void _initLogic() async {
    isFirst = await AppStorage.isFirstLaunch();
    lastRoute = await AppStorage.getLastRoute();

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // أول مرة يفتح التطبيق
    if (isFirst == true) {
      return const HomeScreen();
    }

    // المرات التالية: نفتح آخر صفحة كانت مفتوحة
    switch (lastRoute) {
      case '/al_quran':
        return const QuranScreen();
      case '/dua':
        return const QuranFollowUpFlow();
      case '/setup':
        return const StartSetupScreen();
      case '/home':
      default:
        return const HomeScreen();
    }
  }
}
