import 'package:flutter/material.dart';
import 'package:salad_of_achievement/logical/models/data_model.dart';
import 'package:salad_of_achievement/main.dart';

class DataProvider with ChangeNotifier {
  // اضافت البيانات الى البرنامج
  SettingData settings = objectBox.getSetting()!;
  List<History> storedHistory = objectBox.getHistories();
  late int _star1;
  late int _star2;
  late int _star3;
  int _doneMinutes = 0;
  final List<Activity> _activity = [];
  final List<History> _history = [];

  int get star1 => _star1;
  int get star2 => _star2;
  int get star3 => _star3;
  int get doneMinutes => _doneMinutes;
  List<Activity> get activity => _activity;
  List<History> get history => _history;

  DataProvider() {
    _star1 = settings.star1;
    _star2 = settings.star2;
    _star3 = settings.star3;
    _activity.addAll(objectBox.getActivities());
    getHistories();
  }

  void setStar1(int value) {
    _star1 = value;
    objectBox.updateSetting(objectBox.getSetting()!..star1 = value);
    notifyListeners();
  }

  void setStar2(int value) {
    _star2 = value;
    objectBox.updateSetting(objectBox.getSetting()!..star2 = value);
    notifyListeners();
  }

  void setStar3(int value) {
    _star3 = value;
    objectBox.updateSetting(objectBox.getSetting()!..star3 = value);
    notifyListeners();
  }

  void setDoneMinutes(int value, String? activityName) {
    //خلها مع التاريخ
    _doneMinutes += value;

    objectBox.addHistory(History.todayFormate(), value, activityName);
    _activity.clear();
    _activity.addAll(objectBox.getActivities());
    getHistories();
    notifyListeners();
  }

  void addActivity(String activityName, int duration) {
    objectBox.addActivity(activityName, duration);
    _activity.add(objectBox.getActivity(activityName)!);
    notifyListeners();
  }

  // void editActivity(String activityName, int duration, {String name = "", int newDuration = 0}) {
  //   //مررت المعلومات الجديدة و القديمة
  // objectBox.editActivity(Activity(name: activityName, duration: duration), name: name, duration: newDuration);
  //   //حذفت القديمة
  //   _Activity.remove(activityName);
  //   //أضفت الجديدة
  //   _Activity.addAll({name: newDuration});
  //   notifyListeners();
  // }

  // void addListActivity(List<Activity> activityList) {
  //   for (Activity activity in activityList) {
  //     _activity.addAll({activity.name!: activity.totalTime!});
  //   }
  // }

  void getHistories() {
    _history.removeRange(0, _history.length);
    _history.addAll(objectBox.getHistories());
    if (_history.isNotEmpty && _history.last.date == History.todayFormate()) {
      _doneMinutes = _history.last.todayTime!;
    }
  }
}
