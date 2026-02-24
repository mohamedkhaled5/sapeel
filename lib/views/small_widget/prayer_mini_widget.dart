import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sapeel/data/prayer_service.dart';

class PrayerMiniWidget extends StatefulWidget {
  const PrayerMiniWidget({super.key});

  @override
  State<PrayerMiniWidget> createState() => _PrayerMiniWidgetState();
}

class _PrayerMiniWidgetState extends State<PrayerMiniWidget> {
  PrayerTimes? _prayerTimes;
  Timer? _timer;
  Duration _countdown = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadTimes();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_prayerTimes != null) {
        setState(() {
          _countdown = PrayerService.getCountdown(_prayerTimes!);
          if (_countdown.isNegative) _loadTimes();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadTimes() async {
    try {
      final times = await PrayerService.getPrayerTimes();
      if (mounted) {
        setState(() {
          _prayerTimes = times;
          // تحديث العد التنازلي فوراً عند تحميل الأوقات
          _countdown = PrayerService.getCountdown(times);
        });
      }
    } catch (_) {}
  }

  String _getPrayerName(Prayer prayer) {
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

  @override
  Widget build(BuildContext context) {
    if (_prayerTimes == null) return const SizedBox.shrink();

    final nextPrayer = _prayerTimes!.nextPrayer();
    final nextPrayerTime = _prayerTimes!.timeForPrayer(nextPrayer);

    // إذا لم يتوفر وقت للصلاة القادمة (حالة نادرة)، لا نعرض الويدجت
    if (nextPrayerTime == null) return const SizedBox.shrink();

    const color = Color(0xFF1B5E20);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "الصلاة القادمة: ${_getPrayerName(nextPrayer)}",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat.jm('ar').format(nextPrayerTime),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "الوقت المتبقي",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                "${_countdown.inHours.toString().padLeft(2, '0')}:${(_countdown.inMinutes % 60).toString().padLeft(2, '0')}:${(_countdown.inSeconds % 60).toString().padLeft(2, '0')}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
