import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class QiblaData {
  final double qiblaDirection;
  final double distanceToMakkah;
  final String? cityName;
  final double latitude;
  final double longitude;

  QiblaData({
    required this.qiblaDirection,
    required this.distanceToMakkah,
    this.cityName,
    required this.latitude,
    required this.longitude,
  });
}

class QiblaService {
  // إحداثيات الكعبة المشرفة
  static const double kaabaLatitude = 21.422487;
  static const double kaabaLongitude = 39.826206;

  /// الحصول على بيانات القبلة بالكامل (الموقع، المسافة، المدينة، الزاوية)
  static Future<QiblaData> getQiblaData() async {
    // 1. الحصول على الموقع الحالي
    Position position = await _determinePosition();

    // 2. حساب زاوية القبلة
    double qiblaDirection = calculateQiblaDirection(
      position.latitude,
      position.longitude,
    );

    // 3. حساب المسافة إلى مكة
    double distanceInMeters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      kaabaLatitude,
      kaabaLongitude,
    );
    double distanceInKm = distanceInMeters / 1000;

    // 4. الحصول على اسم المدينة (اختياري)
    String? cityName;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        cityName =
            placemarks.first.locality ?? placemarks.first.subAdministrativeArea;
      }
    } catch (e) {
      // نتجاهل الخطأ إذا لم نتمكن من جلب اسم المدينة
    }

    return QiblaData(
      qiblaDirection: qiblaDirection,
      distanceToMakkah: distanceInKm,
      cityName: cityName,
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  /// حساب زاوية القبلة بناءً على خطوط الطول والعرض
  static double calculateQiblaDirection(double userLat, double userLng) {
    double userLatRad = userLat * (pi / 180.0);
    double userLngRad = userLng * (pi / 180.0);
    double kaabaLatRad = kaabaLatitude * (pi / 180.0);
    double kaabaLngRad = kaabaLongitude * (pi / 180.0);

    double deltaLng = kaabaLngRad - userLngRad;

    double y = sin(deltaLng);
    double x =
        cos(userLatRad) * tan(kaabaLatRad) - sin(userLatRad) * cos(deltaLng);

    double qiblaDirectionRad = atan2(y, x);
    double qiblaDirectionDeg = qiblaDirectionRad * (180.0 / pi);

    return (qiblaDirectionDeg + 360.0) % 360.0;
  }

  /// التأكد من صلاحيات الموقع وجلب الإحداثيات
  static Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('خدمة الموقع غير مفعلة. يرجى تفعيل GPS.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('تم رفض صلاحية الوصول للموقع.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'صلاحيات الموقع مرفوضة بشكل دائم، لا يمكننا تحديد اتجاه القبلة.',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
