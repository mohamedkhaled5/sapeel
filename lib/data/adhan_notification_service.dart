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
      return;
    }

    final prayers = {
      "الفجر": prayerTimes.fajr,
      "الظهر": prayerTimes.dhuhr,
      "العصر": prayerTimes.asr,
      "المغرب": prayerTimes.maghrib,
      "العشاء": prayerTimes.isha,
    };

    // 1. إضافة إشعار "مستمر" للعد التنازلي للصلاة القادمة (أندرويد فقط)
    await _showOngoingCountdown(prayerTimes);

    int id = 100; // نبدأ من 100 لتجنب التداخل مع إشعار العد التنازلي (id: 0)
    prayers.forEach((name, time) async {
      if (time.isAfter(DateTime.now())) {
        try {
          await _scheduleNotification(
            id++,
            "وقت صلاة $name",
            "حان الآن موعد أذان $name حسب توقيتك المحلي",
            time,
          );

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

  /// عرض إشعار مستمر يحتوي على عداد تنازلي للصلاة القادمة
  static Future<void> _showOngoingCountdown(PrayerTimes prayerTimes) async {
    final nextPrayer = prayerTimes.nextPrayer();
    final nextPrayerTime = prayerTimes.timeForPrayer(nextPrayer);

    if (nextPrayerTime == null) return;

    final String prayerName = _getPrayerNameArabic(nextPrayer);

    await _plugin.show(
      0, // ID ثابت لإشعار العد التنازلي
      "الصلاة القادمة: $prayerName",
      "بقي على الأذان:",
      NotificationDetails(
        android: AndroidNotificationDetails(
          'countdown_channel_v2', // تغيير اسم القناة لضمان تحديث الإعدادات
          'العد التنازلي للصلاة',
          channelDescription: 'إشعار مستمر يظهر الوقت المتبقي للصلاة القادمة',
          importance: Importance.max, // رفع الأهمية لضمان الظهور
          priority: Priority.high,
          ongoing: true,
          showWhen: true,
          when: nextPrayerTime.millisecondsSinceEpoch,
          usesChronometer: true,
          chronometerCountDown: true,
          icon: '@mipmap/ic_launcher',
          visibility:
              NotificationVisibility.public, // السماح بالظهور في شاشة القفل
        ),
      ),
    );
  }

  static String _getPrayerNameArabic(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return "الفجر";
      case Prayer.sunrise:
        return "الشروق";
      case Prayer.dhuhr:
        return "الظهر";
      case Prayer.asr:
        return "العصر";
      case Prayer.maghrib:
        return "المغرب";
      case Prayer.isha:
        return "العشاء";
      default:
        return "القيام";
    }
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
