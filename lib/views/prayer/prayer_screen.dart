import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sapeel/data/prayer_service.dart';
import 'package:sapeel/data/adhan_notification_service.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  PrayerTimes? _prayerTimes;
  String? _errorMessage;
  bool _isLoading = true;
  Timer? _timer;
  Duration _countdown = Duration.zero;

  CalculationMethod _selectedMethod = CalculationMethod.egyptian;
  Madhab _selectedMadhab = Madhab.shafi;
  String _selectedCity = "القاهرة";
  bool _autoLocation = true;

  @override
  void initState() {
    super.initState();
    _loadSettingsAndTimes();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_prayerTimes != null) {
        setState(() {
          _countdown = PrayerService.getCountdown(_prayerTimes!);
          if (_countdown.isNegative) _loadPrayerTimes();
        });
      }
    });
  }

  Future<void> _loadSettingsAndTimes() async {
    final settings = await PrayerService.getSettings();
    setState(() {
      _selectedMethod = CalculationMethod.values.firstWhere(
        (e) => e.name == settings["method"],
      );
      _selectedMadhab = Madhab.values.firstWhere(
        (e) => e.name == settings["madhab"],
      );
      _selectedCity = settings["city"];
      _autoLocation = settings["autoLocation"];
    });
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    setState(() => _isLoading = true);
    try {
      final times = await PrayerService.getPrayerTimes();
      if (mounted) {
        setState(() {
          _prayerTimes = times;
          _isLoading = false;
          _errorMessage = null;
        });
        // جدولة الإشعارات فور تحميل الأوقات
        AdhanNotificationService.schedulePrayerNotifications(times);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1B5E20);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "مواقيت الصلاة",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _errorMessage != null
          ? _buildErrorState()
          : _buildMainUI(primaryColor),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadPrayerTimes,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
              ),
              child: const Text(
                "إعادة المحاولة",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainUI(Color primaryColor) {
    final nextPrayer = _prayerTimes!.nextPrayer();
    final currentPrayer = _prayerTimes!.currentPrayer();
    final nextPrayerTime = _prayerTimes!.timeForPrayer(nextPrayer);

    return Column(
      children: [
        // قسم الصلاة القادمة والعد التنازلي
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                "الصلاة القادمة: ${_getPrayerName(nextPrayer)}",
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 15),
              Text(
                _formatDuration(_countdown),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                DateFormat.yMMMMd('ar').format(DateTime.now()),
                style: const TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 5),
              if (nextPrayerTime != null)
                Text(
                  "موعدها: ${DateFormat.jm('ar').format(nextPrayerTime)}",
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.white54,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _autoLocation ? "تحديد تلقائي" : _selectedCity,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _prayerTile(
                "الفجر",
                _prayerTimes!.fajr,
                currentPrayer == Prayer.fajr,
                primaryColor,
              ),
              _prayerTile("الشروق", _prayerTimes!.sunrise, false, primaryColor),
              _prayerTile(
                "الظهر",
                _prayerTimes!.dhuhr,
                currentPrayer == Prayer.dhuhr,
                primaryColor,
              ),
              _prayerTile(
                "العصر",
                _prayerTimes!.asr,
                currentPrayer == Prayer.asr,
                primaryColor,
              ),
              _prayerTile(
                "المغرب",
                _prayerTimes!.maghrib,
                currentPrayer == Prayer.maghrib,
                primaryColor,
              ),
              _prayerTile(
                "العشاء",
                _prayerTimes!.isha,
                currentPrayer == Prayer.isha,
                primaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _prayerTile(String name, DateTime time, bool isCurrent, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      decoration: BoxDecoration(
        color: isCurrent ? color.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrent ? color : Colors.grey.withOpacity(0.1),
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: [
          if (isCurrent)
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isCurrent)
                Icon(Icons.notifications_active, color: color, size: 20),
              if (isCurrent) const SizedBox(width: 10),
              Text(
                name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                  color: isCurrent ? color : Colors.black87,
                ),
              ),
            ],
          ),
          Text(
            DateFormat.jm('ar').format(time),
            style: TextStyle(
              fontSize: 18,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
              color: isCurrent ? color : Colors.black54,
            ),
          ),
        ],
      ),
    );
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
      case Prayer.none:
        return "القيام";
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            "إعدادات الصلاة",
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text("تحديد الموقع تلقائياً (GPS)"),
                  value: _autoLocation,
                  onChanged: (val) {
                    setDialogState(() => _autoLocation = val);
                    setState(() => _autoLocation = val);
                  },
                ),
                if (!_autoLocation)
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCity,
                    decoration: const InputDecoration(
                      labelText: "اختر المدينة",
                    ),
                    items: PrayerService.cityCoordinates.keys
                        .map(
                          (city) =>
                              DropdownMenuItem(value: city, child: Text(city)),
                        )
                        .toList(),
                    onChanged: (val) {
                      setDialogState(() => _selectedCity = val!);
                      setState(() => _selectedCity = val!);
                    },
                  ),
                const Divider(),
                DropdownButtonFormField<CalculationMethod>(
                  initialValue: _selectedMethod,
                  decoration: const InputDecoration(labelText: "طريقة الحساب"),
                  items: [
                    const DropdownMenuItem(
                      value: CalculationMethod.egyptian,
                      child: Text("الهيئة المصرية"),
                    ),
                    const DropdownMenuItem(
                      value: CalculationMethod.umm_al_qura,
                      child: Text("أم القرى (السعودية)"),
                    ),
                    const DropdownMenuItem(
                      value: CalculationMethod.muslim_world_league,
                      child: Text("رابطة العالم الإسلامي"),
                    ),
                    const DropdownMenuItem(
                      value: CalculationMethod.karachi,
                      child: Text("جامعة كراتشي"),
                    ),
                  ],
                  onChanged: (val) {
                    setDialogState(() => _selectedMethod = val!);
                    setState(() => _selectedMethod = val!);
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<Madhab>(
                  initialValue: _selectedMadhab,
                  decoration: const InputDecoration(
                    labelText: "المذهب (لصلاة العصر)",
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: Madhab.shafi,
                      child: Text("شافعي/مالكي/حنبلي"),
                    ),
                    const DropdownMenuItem(
                      value: Madhab.hanafi,
                      child: Text("حنفي"),
                    ),
                  ],
                  onChanged: (val) {
                    setDialogState(() => _selectedMadhab = val!);
                    setState(() => _selectedMadhab = val!);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await PrayerService.saveSettings(
                  method: _selectedMethod,
                  madhab: _selectedMadhab,
                  city: _selectedCity,
                  autoLocation: _autoLocation,
                );
                Navigator.pop(context);
                _loadPrayerTimes();
              },
              child: const Text("حفظ وتطبيق"),
            ),
          ],
        ),
      ),
    );
  }
}
