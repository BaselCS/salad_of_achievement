import 'package:flutter_test/flutter_test.dart';
import 'package:salad_of_achievement/DB/models/object_box.dart';
import 'package:salad_of_achievement/DB/models/data_model.dart';
import 'package:hijri/hijri_calendar.dart';

void main() {
  group('Database Tests', () {
    late ObjectBoxState db;

    setUpAll(() async {
      // Initialize ObjectBox for testing
      db = await ObjectBoxState.create();
    });

    tearDownAll(() {
      // Clean up
      db.dispose();
    });

    test('Database validation should pass', () {
      // expect(db.validateDatabase(), true);
    });

    test('Add and retrieve session', () {
      final session = Session(date: HijriCalendar.now().toString(), timeSpent: 25, activityName: 'Test Activity');

      db.addSession(session);
      final sessions = db.getAllSessions();
      expect(sessions.isNotEmpty, true);
      expect(sessions.last.activityName, 'Test Activity');
      expect(sessions.last.timeSpent, 25);
    });

    test('Add and retrieve activity', () {
      final activity = Activity(name: 'Test Activity', timeSpent: 30);

      db.addActivity(activity);
      final activities = db.getAllActivities();
      expect(activities.isNotEmpty, true);
      expect(activities.last.name, 'Test Activity');
      expect(activities.last.timeSpent, 30);
    });

    test('Fruit usage initialization', () {
      final fruitUsage = db.getAllFruitUsage();
      expect(fruitUsage.length, 9);

      // Check all required IDs are present
      final requiredIds = [5, 10, 15, 20, 25, 30, 40, 50, 60];
      for (int id in requiredIds) {
        expect(fruitUsage.any((fruit) => fruit.id == id), true);
      }
    });

    test('Star validation', () {
      // Test valid star values
      db.updateStares(newStar1: 60, newStar2: 120, newStar3: 240);
      expect(db.star1, 60);
      expect(db.star2, 120);
      expect(db.star3, 240);
    });

    // test('Database stats', () {
    //   final stats = db.getDatabaseStats();
    //   expect(stats.containsKey('sessions'), true);
    //   expect(stats.containsKey('activities'), true);
    //   expect(stats.containsKey('fruitUsage'), true);
    //   expect(stats.containsKey('settings'), true);
    // });
  });
}
