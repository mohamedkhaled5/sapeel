import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart' show Color;

import 'package:sapeel/data/prayer_service.dart';

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
    for (var entry in prayers.entries) {
      final name = entry.key;
      final time = entry.value;

      if (time.isAfter(DateTime.now())) {
        try {
          // إشعار موعد الأذان
          await _scheduleNotification(
            id++,
            "وقت صلاة $name",
            "حان الآن موعد أذان $name حسب توقيتك المحلي",
            time,
            isAlarm: true, // تفعيل التنبيه العالي
          );

          // تنبيه قبل الصلاة بـ 15 دقيقة
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
    }
  }

  /// عرض إشعار مستمر يحتوي على عداد تنازلي للصلاة القادمة
  static Future<void> _showOngoingCountdown(PrayerTimes prayerTimes) async {
    final nextData = PrayerService.getNextPrayerAndTime(prayerTimes);
    final Prayer nextPrayer = nextData["prayer"];
    final DateTime? nextPrayerTime = nextData["time"];

    if (nextPrayerTime == null) return;

    final String prayerName = _getPrayerNameArabic(nextPrayer);

    // التحقق من صلاحيات الإشعارات (لأندرويد 13+)
    final bool? granted = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    if (granted == false) {
      print("Notification permission not granted");
    }

    await _plugin.show(
      0, // ID ثابت لإشعار العد التنازلي
      "الصلاة القادمة: $prayerName",
      "بقي على الأذان: ${DateFormat.jm('ar').format(nextPrayerTime)}",
      NotificationDetails(
        android: AndroidNotificationDetails(
          'countdown_channel_v3',
          'العد التنازلي للصلاة',
          channelDescription: 'إشعار مستمر يظهر الوقت المتبقي للصلاة القادمة',
          importance: Importance.max,
          priority: Priority.high,
          ongoing: true,
          showWhen: true,
          when: nextPrayerTime.millisecondsSinceEpoch,
          usesChronometer: true,
          chronometerCountDown: true,
          icon: '@mipmap/ic_launcher',
          visibility: NotificationVisibility.public,
          category: AndroidNotificationCategory.alarm,
          color: const Color(0xFF2196F3), // لون أزرق للإشعار
          styleInformation: BigTextStyleInformation(
            "بقي على الأذان:<br><font color='#2196F3'><b>${DateFormat.jm('ar').format(nextPrayerTime)}</b></font>",
            htmlFormatBigText: true,
            htmlFormatContentTitle: true,
            contentTitle: "<b>الصلاة القادمة: $prayerName</b>",
            summaryText: "موعد الأذان",
          ),
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

  /// وظيفة مساعدة لجدولة إشعار فردي
  static Future<void> _scheduleNotification(
    int id,
    String title,
    String body,
    DateTime scheduledDate, {
    bool isAlarm = false,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          isAlarm ? 'prayer_alerts_v4' : 'prayer_reminders_v4',
          isAlarm ? 'تنبيهات الأذان' : 'تذكيرات الصلاة',
          channelDescription: 'قناة تنبيهات مواقيت الصلاة',
          importance: isAlarm ? Importance.max : Importance.high,
          priority: isAlarm ? Priority.high : Priority.defaultPriority,
          sound: isAlarm
              ? const RawResourceAndroidNotificationSound('adhan')
              : null,
          playSound: true,
          enableVibration: true,
          fullScreenIntent:
              isAlarm, // يظهر الإشعار على كامل الشاشة إذا كان مغلقاً
          category: isAlarm
              ? AndroidNotificationCategory.alarm
              : AndroidNotificationCategory.reminder,
          visibility: NotificationVisibility.public,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'adhan.aiff',
        ),
      ),
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle, // مهم جداً للدقة في الخلفية
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
