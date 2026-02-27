import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart';
import 'package:sapeel/data/prayer_service.dart';

class DynamicHeader extends StatefulWidget {
  const DynamicHeader({super.key});

  @override
  State<DynamicHeader> createState() => _DynamicHeaderState();
}

class _DynamicHeaderState extends State<DynamicHeader> {
  PrayerTimes? _prayerTimes;
  String _hijriDate = "";
  String _gregorianDate = "";

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _loadPrayerData();
  }

  void _updateDateTime() {
    final now = DateTime.now();

    // التاريخ الهجري
    final hijriNow = HijriCalendar.now();
    _hijriDate =
        "${hijriNow.hDay} ${hijriNow.longMonthName}, ${hijriNow.hYear}";

    // التاريخ الميلادي
    _gregorianDate = DateFormat('EEEE, d MMMM yyyy', 'ar').format(now);

    setState(() {});
  }

  Future<void> _loadPrayerData() async {
    try {
      final times = await PrayerService.getPrayerTimes();
      if (mounted) {
        setState(() {
          _prayerTimes = times;
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
    final nextPrayer = _prayerTimes?.nextPrayer() ?? Prayer.none;
    final nextPrayerTime = _prayerTimes?.timeForPrayer(nextPrayer);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1B5E20),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'السلام عليكم ورحمة الله وبركاته',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const Text(
            'أهلاً بك في سبيل',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _prayerTimes == null
                          ? 'جاري التحميل...'
                          : 'الصلاة القادمة: ${_getPrayerName(nextPrayer)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (nextPrayerTime != null)
                      Text(
                        DateFormat.jm('ar').format(nextPrayerTime),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _hijriDate,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _gregorianDate,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
