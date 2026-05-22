import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import '../DB/models/object_box.dart';
import '../DB/models/data_model.dart';

class DatabaseExporter {
  final ObjectBoxState objectBox;

  DatabaseExporter(this.objectBox);

  /// Exports the entire database (Sessions, Activities, FruitUsage) to a JSON file
  Future<void> exportToJson() async {
    try {
      // 1. Gather all data
      final sessions = objectBox
          .getAllSessions()
          .map((e) => e.toMap())
          .toList();
      final activities = objectBox
          .getAllActivities()
          .map((e) => e.toMap())
          .toList();

      // Handle FruitUsage specially since its toMap returns Map<int,int> which isn't valid JSON
      final fruitUsage = objectBox
          .getAllFruitUsage()
          .map((e) => {'id': e.id, 'usageCount': e.usageCount})
          .toList();

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
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Salad of Achievement Backup (JSON)',
        ),
      );
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
      List<List<dynamic>> rows = [];
      rows.add(['ID', 'Date', 'Time Spent (min)', 'Activity Name']);

      // Rows
      for (var session in sessions) {
        rows.add([
          session.id,
          session.date,
          session.timeSpent,
          session.activityName,
          session.group ?? 'General',
        ]);
      }

      String csvContent = csv.encode(rows);

      // 2. Write to file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/sessions_export.csv');
      await file.writeAsString(csvContent);

      // 3. Share the file
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: 'Sessions Export (CSV)'),
      );
    } catch (e) {
      debugPrint("Error exporting CSV: $e");
    }
  }

  /// Imports database from a JSON file
  Future<bool> importFromJson() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final Map<String, dynamic> data = jsonDecode(content);

        // Clear existing data before importing (optional, but safer for consistency)
        // Or we could merge. Given "import the DB", replacement is often expected.
        // Let's go with adding/merging to be less destructive, but deduplicating session IDs if needed.
        // Actually, objectbox IDs are auto-generated if we set them to 0.

        if (data.containsKey('activities')) {
          final List<dynamic> activitiesJson = data['activities'];
          for (var actJson in activitiesJson) {
            final activity = Activity(
              name: actJson['name'],
              timeSpent: actJson['time_spent'],
              isArchived: actJson['is_archived'] ?? false,
              group: actJson['group'] ?? 'General',
            );
            objectBox.addActivity(activity);
          }
        }

        if (data.containsKey('sessions')) {
          final List<dynamic> sessionsJson = data['sessions'];
          for (var sessJson in sessionsJson) {
            final String activityName = sessJson['activityName'];
            final String group =
                sessJson['group'] ??
                objectBox
                    .getAllActivities()
                    .firstWhereOrNull(
                      (activity) => activity.name == activityName,
                    )
                    ?.group ??
                'General';
            final session = Session(
              date: sessJson['date'],
              timeSpent: sessJson['time_spent'],
              activityName: activityName,
              group: group,
            );
            objectBox.addSession(session);
          }
        }

        if (data.containsKey('fruit_usage')) {
          final List<dynamic> fruitJson = data['fruit_usage'];
          for (var fJson in fruitJson) {
            // FruitUsage handles its own logic in addFruitUsage,
            // but for a full import we might want to set specific counts.
            // Since addFruitUsage increments, we might need a direct put.
            // But objectBox doesn't expose a direct put for FruitUsage in a bulk way.
            // For now, let's just add it if usageCount > 0
            for (int i = 0; i < (fJson['usageCount'] ?? 0); i++) {
              objectBox.addFruitUsage(time: fJson['id']);
            }
          }
        }

        return true;
      }
    } catch (e) {
      debugPrint("Error importing JSON: $e");
    }
    return false;
  }

  /// Imports sessions from a CSV file
  Future<bool> importSessionsFromCsv() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        List<List<dynamic>> rows = csv.decode(content);

        if (rows.length <= 1) return false; // Only header or empty

        // Skip header
        for (var i = 1; i < rows.length; i++) {
          final row = rows[i];
          if (row.length < 4) continue;

          // CSV Format: ID, Date, Time Spent, Activity Name
          final String activityName = row[3].toString();
          final String group =
              row.length >= 5 && row[4].toString().trim().isNotEmpty
              ? row[4].toString()
              : objectBox
                        .getAllActivities()
                        .firstWhereOrNull(
                          (activity) => activity.name == activityName,
                        )
                        ?.group ??
                    'General';
          final session = Session(
            date: row[1].toString(),
            timeSpent: int.tryParse(row[2].toString()) ?? 0,
            activityName: activityName,
            group: group,
          );
          objectBox.addSession(session);
        }
        return true;
      }
    } catch (e) {
      debugPrint("Error importing CSV: $e");
    }
    return false;
  }
}
