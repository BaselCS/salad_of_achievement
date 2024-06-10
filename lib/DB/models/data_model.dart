import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Session {
  @Id()
  int id;
  DateTime date;
  int timeSpent;
  String topic;

  Session({
    this.id = 0, // ObjectBox IDs start at 0
    required this.date,
    required this.timeSpent,
    required this.topic,
  });

// Convert a Session into a Map. The keys must correspond to the names of the columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': '${DateUtils.dateOnly(date)}', // Format: YYYY-MM-DD
      'time_spent': timeSpent,
      'topic': topic,
    };
  }

  String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

// Implement toString to make it easier to see information about each session when using the print statement.
  @override
  String toString() {
    String formattedDate = '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';
    return 'Session{id: $id, date: $formattedDate, timeSpent: $timeSpent, topic: $topic}\n';
  }
}

@Entity()
class Activity {
  @Id()
  int id;
  String name;
  int timeSpent;

  Activity({
    this.id = 0, // ObjectBox IDs start at 0
    required this.name,
    required this.timeSpent,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'time_spent': timeSpent,
    };
  }

  @override
  String toString() {
    return 'Activity{id: $id, name: $name, timeSpent: $timeSpent}';
  }
}

@Entity()
class FruitUsage {
  @Id()
  int id;
  String fruitName;
  int timeSpent;
  int usageCount;

  FruitUsage({
    this.id = 0, // ObjectBox IDs start at 0
    required this.fruitName,
    required this.timeSpent,
    required this.usageCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fruit_name': fruitName,
      'time_spent': timeSpent,
      'usage_count': usageCount,
    };
  }

  @override
  String toString() {
    return 'FruitUsage{id: $id, fruitName: $fruitName, timeSpent: $timeSpent, usageCount: $usageCount}';
  }
}

class UserStatistics {
  static DateTime? mostProductiveDate;
  static int mostProductiveDay = 0;
  static double averageDailyProductivity = 0;

  // Convert a UserStatistics instance into a Map for ObjectBox.
  Map<String, dynamic> toMap() {
    return {
      'mostProductiveDate': DateUtils.dateOnly(mostProductiveDate ?? DateTime.now()),
      'mostProductiveDay': mostProductiveDay,
      'averageDailyProductivity': averageDailyProductivity,
    };
  }

  @override
  String toString() {
    return 'UserStatistics{mostProductiveDate:$mostProductiveDate ,mostProductiveDay: $mostProductiveDay, averageDailyProductivity: $averageDailyProductivity}';
  }
}
