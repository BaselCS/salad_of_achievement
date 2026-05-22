// ignore_for_file: use_build_context_synchronously

// ignore_for_file: avoid_print

import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';
import 'package:salad_of_achievement/logical/app_logger.dart';
import '../DB/models/data_model.dart';
import '../DB/models/object_box.dart';

/// Class to generate fake data for testing the app
class FakeDataGenerator {
  static final Random _random = Random();

  /// List of sample activity names in Arabic
  static final List<String> _sampleActivities = [
    'دراسة البرمجة',
    'قراءة القرآن',
    'ممارسة الرياضة',
    'تعلم اللغة الإنجليزية',
    'مراجعة الدروس',
    'كتابة المقالات',
    'تطوير التطبيقات',
    'حفظ القرآن',
    'دراسة الرياضيات',
    'تعلم التصميم',
    'قراءة الكتب',
    'مشاهدة الدورات التعليمية',
    'حل التمارين',
    'التأمل والذكر',
    'تطوير المهارات',
  ];

  /// Generate fake activities
  static Future<void> generateFakeActivities(ObjectBoxState objectBox) async {
    AppLogger.log('🎭 Generating fake activities...', tag: 'fake-data');

    // Clear existing activities - we'll use deleteAll() to clear everything
    List<Activity> existingActivities = objectBox.getAllActivities();
    for (Activity activity in existingActivities) {
      objectBox.deleteActivity(activity);
    }

    // Generate 8-12 random activities
    int numActivities = 8 + _random.nextInt(5);

    for (int i = 0; i < numActivities; i++) {
      String activityName =
          _sampleActivities[_random.nextInt(_sampleActivities.length)];

      // Ensure unique activity names
      while (objectBox.getAllActivities().any((a) => a.name == activityName)) {
        activityName =
            _sampleActivities[_random.nextInt(_sampleActivities.length)];
      }

      // Generate random time spent (30 minutes to 20 hours)
      int timeSpent = 30 + _random.nextInt(1170); // 30 to 1200 minutes

      Activity activity = Activity(name: activityName, timeSpent: timeSpent);

      objectBox.addActivity(activity);
    }

    AppLogger.log(
      '✅ Generated $numActivities fake activities',
      tag: 'fake-data',
    );
  }

  /// Generate fake sessions for the last 30 days
  static Future<void> generateFakeSessions(ObjectBoxState objectBox) async {
    AppLogger.log('🎭 Generating fake sessions...', tag: 'fake-data');

    // Clear existing sessions
    objectBox.deleteAllSessions();

    List<Activity> activities = objectBox.getAllActivities();
    if (activities.isEmpty) {
      AppLogger.log(
        '⚠️ No activities found. Generate activities first.',
        tag: 'fake-data',
      );
      return;
    }

    // Generate sessions for the last 30 days
    DateTime now = DateTime.now();
    int totalSessions = 0;

    for (int dayOffset = 0; dayOffset < 30; dayOffset++) {
      DateTime sessionDate = now.subtract(Duration(days: dayOffset));
      HijriCalendar hijriDate = HijriCalendar.fromDate(sessionDate);
      String hijriDateString =
          '${hijriDate.hYear}/${hijriDate.hMonth}/${hijriDate.hDay}';

      // Random number of sessions per day (0-5)
      int sessionsPerDay = _random.nextInt(6);

      for (int i = 0; i < sessionsPerDay; i++) {
        // Random activity
        Activity randomActivity =
            activities[_random.nextInt(activities.length)];

        // Random session duration (5, 10, 15, 20, 25, 30, 40, 50, or 60 minutes)
        List<int> possibleDurations = [5, 10, 15, 20, 25, 30, 40, 50, 60];
        int duration =
            possibleDurations[_random.nextInt(possibleDurations.length)];

        Session session = Session(
          date: hijriDateString,
          timeSpent: duration,
          activityName: randomActivity.name,
          group: randomActivity.group,
        );

        objectBox.addSession(session);
        totalSessions++;
      }
    }

    AppLogger.log(
      '✅ Generated $totalSessions fake sessions over 30 days',
      tag: 'fake-data',
    );
  }

  /// Generate fake fruit usage data
  static Future<void> generateFakeFruitUsage(ObjectBoxState objectBox) async {
    AppLogger.log('🎭 Generating fake fruit usage...', tag: 'fake-data');

    // Clear existing fruit usage
    List<int> fruitIds = [5, 10, 15, 20, 25, 30, 40, 50, 60];

    for (int fruitId in fruitIds) {
      objectBox.deleteFruitUsage(fruitId);
    }

    // Generate random usage for each fruit
    for (int fruitId in fruitIds) {
      int usageCount = _random.nextInt(50) + 1; // 1 to 50 uses

      // Add multiple uses for this fruit
      for (int i = 0; i < usageCount; i++) {
        objectBox.addFruitUsage(time: fruitId);
      }
    }

    AppLogger.log('✅ Generated fake fruit usage data', tag: 'fake-data');
  }

  /// Generate realistic settings
  static Future<void> generateFakeSettings(ObjectBoxState objectBox) async {
    AppLogger.log('🎭 Setting up realistic app settings...', tag: 'fake-data');

    // Set up realistic star thresholds and daily progress
    int dailyProgress = 120 + _random.nextInt(300); // 120 to 420 minutes

    objectBox.updateStares(
      newStar1: 120, // 2 hours for 1 star
      newStar2: 240, // 4 hours for 2 stars
      newStar3: 480, // 8 hours for 3 stars
    );

    // Set daily progress
    objectBox.doneMinutes = dailyProgress;

    // Update the settings through the public method
    objectBox.updateStares(newStar1: 120, newStar2: 240, newStar3: 480);

    AppLogger.log(
      '✅ Set up realistic settings with $dailyProgress minutes of daily progress',
      tag: 'fake-data',
    );
  }

  /// Generate all fake data at once
  static Future<void> generateAllFakeData(ObjectBoxState objectBox) async {
    AppLogger.log('🎭 Starting fake data generation...', tag: 'fake-data');
    AppLogger.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', tag: 'fake-data');

    await generateFakeActivities(objectBox);
    await generateFakeSessions(objectBox);
    await generateFakeFruitUsage(objectBox);
    await generateFakeSettings(objectBox);

    AppLogger.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', tag: 'fake-data');
    AppLogger.log('🎉 All fake data generated successfully!', tag: 'fake-data');
    AppLogger.log(
      '📊 Your app is now ready for testing with sample data',
      tag: 'fake-data',
    );

    // Print summary
    List<Activity> activities = objectBox.getAllActivities();
    List<Session> sessions = objectBox.getAllSessions();

    AppLogger.log('📈 Summary:', tag: 'fake-data');
    AppLogger.log('   - ${activities.length} activities', tag: 'fake-data');
    AppLogger.log('   - ${sessions.length} sessions', tag: 'fake-data');
    AppLogger.log(
      '   - ${objectBox.doneMinutes} minutes of daily progress',
      tag: 'fake-data',
    );
    AppLogger.log(
      '   - Fruit usage data for all time intervals',
      tag: 'fake-data',
    );
  }

  /// Clear all fake data
  static Future<void> clearAllData(ObjectBoxState objectBox) async {
    AppLogger.log('🧹 Clearing all data...', tag: 'fake-data');

    objectBox.deleteAll();

    AppLogger.log('✅ All data cleared successfully', tag: 'fake-data');
  }

  /// Generate data for a specific scenario
  static Future<void> generateScenarioData(
    ObjectBoxState objectBox,
    String scenario,
  ) async {
    switch (scenario.toLowerCase()) {
      case 'beginner':
        await _generateBeginnerData(objectBox);
        break;
      case 'active':
        await _generateActiveUserData(objectBox);
        break;
      case 'expert':
        await _generateExpertData(objectBox);
        break;
      default:
        await generateAllFakeData(objectBox);
    }
  }

  /// Generate data for a beginner user
  static Future<void> _generateBeginnerData(ObjectBoxState objectBox) async {
    AppLogger.log('🌱 Generating beginner user data...', tag: 'fake-data');

    objectBox.deleteAll();

    // Few activities
    List<String> beginnerActivities = [
      'قراءة القرآن',
      'ممارسة الرياضة',
      'دراسة البرمجة',
    ];

    for (String activityName in beginnerActivities) {
      Activity activity = Activity(
        name: activityName,
        timeSpent: _random.nextInt(60) + 30,
      );
      objectBox.addActivity(activity);
    }

    // Few sessions in last week only
    DateTime now = DateTime.now();
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      if (_random.nextBool()) {
        // 50% chance of having sessions
        DateTime sessionDate = now.subtract(Duration(days: dayOffset));
        HijriCalendar hijriDate = HijriCalendar.fromDate(sessionDate);
        String hijriDateString =
            '${hijriDate.hYear}/${hijriDate.hMonth}/${hijriDate.hDay}';

        final String activityName =
            beginnerActivities[_random.nextInt(beginnerActivities.length)];
        Session session = Session(
          date: hijriDateString,
          timeSpent: [5, 10, 15][_random.nextInt(3)], // Short sessions
          activityName: activityName,
          group:
              objectBox
                  .getAllActivities()
                  .firstWhereOrNull((activity) => activity.name == activityName)
                  ?.group ??
              'General',
        );
        objectBox.addSession(session);
      }
    }

    objectBox.doneMinutes = 45; // Low daily progress
    AppLogger.log('✅ Beginner data generated', tag: 'fake-data');
  }

  /// Generate data for an active user
  static Future<void> _generateActiveUserData(ObjectBoxState objectBox) async {
    AppLogger.log('🔥 Generating active user data...', tag: 'fake-data');

    objectBox.deleteAll();
    await generateFakeActivities(objectBox);
    await generateFakeSessions(objectBox);
    await generateFakeFruitUsage(objectBox);

    objectBox.doneMinutes = 280; // High daily progress
    AppLogger.log('✅ Active user data generated', tag: 'fake-data');
  }

  /// Generate data for an expert user
  static Future<void> _generateExpertData(ObjectBoxState objectBox) async {
    AppLogger.log('🏆 Generating expert user data...', tag: 'fake-data');

    objectBox.deleteAll();
    await generateFakeActivities(objectBox);

    // Generate more sessions with longer durations
    List<Activity> activities = objectBox.getAllActivities();
    DateTime now = DateTime.now();

    for (int dayOffset = 0; dayOffset < 60; dayOffset++) {
      // 60 days of data
      DateTime sessionDate = now.subtract(Duration(days: dayOffset));
      HijriCalendar hijriDate = HijriCalendar.fromDate(sessionDate);
      String hijriDateString =
          '${hijriDate.hYear}/${hijriDate.hMonth}/${hijriDate.hDay}';

      int sessionsPerDay = 3 + _random.nextInt(5); // 3-7 sessions per day

      for (int i = 0; i < sessionsPerDay; i++) {
        Activity randomActivity =
            activities[_random.nextInt(activities.length)];
        List<int> expertDurations = [25, 30, 40, 50, 60]; // Longer sessions
        int duration = expertDurations[_random.nextInt(expertDurations.length)];

        Session session = Session(
          date: hijriDateString,
          timeSpent: duration,
          activityName: randomActivity.name,
          group: randomActivity.group,
        );
        objectBox.addSession(session);
      }
    }

    await generateFakeFruitUsage(objectBox);
    objectBox.doneMinutes = 520; // Very high daily progress
    AppLogger.log('✅ Expert user data generated', tag: 'fake-data');
  }
}

/// Show dialog to generate fake data for testing
void showFakeDataDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('🎭 Generate Test Data'),
        content: const Text('Choose what type of test data to generate:'),
        actions: <Widget>[
          TextButton(
            child: const Text('Clear All'),
            onPressed: () async {
              Navigator.of(context).pop();
              final objectBox = Provider.of<ObjectBoxState>(
                context,
                listen: false,
              );
              await FakeDataGenerator.clearAllData(objectBox);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🧹 All data cleared!')),
              );
            },
          ),
          TextButton(
            child: const Text('Beginner'),
            onPressed: () async {
              Navigator.of(context).pop();
              final objectBox = Provider.of<ObjectBoxState>(
                context,
                listen: false,
              );
              await FakeDataGenerator.generateScenarioData(
                objectBox,
                'beginner',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🌱 Beginner data generated!')),
              );
            },
          ),
          TextButton(
            child: const Text('Active User'),
            onPressed: () async {
              Navigator.of(context).pop();
              final objectBox = Provider.of<ObjectBoxState>(
                context,
                listen: false,
              );
              await FakeDataGenerator.generateScenarioData(objectBox, 'active');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🔥 Active user data generated!')),
              );
            },
          ),
          TextButton(
            child: const Text('Expert'),
            onPressed: () async {
              Navigator.of(context).pop();
              final objectBox = Provider.of<ObjectBoxState>(
                context,
                listen: false,
              );
              await FakeDataGenerator.generateScenarioData(objectBox, 'expert');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🏆 Expert data generated!')),
              );
            },
          ),
        ],
      );
    },
  );
}
