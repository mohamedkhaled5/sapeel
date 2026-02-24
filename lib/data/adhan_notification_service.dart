import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:adhan/adhan.dart';

class AdhanNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// تهيئة نظام التنبيهات
  static Future<void> initialize() async {
    tz_data.initializeTimeZones();
    String timeZoneName;
    try {
      timeZoneName = await FlutterTimezone.getLocalTimezone();
    } catch (e) {
      // Fallback to UTC or a default timezone if the plugin fails
      timeZoneName = 'Africa/Cairo';
    }
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _plugin.initialize(settings);
    } catch (e) {
      // فشل التهيئة غالباً بسبب عدم إعادة تشغيل التطبيق بالكامل بعد إضافة المكتبة
      print("Notification Initialization Error: $e");
    }
  }

  /// جدولة تنبيهات لجميع صلوات اليوم
  static Future<void> schedulePrayerNotifications(
    PrayerTimes prayerTimes,
  ) async {
    try {
      // إلغاء أي تنبيهات قديمة
      await _plugin.cancelAll();
    } catch (e) {
      print("Notification cancelAll error: $e");
      return; // توقف إذا كان هناك خطأ في الاتصال بالمكتبة
    }

    final prayers = {
      "الفجر": prayerTimes.fajr,
      "الظهر": prayerTimes.dhuhr,
      "العصر": prayerTimes.asr,
      "المغرب": prayerTimes.maghrib,
      "العشاء": prayerTimes.isha,
    };

    int id = 0;
    prayers.forEach((name, time) async {
      if (time == null) return; // حماية من القيم الفارغة

      // تنبيه وقت الأذان
      if (time.isAfter(DateTime.now())) {
        try {
          await _scheduleNotification(
            id++,
            "وقت صلاة $name",
            "حان الآن موعد أذان $name حسب توقيتك المحلي",
            time,
          );

          // تنبيه قبل الأذان بـ 15 دقيقة (اختياري)
          final preTime = time.subtract(const Duration(minutes: 15));
          if (preTime.isAfter(DateTime.now())) {
            await _scheduleNotification(
              id++,
              "اقترب موعد صلاة $name",
              "بقي 15 دقيقة على أذان $name، استعد للصلاة",
              preTime,
            );
          }
        } catch (e) {
          print("Error scheduling notification for $name: $e");
        }
      }
    });
  }

  static Future<void> _scheduleNotification(
    int id,
    String title,
    String body,
    DateTime time,
  ) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(time, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'adhan_channel',
          'تنبيهات الأذان',
          channelDescription: 'تنبيهات مواقيت الصلاة والأذان',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound(
            'adhan',
          ), // ملف صوتي أذان اختياري
        ),
        iOS: DarwinNotificationDetails(sound: 'adhan.caf'),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
