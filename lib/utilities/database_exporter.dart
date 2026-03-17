import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart'; // for debugPrint or just use print
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../DB/models/object_box.dart';

class DatabaseExporter {
  final ObjectBoxState objectBox;

  DatabaseExporter(this.objectBox);

  /// Exports the entire database (Sessions, Activities, FruitUsage) to a JSON file
  Future<void> exportToJson() async {
    try {
      // 1. Gather all data
      final sessions = objectBox.getAllSessions().map((e) => e.toMap()).toList();
      final activities = objectBox.getAllActivities().map((e) => e.toMap()).toList();

      // Handle FruitUsage specially since its toMap returns Map<int,int> which isn't valid JSON
      final fruitUsage = objectBox.getAllFruitUsage().map((e) => {'id': e.id, 'usageCount': e.usageCount}).toList();

      final Map<String, dynamic> data = {
        'sessions': sessions,
        'activities': activities,
        'fruit_usage': fruitUsage,
        'export_date': DateTime.now().toIso8601String(),
      };

      // 2. Convert to JSON String
      final String jsonString = jsonEncode(data);

      // 3. Write to file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/salad_achievement_backup.json');
      await file.writeAsString(jsonString);

      // 4. Share the file
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: 'Salad of Achievement Backup (JSON)'));
    } catch (e) {
      debugPrint("Error exporting JSON: $e");
    }
  }

  /// Exports the Sessions to a CSV file (Spreadsheet compatible)
  Future<void> exportSessionsToCsv() async {
    try {
      final sessions = objectBox.getAllSessions();

      // 1. Create CSV String manually
      // Header
      String csvContent = 'ID,Date,Time Spent (min),Activity Name\n';

      // Rows
      for (var session in sessions) {
        // Escape commas in activity name if necessary to avoid breaking CSV format
        final cleanActivityName = session.activityName.replaceAll(',', ' ');
        csvContent += '${session.id},${session.date},${session.timeSpent},$cleanActivityName\n';
      }

      // 2. Write to file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/sessions_export.csv');
      await file.writeAsString(csvContent);

      // 3. Share the file
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: 'Sessions Export (CSV)'));
    } catch (e) {
      debugPrint("Error exporting CSV: $e");
    }
  }
}
