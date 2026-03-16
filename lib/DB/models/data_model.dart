import 'package:objectbox/objectbox.dart';

@Entity()
class Session {
  @Id()
  int id;
  String date;
  int timeSpent;
  String activityName;

  Session({
    this.id = 0, // ObjectBox IDs start at 0
    required this.date,
    required this.timeSpent,
    required this.activityName,
  });

  // Convert a Session into a Map. The keys must correspond to the names of the columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date, // Format: YYYY-MM-DD
      'time_spent': timeSpent,
      'activityName': activityName,
    };
  }

  @override
  String toString() {
    return 'Session{id: $id, date: $date, timeSpent: $timeSpent, activityName: $activityName}\n';
  }
}

@Entity()
class Activity {
  @Id()
  int id;
  String name;
  int timeSpent;
  bool isArchived;

  Activity({
    this.id = 0, // ObjectBox IDs start at 0
    required this.name,
    required this.timeSpent,
    this.isArchived = false,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'time_spent': timeSpent, 'is_archived': isArchived};
  }

  @override
  String toString() {
    return 'Activity{id: $id, name: $name, timeSpent: $timeSpent, isArchived: $isArchived}';
  }
}

@Entity()
class FruitUsage {
  @Id(assignable: true)
  int id;
  int usageCount;

  FruitUsage({
    this.id = 0, // ObjectBox IDs start at 0
    required this.usageCount,
  });

  Map<int, int> toMap() {
    return {id: usageCount};
  }

  @override
  String toString() {
    return 'FruitUsage{id: $id, usageCount: $usageCount}';
  }
}

@Entity()
class Setting {
  @Id()
  int id;
  int star1;
  int star2;
  int star3;
  int hourOfRest; //الساعة الي يصفر بعدها بنظام 24 ساعة
  String timeOfRest = '';
  int doneMinutes;
  Setting({this.id = 0, this.star1 = 120, this.star2 = 240, this.star3 = 480, this.hourOfRest = 4, this.timeOfRest = '', this.doneMinutes = 0});

  Map<String, dynamic> toMap() {
    return {'id': id, 'star1': star1, 'star2': star2, 'star3': star3, 'done_minutes': doneMinutes, 'hour_of_rest': hourOfRest, 'time_of_rest': timeOfRest};
  }

  @override
  String toString() {
    return 'Setting{id: $id, star1: $star1, star2: $star2, star3: $star3, doneMinutes: $doneMinutes ,hourOfRest: $hourOfRest, timeOfRest: $timeOfRest}';
  }
}

class UserStatistics {
  static String mostProductiveDate = '';
  static int mostProductiveDay = 0;
  static double averageDailyProductivity = 0;

  // Convert a UserStatistics instance into a Map for ObjectBox.
  Map<String, dynamic> toMap() {
    return {'mostProductiveDate': mostProductiveDate, 'mostProductiveDay': mostProductiveDay, 'averageDailyProductivity': averageDailyProductivity};
  }

  @override
  String toString() {
    return 'UserStatistics{mostProductiveDate:$mostProductiveDate ,mostProductiveDay: $mostProductiveDay, averageDailyProductivity: $averageDailyProductivity}';
  }
}

class GroupedSessions {
  String date;
  String dayName;
  int totalMinutes = 0;
  List<Session> sessions;
  GroupedSessions({required this.date, required this.dayName, required this.sessions, required this.totalMinutes});

  Map<String, dynamic> toMap() {
    return {'date': date, 'day_name': dayName, 'sessions': sessions};
  }

  @override
  String toString() {
    return 'GroupedSessions{date: $date, dayName: $dayName, sessions: \n[$sessions]\n}';
  }
}
