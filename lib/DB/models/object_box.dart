import 'dart:math' show min;
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:salad_of_achievement/logical/hijri_logic.dart';
import 'package:salad_of_achievement/logical/app_logger.dart';

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
  late int doneMinutes = 0;
  late bool autoStart = true;

  ObjectBoxState._create(this._store) {
    _initializeBoxes(); //تهيئة البيانات
    _initializeSettings(); // تهيئة الإعدادات
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
  }

  /// تهيئة الإعدادات
  void _initializeSettings() {
    final setting = _settingBox.getAll().firstOrNull;
    if (setting == null) {
      setDefaultSettings();
    } else {
      star1 = setting.star1;
      star2 = setting.star2;
      star3 = setting.star3;
      timeToRest = DateTime.tryParse(setting.timeOfRest) ?? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, setting.hourOfRest);
      doneMinutes = setting.doneMinutes;
    }
  }

  /// تعيين الإعدادات الافتراضية
  void setDefaultSettings() {
    star1 = 120;
    star2 = 240;
    star3 = 480;
    autoStart = true;
    timeToRest = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 4);
    doneMinutes = 0;

    final defaultSetting = Setting(
      star1: star1,
      star2: star2,
      star3: star3,
      hourOfRest: timeToRest.hour,
      timeOfRest: timeToRest.toString(),
      doneMinutes: doneMinutes,
    );
    _settingBox.put(defaultSetting);
  }

  /// تهيئة مؤقت إعادة التعيين
  void _initializeResetTimer() {
    isNewDay();
  }

  /// التحقق من بداية يوم جديد
  void isNewDay() {
    final setting = _settingBox.getAll().firstOrNull;
    if (setting == null) {
      notifyListeners();
      return;
    }

    final now = DateTime.now();
    final nextReset = _resolveNextReset(now, setting);

    // Keep in-memory state synchronized with persisted settings.
    timeToRest = nextReset;
    if (doneMinutes != setting.doneMinutes) {
      doneMinutes = setting.doneMinutes;
    }

    // Persist a normalized reset timestamp if needed.
    if (setting.timeOfRest != nextReset.toString()) {
      setting.timeOfRest = nextReset.toString();
      _settingBox.put(setting);
    }

    if (now.isAfter(nextReset)) {
      _resetDoneMinutes(nextReset.add(const Duration(days: 1)));
      return;
    }

    notifyListeners();
  }

  DateTime _resolveNextReset(DateTime now, Setting setting) {
    final parsed = DateTime.tryParse(setting.timeOfRest);
    final fallback = DateTime(now.year, now.month, now.day, setting.hourOfRest);
    final base = parsed ?? fallback;
    return DateTime(base.year, base.month, base.day, setting.hourOfRest);
  }

  /// إعادة تعيين الدقائق المكتملة
  void _resetDoneMinutes(DateTime nextReset) {
    doneMinutes = 0;
    timeToRest = nextReset;
    final currentSetting = _settingBox.getAll().firstOrNull ?? Setting();
    currentSetting.doneMinutes = doneMinutes;
    currentSetting.timeOfRest = nextReset.toString();
    _settingBox.put(currentSetting);
    notifyListeners();
    AppLogger.log("يوم جديد", tag: 'objectbox');
  }

  /// [الجلسات]
  List<Session> getAllSessions() {
    List<Session> list = _sessionBox.getAll();
    AppLogger.log("جلبت جميع الجلسات", tag: 'objectbox');
    return list;
  }

  void addSession(Session session) {
    // Ensure the day rollover is applied before counting the new session.
    isNewDay();
    _sessionBox.put(session);
    doneMinutes += session.timeSpent;
    addFruitUsage(time: session.timeSpent);
    _updateSettingDoneMinutes();
    AppLogger.log("إضيفت جلسة جديدة : ${session.id}", tag: 'objectbox');
    notifyListeners();
  }

  void updateSession(Session session, int oldSessionID) {
    doneMinutes += session.timeSpent;
    deleteSession(oldSessionID);
    _sessionBox.put(session);
    AppLogger.log("حدثت الجلسة: ${session.id}", tag: 'objectbox');
    notifyListeners();
  }

  void deleteSession(int id) {
    Session? session = _sessionBox.get(id);
    if (session == null) {
      AppLogger.log("الجلسة غير موجودة", tag: 'objectbox');
      return;
    }
    _sessionBox.remove(session.id);
    if (HijriLogic.englishToArabicNumber(session.date) == HijriCalendar.now().toString()) {
      doneMinutes -= session.timeSpent;
      doneMinutes = doneMinutes < 0 ? 0 : doneMinutes;
    }
    _updateSettingDoneMinutes();
    AppLogger.log("حذفت الجلسة: ${session.id}", tag: 'objectbox');
    notifyListeners();
  }

  void deleteAllSessions() {
    _sessionBox.removeAll();
    doneMinutes = 0;
    _updateSettingDoneMinutes();
    AppLogger.log("حذفت جميع الجلسات", tag: 'objectbox');
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
    AppLogger.log("الجلسات جمعت", tag: 'objectbox');
    return groupedSessions;
  }

  List<GroupedSessions> getLastWeek() {
    List<Session> sessions = getAllSessions();
    List<GroupedSessions> sessionsByDay = groupSessionsByDay(sessions);
    List<GroupedSessions> lastWeek = [];
    if (sessionsByDay.isEmpty) {
      AppLogger.log("لا توجد جلسات", tag: 'objectbox');
      return [];
    }
    for (int i = 1; i <= min(sessionsByDay.length, 9); i++) {
      lastWeek.add(sessionsByDay[sessionsByDay.length - i]);
    }

    AppLogger.log("معلومات الأسبوع المنصرم جاهزة", tag: 'objectbox');
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
      AppLogger.log("إحصائات المستخدم قارغة", tag: 'objectbox');
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
    AppLogger.log("إحصائات المستخدم قارغة", tag: 'objectbox');
  }

  void _updateSettingDoneMinutes() {
    final currentSetting = _settingBox.getAll().firstOrNull ?? Setting();
    currentSetting.doneMinutes = doneMinutes;
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
    final currentSetting = _settingBox.getAll().firstOrNull ?? Setting();
    currentSetting.star1 = star1;
    currentSetting.star2 = star2;
    currentSetting.star3 = star3;
    _settingBox.put(currentSetting);
    AppLogger.log("حدثت قيمة النجوم", tag: 'objectbox');
    notifyListeners();
  }

  void updateTimeToRest(int hour) {
    final currentSetting = _settingBox.getAll().firstOrNull ?? Setting();
    currentSetting.hourOfRest = hour;
    timeToRest = DateTime(timeToRest.year, timeToRest.month, timeToRest.day, hour);
    currentSetting.timeOfRest = timeToRest.toString();
    _settingBox.put(currentSetting);
    AppLogger.log("Start of day set to: $hour", tag: 'objectbox');
    notifyListeners();
  }

  /// [الفواكهة]
  List<FruitUsage> getAllFruitUsage() {
    AppLogger.log("جلبت جميع الفواكهة المستخدمة", tag: 'objectbox');
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
    AppLogger.log("إضيفت قاكهة جديدة لسلطتك: ${fruitUsage.id}", tag: 'objectbox');
    notifyListeners();
  }

  void deleteFruitUsage(int time) {
    final fruitUsage = _fruitUsageBox.get(time);
    if (fruitUsage == null) {
      return;
    }
    if (fruitUsage.usageCount != 0) {
      fruitUsage.usageCount--;

      _fruitUsageBox.put(fruitUsage);
    }
    AppLogger.log("حذفت فاكهة من سلطتك: ${fruitUsage.id}", tag: 'objectbox');
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
  List<Activity> getActiveActivities() {
    AppLogger.log("جلبت جميع الأنشطة النشطة", tag: 'objectbox');
    return _activityBox.getAll().whereNot((activity) => activity.isArchived).toList();
  }

  List<Activity> getAllActivities() {
    AppLogger.log("جلبت جميع الأنشطة", tag: 'objectbox');
    return _activityBox.getAll();
  }

  void addActivity(Activity activity) {
    _activityBox.put(activity);
    AppLogger.log("إضيف نشاط جديد: ${activity.name}", tag: 'objectbox');
    notifyListeners();
  }

  void archiveActivity(Activity activity) {
    activity.isArchived = true;
    _activityBox.put(activity);
    AppLogger.log("أرشف النشاط: ${activity.name}", tag: 'objectbox');

    notifyListeners();
  }

  void unarchiveActivity(Activity activity) {
    activity.isArchived = false;
    _activityBox.put(activity);
    AppLogger.log("ألغيت أرشفة النشاط: ${activity.name}", tag: 'objectbox');
    notifyListeners();
  }

  void updateActivity(Activity activity, String? name, int? timeSpent) {
    activity.name = name ?? activity.name;
    activity.timeSpent = timeSpent ?? activity.timeSpent;
    _activityBox.put(activity);
    AppLogger.log("حدث النشاط: ${activity.id}", tag: 'objectbox');
    notifyListeners();
  }

  void deleteActivity(Activity activity) {
    _activityBox.remove(activity.id);
    AppLogger.log("حذف نشاط: ${activity.id}", tag: 'objectbox');
    notifyListeners();
  }

  /// [حذف البيانات]
  void deleteAll() {
    doneMinutes = 0;

    _sessionBox.removeAll();
    _activityBox.removeAll();
    _fruitUsageBox.removeAll();
    UserStatistics.averageDailyProductivity = 0;
    UserStatistics.mostProductiveDate = HijriCalendar.now().toString();
    UserStatistics.mostProductiveDay = 0;

    AppLogger.log("All data deleted", tag: 'objectbox');
    notifyListeners();
  }
}
