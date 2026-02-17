import 'package:flutter/material.dart';
import 'package:sapeel/data/mushaf_service.dart';
import 'package:sapeel/views/screens/mushaf_screen.dart';

class MushafPage extends StatefulWidget {
  @override
  State<MushafPage> createState() => _MushafPageState();
}

class _MushafPageState extends State<MushafPage> {
  bool downloaded = false;
  double progress = 0;

  @override
  void initState() {
    super.initState();
    checkDownload();
  }

  void checkDownload() async {
    downloaded = await MushafService.isDownloaded();
    setState(() {});
  }

  void startDownload() async {
    await MushafService.downloadMushaf((p) {
      setState(() {
        progress = p;
      });
    });

    setState(() {
      downloaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!downloaded) {
      return Scaffold(
        appBar: AppBar(title: Text("تحميل المصحف")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (progress > 0)
                Column(
                  children: [
                    CircularProgressIndicator(value: progress),
                    SizedBox(height: 10),
                    Text("${(progress * 100).toStringAsFixed(0)}%"),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: startDownload,
                  child: Text("تحميل المصحف (120MB)"),
                ),
            ],
          ),
        ),
      );
    }

    return MushafScreen(initialPage: 1); // هنا تعرض الصفحات
  }
}
