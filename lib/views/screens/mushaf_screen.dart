import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';

class MushafScreen extends StatefulWidget {
  const MushafScreen({super.key});

  @override
  State<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends State<MushafScreen> {
  bool isLoading = true;
  bool isDownloading = false;
  double progress = 0;
  String? mushafPath;

  static const zipUrl = "https://api.quranpedia.net/api-quran-png/hafs.zip";

  @override
  void initState() {
    super.initState();
    checkIfDownloaded();
  }

  Future<void> checkIfDownloaded() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = "${dir.path}/mushaf";
    final directory = Directory(path);

    if (await directory.exists()) {
      setState(() {
        mushafPath = path;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> downloadMushaf() async {
    setState(() {
      isDownloading = true;
      progress = 0;
    });

    final request = http.Request('GET', Uri.parse(zipUrl));
    final response = await request.send();

    final total = response.contentLength ?? 1;
    int received = 0;

    final dir = await getApplicationDocumentsDirectory();
    final zipFile = File("${dir.path}/hafs.zip");
    final sink = zipFile.openWrite();

    await response.stream.listen((chunk) {
      received += chunk.length;
      sink.add(chunk);

      setState(() {
        progress = received / total;
      });
    }).asFuture();

    await sink.close();

    // فك الضغط
    final bytes = zipFile.readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    final mushafDir = Directory("${dir.path}/mushaf");
    await mushafDir.create();

    for (final file in archive) {
      final filename = "${mushafDir.path}/${file.name}";
      if (file.isFile) {
        final outFile = File(filename);
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content);
      }
    }

    await zipFile.delete(); // نحذف الملف المضغوط

    setState(() {
      mushafPath = mushafDir.path;
      isDownloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // لو المصحف مش موجود
    if (mushafPath == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("تحميل المصحف")),
        body: Center(
          child: isDownloading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(value: progress),
                    const SizedBox(height: 12),
                    Text("${(progress * 100).toStringAsFixed(0)}%"),
                  ],
                )
              : ElevatedButton(
                  onPressed: downloadMushaf,
                  child: const Text("تحميل المصحف (150MB)"),
                ),
        ),
      );
    }

    // عرض المصحف
    return Scaffold(
      appBar: AppBar(title: const Text("مصحف المدينة")),
      body: PageView.builder(
        itemCount: 604,
        itemBuilder: (context, index) {
          final pageNumber = (index + 1).toString().padLeft(3, '0');

          final filePath = "$mushafPath/$pageNumber.png";

          return InteractiveViewer(
            child: Image.file(File(filePath), fit: BoxFit.contain),
          );
        },
      ),
    );
  }
}
