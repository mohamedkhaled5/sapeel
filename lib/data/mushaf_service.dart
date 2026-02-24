import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MushafService {
  static const String zipUrl =
      "https://api.quranpedia.net/api-quran-png/hafs.zip";

  static Future<bool> isDownloaded() async {
    final dir = await getApplicationDocumentsDirectory();
    return Directory("${dir.path}/mushaf").exists();
  }

  static Future<String> getMushafPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return "${dir.path}/mushaf";
  }

  static Future<void> downloadMushaf(
    Function(double progress) onProgress,
  ) async {
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
      onProgress(received / total);
    }).asFuture();

    await sink.close();

    await _extractZip(zipFile, dir.path);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("mushaf_downloaded", true);
  }

  static Future<void> _extractZip(File file, String targetPath) async {
    final bytes = file.readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final f in archive) {
      final filename = "$targetPath/mushaf/${f.name}";
      if (f.isFile) {
        final outFile = File(filename);
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(f.content);
      }
    }
  }
}
