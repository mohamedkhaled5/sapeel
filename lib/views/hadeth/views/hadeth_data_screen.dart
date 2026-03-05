import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sapeel/views/hadeth/data/models/hadeeth_detail.dart';
import 'package:sapeel/views/hadeth/data/services/hadeeth_api_service.dart';
import 'package:flutter/services.dart';

class HadethDetailScreen extends StatefulWidget {
  final String hadeethId;
  final int? hadeethNumber;

  const HadethDetailScreen({
    super.key,
    required this.hadeethId,
    this.hadeethNumber,
  });

  @override
  State<HadethDetailScreen> createState() => _HadethDetailScreenState();
}

class _HadethDetailScreenState extends State<HadethDetailScreen>
    with SingleTickerProviderStateMixin {
  void copyHadith(String text) async {
    await Clipboard.setData(ClipboardData(text: text));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: const Text("تم نسخ الحديث", textDirection: TextDirection.rtl),
      ),
    );
  }

  void copySimple(HadeethDetail hadeeth) {
    final text =
        "${hadeeth.hadeeth}\n\n"
        "المصدر: ${hadeeth.reference ?? ""}\n"
        "تطبيق سبيل";

    copyHadith(text);
  }

  //show copy options========================//
  void showCopyOptions(HadeethDetail hadeeth) {
    bool copyExplanation = false;
    bool copyHints = false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "اختر ما تريد نسخه",
            textDirection: TextDirection.rtl,
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: const Text("الشرح"),
                    value: copyExplanation,
                    onChanged: (v) {
                      setState(() => copyExplanation = v!);
                    },
                  ),

                  CheckboxListTile(
                    title: const Text("الفوائد"),
                    value: copyHints,
                    onChanged: (v) {
                      setState(() => copyHints = v!);
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text("إلغاء"),
              onPressed: () => Navigator.pop(context),
            ),

            ElevatedButton(
              child: const Text("نسخ"),
              onPressed: () {
                String text = hadeeth.hadeeth;

                if (copyExplanation && hadeeth.explanation != null) {
                  text += "\n\nالشرح:\n${hadeeth.explanation}";
                }

                if (copyHints && hadeeth.hints != null) {
                  text +=
                      "\n\nالفوائد:\n${hadeeth.hints!.map((e) => "• $e").join("\n")}";
                }

                text += "\n\nالمصدر: ${hadeeth.reference ?? ""}\nتطبيق سبيل";

                copyHadith(text);

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  final HadeethApiService _apiService = HadeethApiService();
  late Future<HadeethDetail> futureHadeeth;

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    futureHadeeth = _apiService.fetchHadeethDetail(
      id: widget.hadeethId,
      language: "ar",
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = const Color(0xffC9A227);
    final bgColor = isDark ? const Color(0xff0F0F0F) : const Color(0xffF8F6F1);
    // 📋 CopyHadith

    // copy simple hadith=======================//

    // =====================//
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("تفاصيل الحديث"),
        centerTitle: true,
        backgroundColor: goldColor,
        foregroundColor: Colors.white,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: FutureBuilder<HadeethDetail>(
          future: futureHadeeth,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "حدث خطأ أثناء تحميل الحديث:\n${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            futureHadeeth = _apiService.fetchHadeethDetail(
                              id: widget.hadeethId,
                              language: "ar",
                            );
                          });
                        },
                        child: const Text("إعادة المحاولة"),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: Text("لا توجد بيانات لهذا الحديث"));
            }

            final hadeeth = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    /// 📖 Badge رقم الحديث
                    if (widget.hadeethNumber != null)
                      Center(
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [goldColor, goldColor.withOpacity(0.7)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: goldColor.withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            widget.hadeethNumber.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 25),

                    /// 📜 المتن بزخرفة + Glass
                    Stack(
                      children: [
                        Positioned.fill(
                          child: Opacity(
                            opacity: isDark ? 0.3 : 1.0,
                            child: isDark
                                ? Image.asset(
                                    "assets/svg/islamic_pattern1.jpg",
                                    fit: BoxFit.cover,
                                  )
                                : SvgPicture.asset(
                                    "assets/svg/islamic_pattern.svg",
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        _glassCard(
                          hadeeth: hadeeth,
                          child: Text(
                            hadeeth.hadeeth,
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontFamily: "Amiri",
                              fontSize: 22,
                              height: 2.1,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          // onTap: () => copyHadith(
                          //   "${hadeeth.hadeeth}\n\n"
                          //   "المصدر: ${hadeeth.reference ?? ""}\n"
                          //   "تطبيق سبيل",
                          // ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    if (hadeeth.explanation != null)
                      _section("الشرح", hadeeth.explanation!, goldColor),

                    if (hadeeth.hints != null && hadeeth.hints!.isNotEmpty)
                      _section(
                        "الفوائد",
                        hadeeth.hints!.map((e) => "• $e").join("\n"),
                        goldColor,
                      ),

                    if (hadeeth.reference != null)
                      _section("المراجع", hadeeth.reference!, goldColor),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child, HadeethDetail? hadeeth}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              child,
              if (hadeeth != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xffC9A227),
                      shape: BoxShape.circle,
                    ),
                    child: GestureDetector(
                      onTap: () => copySimple(hadeeth),
                      onLongPress: () => showCopyOptions(hadeeth),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.copy, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title, String content, Color goldColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: _glassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// العنوان
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: goldColor,
              ),
              textAlign: TextAlign.right,
            ),

            const SizedBox(height: 12),

            /// المحتوى
            Text(
              content,
              style: TextStyle(
                height: 1.9,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }
}
