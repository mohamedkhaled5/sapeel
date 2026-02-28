import 'package:flutter/material.dart';
import 'package:sapeel/views/home/home_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

class IslamicLibraryScreen extends StatefulWidget {
  const IslamicLibraryScreen({super.key});

  @override
  State<IslamicLibraryScreen> createState() => _IslamicLibraryScreenState();
}

class _IslamicLibraryScreenState extends State<IslamicLibraryScreen> {
  late final WebViewController _controller;

  // generate soft color from string
  Color generateSoftColor(String input) {
    final hash = input.hashCode;

    final hue = (hash % 360).toDouble();

    return HSVColor.fromAHSV(
      1.0,
      hue,
      0.45, // saturation
      0.65, // brightness
    ).toColor();
  }
  // update dynamic color from favicon

  final Map<String, String> websites = {
    'المكتبة الشاملة': 'https://shamela.ws/',
    'تراث': 'https://app.turath.io/',
    'الباحث القرآني': 'https://tafsir.app/',
    'المقرئ': 'https://ar.muqri.com/',
    'التفسير التفاعلي': 'https://read.tafsir.one/',
    'الباحث الحديثي': 'https://sunnah.one/',
    // 'تطبيق فائدة': 'https://faidah.app/',
    'تكوين الراسخين': 'https://takw.in/',
    'القارئ': 'https://qari.app/',
    'المصحف المحفّظ': 'https://muhaffidh.app/',
    'الباحث العلمي': 'https://bahith.app/',
    'Miftah': 'https://miftah.app/',
    'منصة سؤال': 'https://quizzer.one/',
    'مقرئ المتون': 'https://mutoon.one/',
    'كلمة': 'https://kalimah.app/',
    'حفظ': 'https://hifdh.app/',
    'المصحف': 'https://almushaf.app/',
    // 'راوي': 'https://rawy.net/',
  };

  String selectedSite = 'المكتبة الشاملة';
  final Map<String, String> descriptions = {
    'المكتبة الشاملة':
        'المكتبة الشاملة مشروع ضخم يضم آلاف الكتب التراثية في مختلف العلوم الشرعية.',

    'تراث':
        'البديل للمكتبة الشاملة الذي يعمل على جميع الأجهزة. من ميزاته: سلاسة القراءة والبحث • محرك بحث فوري • ربط الكتب بالنسخ المصورة • سرعة التحميل • الخفة في التشغيل • يعمل بدون شبكة.',

    'الباحث القرآني':
        'منصة متكاملة للقرآن الكريم تشمل: تفسير • قراءات • مصاحف • إعراب • علوم القرآن • أسباب النزول • أحكام القرآن • معاجم.',

    'المقرئ': 'تسهيل حفظ القرآن لكل صغير وكبير. مترجم إلى ٢٨ لغة.',

    'التفسير التفاعلي':
        'منصة للاستماع إلى التفاسير المختلفة مثل: الميسَّر • المختصر • السعدي • ابن جزي • الجلالين • ابن عاشور وغيرها.',

    'الباحث الحديثي':
        'محرك بحث حديثي متقدم، تكتب جزءًا من الحديث فيُخرج لك جميع الروايات مع بيان درجة صحتها.',

    // 'تطبيق فائدة': 'تعلَّم واستفد دون أن يكون ضيق الوقت أو النسيان عائقًا.',
    'تكوين الراسخين':
        'منهج محرر في طلب العلم الشرعي مع سهولة الوصول إلى المتون والمنظومات والشروح المكتوبة والصوتية والمرئية.',

    'القارئ': 'الاستماع إلى القرآن من خلال ١١٨ قارئ و١٤٤ مصحف في صفحة واحدة.',

    'المصحف المحفّظ':
        'احفظ كتاب الله بأسلوب مبتكر؛ لا تظهر الكلمات إلا عند اللمس ليبقى الذهن عاملًا.',

    'الباحث العلمي': 'بحث فوري في أكبر مكتبة على الشبكة: كتب • دروس • مخطوطات.',

    'Miftah': 'تطبيق بسيط لتعلم الحروف العربية وأصواتها.',

    'منصة سؤال': 'اختبارات تعليمية شرعية ماتعة.',

    'مقرئ المتون': 'تسهيل حفظ المتون العلمية والأدبية.',

    'كلمة': 'اختبر معرفتك بغريب القرآن بطريقة تفاعلية.',

    'حفظ':
        'تطبيق لحفظ المسائل والمعلومات بالتكرار المتباعد (مشابه لـ Anki). ما زال قيد التطوير.',

    'المصحف':
        'نسخة رقمية عالية الجودة من مصحف المدينة المنورة لمجمع الملك فهد، سريعة وسهلة الاستخدام.',

    // 'راوي':
    //     'مكتبة صوتية متكاملة تضم آلاف الكتب الإسلامية بواجهة أنيقة وميزات متقدمة، تعمل حتى بدون إنترنت.',
  };

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(websites[selectedSite]!));
  }

  void loadWebsite(String url) {
    _controller.loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = generateSoftColor(selectedSite);
    final isDark =
        ThemeData.estimateBrightnessForColor(currentColor) == Brightness.dark;

    final foregroundColor = isDark ? Colors.white : Colors.black;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,

        flexibleSpace: TweenAnimationBuilder<Color?>(
          tween: ColorTween(begin: Colors.transparent, end: currentColor),
          duration: const Duration(milliseconds: 600),
          builder: (context, color, _) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color!, color.withValues(alpha: .75)],
                ),
              ),
            );
          },
        ),

        iconTheme: IconThemeData(color: foregroundColor),

        title: Text(
          selectedSite,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: foregroundColor,
          ),
        ),

        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      drawer: Drawer(
        width: 285,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(left: Radius.circular(50)),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            /// ===== HEADER =====
            DrawerHeader(
              padding: EdgeInsets.zero,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOutCubic,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [currentColor, currentColor.withValues(alpha: .8)],
                  ),
                ),
                child: Center(
                  child: Text(
                    'المكتبة الإسلامية',
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),

            /// ===== MENU ITEMS =====
            ...websites.keys.map((site) {
              final isSelected = selectedSite == site;

              return Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.menu_book_rounded,
                      color: isSelected ? currentColor : Colors.grey,
                    ),

                    title: Text(
                      site,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected ? currentColor : Colors.black87,
                      ),
                    ),

                    selectedTileColor: currentColor.withValues(alpha: .08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () {
                      setState(() {
                        selectedSite = site;
                        loadWebsite(websites[site]!);
                      });
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(height: 8),
                ],
              );
            }),
          ],
        ),
      ),
      body: Column(
        children: [
          // 👇 النبذة
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              descriptions[selectedSite] ?? '',
              style: const TextStyle(fontSize: 12),
            ),
          ),

          Expanded(child: WebViewWidget(controller: _controller)),
        ],
      ),
    );
  }
}
