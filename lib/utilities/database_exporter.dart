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
      rows.add(['ID', 'Date', 'Time Spent (min)', 'Activity Name', 'Group']);

      // Rows
      for (var session in sessions) {
        rows.add([
          session.id,
          session.date,
          session.timeSpent,
          session.activityName,
          session.group ?? 'مرجأة',
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
  Future<bool> importFromJson({String fallbackGroup = 'مرجأة'}) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final Map<String, dynamic> data = jsonDecode(content);
        final List<dynamic> activitiesJson =
            (data['activities'] as List<dynamic>?) ?? <dynamic>[];
        final List<dynamic> sessionsJson =
            (data['sessions'] as List<dynamic>?) ?? <dynamic>[];
        final List<dynamic> fruitJson =
            (data['fruit_usage'] as List<dynamic>?) ?? <dynamic>[];

        // Replace current data with imported data.
        objectBox.deleteAll();
        final String currentSessionDate = objectBox.getCurrentSessionDate();
        int currentSessionMinutes = 0;

        final Map<String, Activity> activitiesByName = {};
        final Map<String, Map<String, dynamic>> activitySnapshots = {};
        final Map<String, int> activityDurations = {};

        for (final actJson in activitiesJson) {
          final String activityName = actJson['name']?.toString() ?? 'غير محدد';
          final String activityGroup =
              actJson['group_name']?.toString() ??
              actJson['group']?.toString() ??
              fallbackGroup;
          activitySnapshots[activityName] = Map<String, dynamic>.from(actJson);
          final activity = Activity(
            name: activityName,
            timeSpent: 0,
            isArchived: actJson['is_archived'] ?? false,
            group: activityGroup,
          );
          objectBox.addActivity(activity);
          activitiesByName[activityName] = activity;
        }

        for (final sessJson in sessionsJson) {
          final String activityName =
              sessJson['activityName']?.toString() ?? 'غير محدد';
          final int sessionMinutes =
              sessJson['duration_in_minutes'] ??
              sessJson['time_spent'] ??
              sessJson['timeSpent'] ??
              0;
          final String group =
              sessJson['group_name']?.toString() ??
              sessJson['group']?.toString() ??
              activitiesByName[activityName]?.group ??
              fallbackGroup;

          if (!activitiesByName.containsKey(activityName)) {
            final importedActivity = Activity(
              name: activityName,
              timeSpent: 0,
              group: group,
            );
            objectBox.addActivity(importedActivity);
            activitiesByName[activityName] = importedActivity;
          }

          final session = Session(
            date: sessJson['date']?.toString() ?? '',
            timeSpent: sessionMinutes,
            activityName: activityName,
            group: group,
          );
          objectBox.addSession(session);
          if (session.date == currentSessionDate) {
            currentSessionMinutes += sessionMinutes;
          }
          activityDurations[activityName] =
              (activityDurations[activityName] ?? 0) + sessionMinutes;
        }

        for (final entry in activitySnapshots.entries) {
          final Activity? activity = activitiesByName[entry.key];
          if (activity == null) {
            continue;
          }
          final snapshot = entry.value;
          final int restoredTimeSpent =
              activityDurations[entry.key] ??
              snapshot['time_spent'] ??
              snapshot['timeSpent'] ??
              activity.timeSpent;
          objectBox.updateActivity(
            activity,
            snapshot['name']?.toString() ?? activity.name,
            restoredTimeSpent,
            snapshot['group_name']?.toString() ?? snapshot['group']?.toString(),
          );
        }

        for (final entry in activityDurations.entries) {
          if (activitiesByName.containsKey(entry.key)) {
            continue;
          }
          final Activity? activity = objectBox
              .getAllActivities()
              .firstWhereOrNull((item) => item.name == entry.key);
          if (activity == null) {
            continue;
          }
          objectBox.updateActivity(
            activity,
            activity.name,
            entry.value,
            activity.group,
          );
        }

        objectBox.setDoneMinutes(currentSessionMinutes);

        for (final fJson in fruitJson) {
          objectBox.setFruitUsageCount(
            fJson['id'] as int,
            fJson['usageCount'] as int? ?? 0,
          );
        }

        return true;
      }
    } catch (e) {
      debugPrint("Error importing JSON: $e");
    }
    return false;
  }

  /// Imports sessions from a CSV file
  Future<bool> importSessionsFromCsv({String fallbackGroup = 'مرجأة'}) async {
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

        // Replace current data with imported data.
        objectBox.deleteAll();
        final String currentSessionDate = objectBox.getCurrentSessionDate();
        int currentSessionMinutes = 0;

        final Set<String> importedActivities = <String>{};
        final Map<String, int> activityDurations = {};

        // Skip header
        for (var i = 1; i < rows.length; i++) {
          final row = rows[i];
          if (row.length < 4) continue;

          // CSV Format: ID, Date, Time Spent, Activity Name
          final String activityName = row[3].toString();
          final String group =
              row.length >= 5 && row[4].toString().trim().isNotEmpty
              ? row[4].toString()
              : fallbackGroup;
          final session = Session(
            date: row[1].toString(),
            timeSpent: int.tryParse(row[2].toString()) ?? 0,
            activityName: activityName,
            group: group,
          );

          final existingActivity = objectBox
              .getAllActivities()
              .firstWhereOrNull((activity) => activity.name == activityName);
          if (existingActivity == null &&
              !importedActivities.contains(activityName)) {
            objectBox.addActivity(
              Activity(name: activityName, timeSpent: 0, group: group),
            );
            importedActivities.add(activityName);
          }

          objectBox.addSession(session);
          if (session.date == currentSessionDate) {
            currentSessionMinutes += session.timeSpent;
          }
          activityDurations[activityName] =
              (activityDurations[activityName] ?? 0) + session.timeSpent;

          if (existingActivity != null) {
            objectBox.updateActivity(
              existingActivity,
              existingActivity.name,
              activityDurations[activityName] ?? existingActivity.timeSpent,
              group,
            );
          }
        }

        for (final entry in activityDurations.entries) {
          final activity = objectBox.getAllActivities().firstWhereOrNull(
            (item) => item.name == entry.key,
          );
          if (activity == null) {
            continue;
          }
          objectBox.updateActivity(
            activity,
            activity.name,
            entry.value,
            activity.group,
          );
        }

        objectBox.setDoneMinutes(currentSessionMinutes);
        return true;
      }
    } catch (e) {
      debugPrint("Error importing CSV: $e");
    }
    return false;
  }
}
