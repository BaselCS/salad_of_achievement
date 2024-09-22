import 'dart:developer';
import 'dart:math' show min;
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:salad_of_achievement/logical/hijri_logic.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../objectbox.g.dart';
import 'data_model.dart';

class ObjectBoxState with ChangeNotifier {
  late final Store _store;
  late final Box<Session> _sessionBox;
  late final Box<Activity> _activityBox;
  late final Box<FruitUsage> _fruitUsageBox;
  late final Box<Setting> _settingBox;

  late int star1;
  late int star2;
  late int star3;
  late DateTime timeToRest;
  late int totalDoneMinutes;
  late bool autoStart = true;

  ObjectBoxState._create(this._store) {
    _initializeBoxes(); //تهيئة البيانات
    _initializeSettings(); // تهيئة الإعدادات
    log("timeToRest: $timeToRest");
    _initializeResetTimer(); // تهيئة مؤقت إعادة التعيين
  }

  static Future<ObjectBoxState> create() async {
    final store = await openStore();
    return ObjectBoxState._create(store);
  }

  /// [الإعدادات الافتراضية]
  /// تهيئة الصناديق
  void _initializeBoxes() {
    _sessionBox = Box<Session>(_store);
    _activityBox = Box<Activity>(_store);
    _fruitUsageBox = Box<FruitUsage>(_store);
    _settingBox = Box<Setting>(_store);
    // // Log the number of settings in the box
    // final settingsCount = _settingBox.count();
    // log("Settings count: $settingsCount");
  }

  /// تهيئة الإعدادات
  void _initializeSettings() {
    final setting = _settingBox.get(1);
    if (setting == null) {
      setDefaultSettings();
    } else {
      log("Found existing settings: $setting");
      star1 = setting.star1;
      star2 = setting.star2;
      star3 = setting.star3;

      // Set timeToRest and totalDoneMinutes from the existing settings
      timeToRest = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, setting.hourOfRest);
      totalDoneMinutes = setting.doneMinutes;
    }
  }

  /// تعيين الإعدادات الافتراضية
  void setDefaultSettings() {
    star1 = 120;
    star2 = 240;
    star3 = 480;
    autoStart = true;
    timeToRest = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 4);
    totalDoneMinutes = 0;
  }

  /// تهيئة مؤقت إعادة التعيين
  void _initializeResetTimer() {
    tz.initializeTimeZones();
    final location = tz.getLocation('Asia/Riyadh');
    final now = tz.TZDateTime.now(location);
    var nextReset = tz.TZDateTime(location, timeToRest.year, timeToRest.month, timeToRest.day, timeToRest.hour);

    if (now.isAfter(nextReset)) {
      nextReset = nextReset.add(const Duration(days: 1));
      resetTotalDoneMinutes(nextReset);
    }
  }

  /// إعادة تعيين الدقائق المكتملة
  void resetTotalDoneMinutes(var nextReset) {
    totalDoneMinutes = 0;
    final currentSetting = _settingBox.get(1) ?? Setting();
    currentSetting.doneMinutes = totalDoneMinutes;
    currentSetting.timeOfRest = nextReset.toString();
    _settingBox.put(currentSetting);
    notifyListeners();
    // MyLogger.log("يوم جديد");
  }

  /// [الجلسات]
  List<Session> getAllSessions() {
    List<Session> list = _sessionBox.getAll();
    // MyLogger.log("جلبت جميع الجلسات");
    return list;
  }

  void addSession(Session session) {
    session.date = getDate();
    _sessionBox.put(session);
    totalDoneMinutes += session.timeSpent;
    addFruitUsage(time: session.timeSpent);
    updateSettingTotalDoneMinutes();
    // MyLogger.log("إضيفت جلسة جديدة : ${session.id}");
    notifyListeners();
  }

  void updateSession(Session session) {
    _sessionBox.put(session);
    // MyLogger.log("حدثت الجلسة: ${session.id}");
    notifyListeners();
  }

  void deleteSession(int id) {
    Session? session = _sessionBox.get(id);
    if (session == null) {
      // MyLogger.log("الجلسة غير موجودة");
      return;
    }
    _sessionBox.remove(session.id);
    if (session.date == HijriCalendar.now().toString()) {
      totalDoneMinutes -= session.timeSpent;
      totalDoneMinutes = totalDoneMinutes < 0 ? 0 : totalDoneMinutes;
    }
    deleteFruitUsage(session.timeSpent);
    updateSettingTotalDoneMinutes();
    // MyLogger.log("حذفت الجلسة: ${session.id}");
    notifyListeners();
  }

  void deleteAllSessions() {
    _sessionBox.removeAll();
    totalDoneMinutes = 0;
    updateSettingTotalDoneMinutes();
    // MyLogger.log("حذفت جميع الجلسات");
    notifyListeners();
  }

  /// تجميع الجلسات حسب اليوم
  List<GroupedSessions> groupSessionsByDay(List<Session> sessions) {
    final Map<String, List<Session>> sessionsByDay = groupBy(sessions, (session) => session.date);

    List<GroupedSessions> groupedSessions = [];

    sessionsByDay.forEach((date, sessions) {
      double timeSpent = sessions.fold(0, (previousValue, element) => previousValue + element.timeSpent);
      String dayName = HijriLogic.hijriDateToDayName(date);

      groupedSessions.add(GroupedSessions(date: date, dayName: dayName, sessions: sessions, totalMinutes: timeSpent.toInt()));
    });
    // MyLogger.log("الجلسات جمعت");
    return groupedSessions;
  }

  List<GroupedSessions> getLastWeek() {
    List<Session> sessions = getAllSessions();
    List<GroupedSessions> sessionsByDay = groupSessionsByDay(sessions);
    List<GroupedSessions> lastWeek = [];
    if (sessionsByDay.isEmpty) {
      // MyLogger.log("لا توجد جلسات");
      return [];
    }
    for (int i = 1; i <= min(sessionsByDay.length, 9); i++) {
      lastWeek.add(sessionsByDay[sessionsByDay.length - i]);
    }

    // MyLogger.log("معلومات الأسبوع المنصرم جاهزة");
    return lastWeek;
  }

  /// [إعدادات المستخدم]
  void getUserStatistics() {
    List<Session> sessions = getAllSessions();
    List<GroupedSessions> sessionsByDay = groupSessionsByDay(sessions);
    int maxTimeSpent = 0;
    double totalTime = 0;
    String mostActiveDay = "";
    if (sessionsByDay.isEmpty) {
      UserStatistics.averageDailyProductivity = 0;
      UserStatistics.mostProductiveDate = "احرص على ما ينفعُك، واستعنْ بالله، ولا تعجز";
      UserStatistics.mostProductiveDay = 0;
      // MyLogger.log("إحصائات المستخدم قارغة");
      return;
    }

    for (GroupedSessions entry in sessionsByDay) {
      double timeSpent = entry.totalMinutes.toDouble();
      totalTime += timeSpent;
      if (timeSpent > maxTimeSpent) {
        maxTimeSpent = timeSpent.toInt();
        mostActiveDay = "${entry.dayName}  ${entry.date}هـ";
      }
    }

    UserStatistics.averageDailyProductivity = totalTime / sessionsByDay.length;
    UserStatistics.mostProductiveDate = mostActiveDay;
    UserStatistics.mostProductiveDay = maxTimeSpent;
    // MyLogger.log("إحصائات المستخدم قارغة");
  }

  void updateSettingTotalDoneMinutes() {
    final currentSetting = _settingBox.get(1) ?? Setting();
    currentSetting.doneMinutes = totalDoneMinutes;
    _settingBox.put(currentSetting);
  }

  void updateStares({int newStar1 = 0, int newStar2 = 0, int newStar3 = 0}) {
    if (newStar1 != 0) {
      star1 = newStar1;
    }
    if (newStar2 != 0) {
      star2 = newStar2;
    }
    if (newStar3 != 0) {
      star3 = newStar3;
    }
    final Setting currentSetting = _settingBox.get(1) ?? Setting();
    currentSetting.star1 = star1;
    currentSetting.star2 = star2;
    currentSetting.star3 = star3;
    _settingBox.put(currentSetting);
    // MyLogger.log("حدثت قيمة النجوم");
    notifyListeners();
  }

  void setStartOfDay(int value) {
    timeToRest = DateTime(timeToRest.year, timeToRest.month, timeToRest.day, value);
    final currentSetting = _settingBox.get(1) ?? Setting();
    currentSetting.hourOfRest = value;
    _settingBox.put(currentSetting);
    print(_settingBox.getAll());
    // MyLogger.log("Start of day set to: $value");
    notifyListeners();
  }

  /// [الفواكهة]
  List<FruitUsage> getAllFruitUsage() {
    // MyLogger.log("جلبت جميع الفواكهة المستخدمة");
    List<FruitUsage> list = _fruitUsageBox.getAll();
    List<int> id = [5, 10, 15, 20, 25, 30, 40, 50, 60];
    if (list.length != 9) {
      for (int i in id) {
        if (list.where((element) => element.id == i).isEmpty) {
          _fruitUsageBox.put(FruitUsage(id: i, usageCount: 0));
        }
      }
    }
    return list;
  }

  void addFruitUsage({int time = 5}) {
    final FruitUsage fruitUsage = _fruitUsageBox.get(time) ?? FruitUsage(id: time, usageCount: 1);
    fruitUsage.usageCount++;
    _fruitUsageBox.put(fruitUsage);
    // MyLogger.log("إضيفت فاكهة جديدة لسلطتك: ${fruitUsage.id}");
    notifyListeners();
  }

  void deleteFruitUsage(int time) {
    final fruitUsage = _fruitUsageBox.get(time);
    if (fruitUsage == null) {
      return;
    }
    fruitUsage.usageCount--;
    if (fruitUsage.usageCount == 0) {
      _fruitUsageBox.remove(fruitUsage.id);
    } else {
      _fruitUsageBox.put(fruitUsage); //كتحديث
    }
    // MyLogger.log("حذفت فاكهة من سلطتك: ${fruitUsage.id}");
    notifyListeners();
  }

  int averageForWeek(List<GroupedSessions> week) {
    int sum = 0;
    for (int i = 0; i < week.length; i++) {
      sum += week[i].totalMinutes;
    }
    return sum ~/ 7;
  }

  /// [الأنشطة]
  List<Activity> getAllActivities() {
    // MyLogger.log("جلبت جميع الأنشطة");
    return _activityBox.getAll();
  }

  void addActivity(Activity activity) {
    _activityBox.put(activity);
    // MyLogger.log("إضيف نشاط جديد: ${activity.name}");
    notifyListeners();
  }

  void updateActivity(Activity activity, String? name, int? timeSpent) {
    activity.name = name ?? activity.name;
    activity.timeSpent = timeSpent ?? activity.timeSpent;
    _activityBox.put(activity);
    // MyLogger.log("حدث النشاط: ${activity.id}");
    notifyListeners();
  }

  void deleteActivity(Activity activity) {
    _activityBox.remove(activity.id);
    deleteFruitUsage(activity.timeSpent);
    // MyLogger.log("حذف نشاط: ${activity.id}");
    notifyListeners();
  }

  /// [حذف البيانات]
  void deleteAll() {
    _sessionBox.removeAll();
    _activityBox.removeAll();
    _fruitUsageBox.removeAll();
    _settingBox.removeAll();
    UserStatistics.averageDailyProductivity = 0;
    UserStatistics.mostProductiveDate = HijriCalendar.now().toString();
    UserStatistics.mostProductiveDay = 0;

    // MyLogger.log("All data deleted");
    notifyListeners();
  }

  String getDate() {
    final int time = DateTime.now().hour;
    DateTime date = DateTime.now();
    if (time < timeToRest.hour) {
      date = date.subtract(const Duration(days: 1));
    }
    return HijriCalendar.fromDate(date).toString();
  }

  HijriCalendar getDateName() {
    final int time = DateTime.now().hour;
    DateTime date = DateTime.now();
    if (time < timeToRest.hour) {
      date = date.subtract(const Duration(days: 1));
    }
    return HijriCalendar.fromDate(date);
  }

  int _doneMinutesOfSession = 0;
  int get getDoneMinutesOfSession => _doneMinutesOfSession;

  set setDoneMinutesOfSession(int value) {
    _doneMinutesOfSession = value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // يتم تنفيذ الكود بعد تحديث الشاشة
      notifyListeners();
    });
  }
}
