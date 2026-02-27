import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:vibration/vibration.dart';
import 'qibla_service.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  QiblaData? qiblaData;
  String? errorMessage;
  bool isLoading = true;
  bool hasVibrated = false;

  late AnimationController _animationController;
  late Animation<double> _animation;
  final double _lastHeading = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(_animationController);
    _loadQiblaData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadQiblaData() async {
    try {
      final data = await QiblaService.getQiblaData();
      if (mounted) {
        setState(() {
          qiblaData = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  void _handleVibration(double qiblaAngle) {
    // الاهتزاز عند المحاذاة مع القبلة (±5 درجات)
    double diff = (qiblaAngle % 360).abs();
    if (diff > 180) diff = 360 - diff;

    if (diff < 5) {
      if (!hasVibrated) {
        Vibration.vibrate(duration: 100);
        hasVibrated = true;
      }
    } else {
      hasVibrated = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1B5E20);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "تحديد القبلة",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? _buildLoadingState(primaryColor)
          : errorMessage != null
          ? _buildErrorState(errorMessage!)
          : _buildCompassUI(primaryColor),
    );
  }

  Widget _buildLoadingState(Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: color),
          const SizedBox(height: 20),
          const Text(
            "جاري تحديد الموقع وحساب القبلة...",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 80, color: Colors.redAccent),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.redAccent),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });
                _loadQiblaData();
              },
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

  Widget _buildCompassUI(Color primaryColor) {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState("خطأ في حساسات الجهاز");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(primaryColor);
        }

        double? direction = snapshot.data?.heading;

        if (direction == null) {
          return _buildErrorState("الجهاز لا يدعم حساس البوصلة");
        }

        // حساب الزوايا
        double qiblaAngle = (qiblaData!.qiblaDirection - direction);
        _handleVibration(qiblaAngle);

        // تنعيم الحركة
        double headingRad = direction * (math.pi / 180) * -1;
        double qiblaRad = qiblaAngle * (math.pi / 180);

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              // معلومات الموقع
              _buildLocationInfo(primaryColor),
              const SizedBox(height: 40),
              // البوصلة
              _buildCompassWidget(
                headingRad,
                qiblaRad,
                primaryColor,
                qiblaAngle,
              ),
              const SizedBox(height: 50),
              // التعليمات
              _buildInstructions(qiblaAngle),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationInfo(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      margin: const EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                qiblaData?.cityName ?? "موقع غير معروف",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                "المسافة لمكة",
                "${qiblaData?.distanceToMakkah.toStringAsFixed(0)} كم",
              ),
              Container(width: 1, height: 20, color: color.withOpacity(0.2)),
              _buildInfoItem(
                "زاوية القبلة",
                "${qiblaData?.qiblaDirection.toStringAsFixed(1)}°",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCompassWidget(
    double headingRad,
    double qiblaRad,
    Color color,
    double qiblaAngle,
  ) {
    // حساب الفرق للتحقق من المحاذاة
    double diff = (qiblaAngle % 360).abs();
    if (diff > 180) diff = 360 - diff;
    bool isAligned = diff < 5;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // خلفية البوصلة (تتحرك مع الجهاز)
          Transform.rotate(
            angle: headingRad,
            child: Container(
              height: 280,
              width: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CustomPaint(painter: CompassPainter()),
            ),
          ),
          // سهم القبلة (يشير دائماً لمكة)
          Transform.rotate(
            angle: qiblaRad,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.navigation,
                  size: 100,
                  color: isAligned ? Colors.green : color,
                ),
                const SizedBox(height: 100), // دفع السهم للأعلى
              ],
            ),
          ),
          // صورة الكعبة في المنتصف (ثابتة)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.mosque, color: color, size: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(double qiblaAngle) {
    double diff = (qiblaAngle % 360).abs();
    if (diff > 180) diff = 360 - diff;
    bool isAligned = diff < 5;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            isAligned
                ? "أنت الآن باتجاه القبلة الصحيح"
                : "قم بتدوير الهاتف حتى يظهر السهم للأعلى",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isAligned ? Colors.green : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 15),
          if (!isAligned)
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  "تأكد من إمساك الهاتف بشكل أفقي وبعيداً عن المعادن",
                  style: TextStyle(fontSize: 12, color: Colors.amber),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // رسم علامات البوصلة
    for (int i = 0; i < 360; i += 10) {
      double angle = i * (math.pi / 180);
      double lineLength = (i % 90 == 0) ? 15 : 8;

      Offset p1 = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      Offset p2 = Offset(
        center.dx + (radius - lineLength) * math.cos(angle),
        center.dy + (radius - lineLength) * math.sin(angle),
      );

      canvas.drawLine(p1, p2, paint);

      // إضافة الحروف (N, S, E, W)
      if (i % 90 == 0) {
        String label = "";
        switch (i) {
          case 0:
            label = "E";
            break;
          case 90:
            label = "S";
            break;
          case 180:
            label = "W";
            break;
          case 270:
            label = "N";
            break;
        }
        _drawText(canvas, center, radius - 30, angle, label);
      }
    }
  }

  void _drawText(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    String text,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final offset = Offset(
      center.dx + radius * math.cos(angle) - textPainter.width / 2,
      center.dy + radius * math.sin(angle) - textPainter.height / 2,
    );
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
