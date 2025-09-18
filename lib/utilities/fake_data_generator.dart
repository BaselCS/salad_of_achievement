// ignore_for_file: avoid_print

import 'dart:math';
import 'package:hijri/hijri_calendar.dart';
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
    print('🎭 Generating fake activities...');

    // Clear existing activities - we'll use deleteAll() to clear everything
    List<Activity> existingActivities = objectBox.getAllActivities();
    for (Activity activity in existingActivities) {
      objectBox.deleteActivity(activity);
    }

    // Generate 8-12 random activities
    int numActivities = 8 + _random.nextInt(5);

    for (int i = 0; i < numActivities; i++) {
      String activityName = _sampleActivities[_random.nextInt(_sampleActivities.length)];

      // Ensure unique activity names
      while (objectBox.getAllActivities().any((a) => a.name == activityName)) {
        activityName = _sampleActivities[_random.nextInt(_sampleActivities.length)];
      }

      // Generate random time spent (30 minutes to 20 hours)
      int timeSpent = 30 + _random.nextInt(1170); // 30 to 1200 minutes

      Activity activity = Activity(name: activityName, timeSpent: timeSpent);

      objectBox.addActivity(activity);
    }

    print('✅ Generated $numActivities fake activities');
  }

  /// Generate fake sessions for the last 30 days
  static Future<void> generateFakeSessions(ObjectBoxState objectBox) async {
    print('🎭 Generating fake sessions...');

    // Clear existing sessions
    objectBox.deleteAllSessions();

    List<Activity> activities = objectBox.getAllActivities();
    if (activities.isEmpty) {
      print('⚠️ No activities found. Generate activities first.');
      return;
    }

    // Generate sessions for the last 30 days
    DateTime now = DateTime.now();
    int totalSessions = 0;

    for (int dayOffset = 0; dayOffset < 30; dayOffset++) {
      DateTime sessionDate = now.subtract(Duration(days: dayOffset));
      HijriCalendar hijriDate = HijriCalendar.fromDate(sessionDate);
      String hijriDateString = '${hijriDate.hYear}/${hijriDate.hMonth}/${hijriDate.hDay}';

      // Random number of sessions per day (0-5)
      int sessionsPerDay = _random.nextInt(6);

      for (int i = 0; i < sessionsPerDay; i++) {
        // Random activity
        Activity randomActivity = activities[_random.nextInt(activities.length)];

        // Random session duration (5, 10, 15, 20, 25, 30, 40, 50, or 60 minutes)
        List<int> possibleDurations = [5, 10, 15, 20, 25, 30, 40, 50, 60];
        int duration = possibleDurations[_random.nextInt(possibleDurations.length)];

        Session session = Session(date: hijriDateString, timeSpent: duration, topic: randomActivity.name);

        objectBox.addSession(session);
        totalSessions++;
      }
    }

    print('✅ Generated $totalSessions fake sessions over 30 days');
  }

  /// Generate fake fruit usage data
  static Future<void> generateFakeFruitUsage(ObjectBoxState objectBox) async {
    print('🎭 Generating fake fruit usage...');

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

    print('✅ Generated fake fruit usage data');
  }

  /// Generate realistic settings
  static Future<void> generateFakeSettings(ObjectBoxState objectBox) async {
    print('🎭 Setting up realistic app settings...');

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

    print('✅ Set up realistic settings with $dailyProgress minutes of daily progress');
  }

  /// Generate all fake data at once
  static Future<void> generateAllFakeData(ObjectBoxState objectBox) async {
    print('🎭 Starting fake data generation...');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    await generateFakeActivities(objectBox);
    await generateFakeSessions(objectBox);
    await generateFakeFruitUsage(objectBox);
    await generateFakeSettings(objectBox);

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🎉 All fake data generated successfully!');
    print('📊 Your app is now ready for testing with sample data');

    // Print summary
    List<Activity> activities = objectBox.getAllActivities();
    List<Session> sessions = objectBox.getAllSessions();

    print('📈 Summary:');
    print('   - ${activities.length} activities');
    print('   - ${sessions.length} sessions');
    print('   - ${objectBox.doneMinutes} minutes of daily progress');
    print('   - Fruit usage data for all time intervals');
  }

  /// Clear all fake data
  static Future<void> clearAllData(ObjectBoxState objectBox) async {
    print('🧹 Clearing all data...');

    objectBox.deleteAll();

    print('✅ All data cleared successfully');
  }

  /// Generate data for a specific scenario
  static Future<void> generateScenarioData(ObjectBoxState objectBox, String scenario) async {
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
    print('🌱 Generating beginner user data...');

    objectBox.deleteAll();

    // Few activities
    List<String> beginnerActivities = ['قراءة القرآن', 'ممارسة الرياضة', 'دراسة البرمجة'];

    for (String activityName in beginnerActivities) {
      Activity activity = Activity(name: activityName, timeSpent: _random.nextInt(60) + 30);
      objectBox.addActivity(activity);
    }

    // Few sessions in last week only
    DateTime now = DateTime.now();
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      if (_random.nextBool()) {
        // 50% chance of having sessions
        DateTime sessionDate = now.subtract(Duration(days: dayOffset));
        HijriCalendar hijriDate = HijriCalendar.fromDate(sessionDate);
        String hijriDateString = '${hijriDate.hYear}/${hijriDate.hMonth}/${hijriDate.hDay}';

        Session session = Session(
          date: hijriDateString,
          timeSpent: [5, 10, 15][_random.nextInt(3)], // Short sessions
          topic: beginnerActivities[_random.nextInt(beginnerActivities.length)],
        );
        objectBox.addSession(session);
      }
    }

    objectBox.doneMinutes = 45; // Low daily progress
    print('✅ Beginner data generated');
  }

  /// Generate data for an active user
  static Future<void> _generateActiveUserData(ObjectBoxState objectBox) async {
    print('🔥 Generating active user data...');

    objectBox.deleteAll();
    await generateFakeActivities(objectBox);
    await generateFakeSessions(objectBox);
    await generateFakeFruitUsage(objectBox);

    objectBox.doneMinutes = 280; // High daily progress
    print('✅ Active user data generated');
  }

  /// Generate data for an expert user
  static Future<void> _generateExpertData(ObjectBoxState objectBox) async {
    print('🏆 Generating expert user data...');

    objectBox.deleteAll();
    await generateFakeActivities(objectBox);

    // Generate more sessions with longer durations
    List<Activity> activities = objectBox.getAllActivities();
    DateTime now = DateTime.now();

    for (int dayOffset = 0; dayOffset < 60; dayOffset++) {
      // 60 days of data
      DateTime sessionDate = now.subtract(Duration(days: dayOffset));
      HijriCalendar hijriDate = HijriCalendar.fromDate(sessionDate);
      String hijriDateString = '${hijriDate.hYear}/${hijriDate.hMonth}/${hijriDate.hDay}';

      int sessionsPerDay = 3 + _random.nextInt(5); // 3-7 sessions per day

      for (int i = 0; i < sessionsPerDay; i++) {
        Activity randomActivity = activities[_random.nextInt(activities.length)];
        List<int> expertDurations = [25, 30, 40, 50, 60]; // Longer sessions
        int duration = expertDurations[_random.nextInt(expertDurations.length)];

        Session session = Session(date: hijriDateString, timeSpent: duration, topic: randomActivity.name);
        objectBox.addSession(session);
      }
    }

    await generateFakeFruitUsage(objectBox);
    objectBox.doneMinutes = 520; // Very high daily progress
    print('✅ Expert user data generated');
  }
}
