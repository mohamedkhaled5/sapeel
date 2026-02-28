import 'package:flutter/material.dart';

class HadeethScreen extends StatefulWidget {
  const HadeethScreen({super.key});

  @override
  State<HadeethScreen> createState() => _HadeethScreenState();
}

class _HadeethScreenState extends State<HadeethScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hadeth Screen')),
      body: const Center(
        child: Text(
          'نراكم قريبا (يمكنكم استعمال المكتبه الاسلاميه للوصول لبعض كتب الاحاديث وبعض التقنيات المناسبه لحين اتاحةهذه الميزه شكرا علي تفهمكم)',
        ),
      ),
    );
  }
}
