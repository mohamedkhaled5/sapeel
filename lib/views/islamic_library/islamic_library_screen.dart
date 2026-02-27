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
  final Map<String, String> websites = {
    'المكتبة الشاملة': 'https://shamela.ws/',
    'تراث': 'https://app.turath.io/',
    'الباحث القرآني': 'https://tafsir.app/',
    'المقرئ': 'https://ar.muqri.com/',
    'التفسير التفاعلي': 'https://read.tafsir.one/',
    'الباحث الحديثي': 'https://sunnah.one/',
    'تطبيق فائدة': 'https://faidah.app/',
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
    'راوي': 'https://rawy.net/',
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

    'تطبيق فائدة': 'تعلَّم واستفد دون أن يكون ضيق الوقت أو النسيان عائقًا.',

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

    'راوي':
        'مكتبة صوتية متكاملة تضم آلاف الكتب الإسلامية بواجهة أنيقة وميزات متقدمة، تعمل حتى بدون إنترنت.',
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
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedSite),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Text(
                'المكتبة الإسلامية',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ...websites.keys.map((site) {
              return ListTile(
                title: Text(site),
                onTap: () {
                  setState(() {
                    selectedSite = site;
                    loadWebsite(websites[site]!);
                  });
                  Navigator.pop(context); // يقفل الـ Drawer
                },
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
