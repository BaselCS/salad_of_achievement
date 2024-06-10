import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../../objectbox.g.dart';
import 'data_model.dart';

class ObjectBoxState with ChangeNotifier {
  late final Store _store;
  late final Box<Session> _sessionBox;
  late final Box<Activity> _activityBox;
  late final Box<FruitUsage> _fruitUsageBox;

  ObjectBoxState._create(this._store) {
    _sessionBox = Box<Session>(_store);
    _activityBox = Box<Activity>(_store);
    _fruitUsageBox = Box<FruitUsage>(_store);
  }

  static Future<ObjectBoxState> create() async {
    final store = await openStore();
    return ObjectBoxState._create(store);
  }

  List<Session> getAllSessions() {
    List<Session> list = _sessionBox.getAll();
    updateUserStatistics(list);
    return _sessionBox.getAll();
  }

  void addSession(Session session) {
    _sessionBox.put(session);
    notifyListeners();
  }

  Map<String, List<Session>> groupSessionsByDay(List<Session> sessions) {
    final sessionsByDay = groupBy(sessions, (session) {
      return session.date.toIso8601String().split('T')[0];
    });

    return sessionsByDay;
  }

  void updateUserStatistics(List<Session> sessions) {
    Map<String, List<Session>> sessionsByDay = groupSessionsByDay(sessions);
    // print(sessionsByDay);
    int maxTimeSpent = 0;
    double totalTime = 0;
    DateTime mostActiveDay = DateTime.now();
    for (var entry in sessionsByDay.entries) {
      var element = entry.value;
      double timeSpent = element.fold(0, (previousValue, element) => previousValue + element.timeSpent);
      totalTime += timeSpent;
      if (timeSpent > maxTimeSpent) {
        maxTimeSpent = timeSpent.toInt();
        mostActiveDay = element[0].date;
      }
    }

    UserStatistics.averageDailyProductivity = totalTime / sessionsByDay.length;
    UserStatistics.mostProductiveDate = mostActiveDay;
    UserStatistics.mostProductiveDay = maxTimeSpent;
  }

  List<Activity> getAllActivities() => _activityBox.getAll();

  void addActivity(Activity activity) {
    _activityBox.put(activity);
    notifyListeners();
  }

  List<FruitUsage> getAllFruitUsage() => _fruitUsageBox.getAll();

  void addFruitUsage(FruitUsage newFruitUsage) {
    final query = _fruitUsageBox.query(FruitUsage_.fruitName.equals(newFruitUsage.fruitName)).build();
    final existingFruitUsage = query.findFirst();
    query.close();

    if (existingFruitUsage != null) {
      existingFruitUsage.timeSpent += newFruitUsage.timeSpent;
      existingFruitUsage.usageCount += newFruitUsage.usageCount;
      _fruitUsageBox.put(existingFruitUsage);
    } else {
      _fruitUsageBox.put(newFruitUsage);
    }

    notifyListeners();
  }

  void deleteAll() {
    _sessionBox.removeAll();
    _activityBox.removeAll();
    _fruitUsageBox.removeAll();
    UserStatistics.averageDailyProductivity = 0;
    UserStatistics.mostProductiveDate = DateTime.now();
    UserStatistics.mostProductiveDay = 0;
    notifyListeners();
  }

  void deleteSession(Session session) {
    _sessionBox.remove(session.id);
    notifyListeners();
  }

  void deleteActivity(Activity activity) {
    _activityBox.remove(activity.id);
    notifyListeners();
  }

  void deleteFruitUsage(FruitUsage fruitUsage) {
    _fruitUsageBox.remove(fruitUsage.id);
    notifyListeners();
  }

  void updateSession(Session session) {
    _sessionBox.put(session);
    notifyListeners();
  }

  void updateActivity(Activity activity) {
    _activityBox.put(activity);
    notifyListeners();
  }

  void updateFruitUsage(FruitUsage fruitUsage) {
    _fruitUsageBox.put(fruitUsage);
    notifyListeners();
  }

  @override
  void dispose() {
    _store.close();
    super.dispose();
  }

  @override
  String toString() {
    return '_sessionBox: ${getAllSessions()},\n _activityBox: ${getAllActivities()} ,\n _fruitUsageBox: ${getAllFruitUsage()}';
  }
}
