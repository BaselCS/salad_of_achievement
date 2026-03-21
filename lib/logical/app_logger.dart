import 'dart:developer' as developer;
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class AppLogger {
  static File? _logFile;

  static void log(String message, {String tag = 'app'}) {
    final String line = '${DateTime.now().toIso8601String()} [$tag] $message';
    developer.log(message, name: tag);
    _append(line);
  }

  static Future<String> getLogFilePath() async {
    final file = await _getLogFile();
    return file.path;
  }

  static Future<String> readLogs({int maxChars = 50000}) async {
    final file = await _getLogFile();
    final String content = await file.readAsString();
    if (content.length <= maxChars) {
      return content;
    }
    return content.substring(content.length - maxChars);
  }

  static Future<void> clearLogs() async {
    final file = await _getLogFile();
    await file.writeAsString('');
  }

  static Future<void> shareLogs() async {
    final file = await _getLogFile();
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: 'Salad of Achievement Logs'));
  }

  static Future<File> _getLogFile() async {
    if (_logFile != null) {
      return _logFile!;
    }

    final dir = await getApplicationDocumentsDirectory();
    final logsDir = Directory('${dir.path}/logs');
    if (!await logsDir.exists()) {
      await logsDir.create(recursive: true);
    }

    final file = File('${logsDir.path}/app.log');
    if (!await file.exists()) {
      await file.create(recursive: true);
    }

    _logFile = file;
    return file;
  }

  static void _append(String line) {
    _getLogFile()
        .then((file) {
          file.writeAsString('$line\n', mode: FileMode.append, flush: true);
        })
        .catchError((error) {
          developer.log('Failed to write log file: $error', name: 'app-logger');
        });
  }
}
