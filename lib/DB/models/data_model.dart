import 'package:objectbox/objectbox.dart';

@Entity()
class ActivityGroup {
  @Id()
  int id;
  String name;

  @Backlink('groupRef')
  final ToMany<Activity> activities = ToMany<Activity>();

  ActivityGroup({this.id = 0, required this.name});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  @override
  String toString() {
    return 'ActivityGroup{id: $id, name: $name}';
  }
}

@Entity()
class Activity {
  @Id()
  int id;
  String name;
  int timeSpent;
  bool isArchived;

  @Backlink('activityRef')
  final ToMany<Session> sessions = ToMany<Session>();

  final ToOne<ActivityGroup> groupRef = ToOne<ActivityGroup>();

  @Transient()
  String _fallbackGroupName = 'مرجأة';

  String get group => groupRef.target?.name ?? _fallbackGroupName;
  set group(String value) {
    _fallbackGroupName = value.trim().isEmpty ? 'مرجأة' : value.trim();
  }

  Activity({
    this.id = 0,
    required this.name,
    required this.timeSpent,
    this.isArchived = false,
    String group = 'مرجأة',
    ActivityGroup? groupEntity,
  }) {
    this.group = group;
    if (groupEntity != null) {
      groupRef.target = groupEntity;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'time_spent': timeSpent,
      'is_archived': isArchived,
      'group_name': group,
      'group_id': groupRef.targetId,
    };
  }

  @override
  String toString() {
    return 'Activity{id: $id, name: $name, timeSpent: $timeSpent, isArchived: $isArchived, group: $group}';
  }
}

@Entity()
class Session {
  @Id()
  int id;
  int durationInMinutes;
  String date;

  final ToOne<Activity> activityRef = ToOne<Activity>();

  @Transient()
  String _activityNameFallback = 'غير محدد';

  @Transient()
  String _groupNameFallback = 'مرجأة';

  int get timeSpent => durationInMinutes;
  set timeSpent(int value) {
    durationInMinutes = value;
  }

  String get activityName => activityRef.target?.name ?? _activityNameFallback;
  set activityName(String value) {
    _activityNameFallback = value.trim().isEmpty ? 'غير محدد' : value.trim();
  }

  String? get group =>
      activityRef.target?.groupRef.target?.name ?? _groupNameFallback;
  set group(String? value) {
    _groupNameFallback = value == null || value.trim().isEmpty
        ? 'مرجأة'
        : value.trim();
  }

  Session({
    this.id = 0,
    required this.date,
    int? durationInMinutes,
    int? timeSpent,
    Activity? activity,
    String? activityName,
    String? group,
  }) : durationInMinutes = durationInMinutes ?? timeSpent ?? 0 {
    if (activity != null) {
      activityRef.target = activity;
    }
    if (activityName != null) {
      this.activityName = activityName;
    }
    if (group != null) {
      this.group = group;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'duration_in_minutes': durationInMinutes,
      'time_spent': durationInMinutes,
      'activity_id': activityRef.targetId,
      'activityName': activityName,
      'group_name': group,
    };
  }

  @override
  String toString() {
    return 'Session{id: $id, date: $date, durationInMinutes: $durationInMinutes, activityName: $activityName, group: $group}';
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

  Setting({
    this.id = 0,
    this.star1 = 120,
    this.star2 = 240,
    this.star3 = 480,
    this.hourOfRest = 4,
    this.timeOfRest = '',
    this.doneMinutes = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'star1': star1,
      'star2': star2,
      'star3': star3,
      'done_minutes': doneMinutes,
      'hour_of_rest': hourOfRest,
      'time_of_rest': timeOfRest,
    };
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
    return {
      'mostProductiveDate': mostProductiveDate,
      'mostProductiveDay': mostProductiveDay,
      'averageDailyProductivity': averageDailyProductivity,
    };
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
  GroupedSessions({
    required this.date,
    required this.dayName,
    required this.sessions,
    required this.totalMinutes,
  });

  Map<String, dynamic> toMap() {
    return {'date': date, 'day_name': dayName, 'sessions': sessions};
  }

  @override
  String toString() {
    return 'GroupedSessions{date: $date, dayName: $dayName, sessions: \n[$sessions]\n}';
  }
}
