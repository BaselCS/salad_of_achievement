import '../../objectbox.g.dart';
import 'data_model.dart';

class ObjectBox {
  //عبارة عن متغير يحتوي على قاعدة البيانات لو أردت اكثر من قاعدة بيانات أنشائه أكثر من مره
  late final Store store;
  late final Box<SettingData> _settingBox;
  late final Box<Activity> _activityBox;
  late final Box<History> _historyBox;

  ///إنشاء الدالة الخاصة بالتعامل مع قاعدة البيانات (منشئ)
  ObjectBox._create(this.store) {
    _settingBox = store.box<SettingData>();
    _activityBox = store.box<Activity>();
    _historyBox = store.box<History>();

    // افراغ البيانات
    // _settingBox.removeAll();
    // _activityBox.removeAll();
    // _historyBox.removeAll();

    //إذا كانت القاعدة فارغة
    if (_settingBox.isEmpty()) {
      _settingBox.put(SettingData(star1: 120, star2: 240, star3: 380));
    }
  }

  /// إنشاء قاعدة بيانات عامة  (تغليف)
  static Future<ObjectBox> create() async {
    // final Directory docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore();
    // final Store store = await openStore(directory: "${docsDir.path}objectbox");
    // store.close();
    return ObjectBox._create(store);
  }

  /// يجلب البيانات لمرة واحدة فقط إذا كانت موجودة
  SettingData? getSetting() {
    return _settingBox.get(1);
  }

  void updateSetting(SettingData data) {
    data.id = 1;
    _settingBox.put(data);
  }

  /// إذا كان صحيح يعني تم الحذف وإذا كان خطأ يعني لم يتم الحذف
  bool deleteSetting(int id) => _settingBox.remove(id);

  /// إضافة نشاط جديد
  ///إذا كان صفر يعني إضافة وإذا كان غير صفر يعني تعديل
  int addActivity(String name, int duration) {
    Activity? activity =
        _activityBox.query(Activity_.name.equals(name)).build().findFirst();

    //إذا كان موجود
    if (activity != null) {
      activity.totalTime = activity.totalTime! + duration;
      return _activityBox.put(activity);
    }
    //إذا كان غير موجود (جديد)
    activity = Activity(name, duration);
    return _activityBox.put(activity);
  }

  // int editActivity(Activity activity, {String name = "", int duration = 0}) {
  //   //نسخة المعلومات
  //   Activity newActivity = getActivate(activity.name!);
  //   //حدثت الجديد
  //   if (name.isNotEmpty) {
  //     newActivity.name = name;
  //   }
  //   if (duration != 0) {
  //     newActivity.duration = duration;
  //   }
  //   //حفظته
  //   return _activityBox.put(newActivity);
  // }

  /// جلب النشاطات
  List<Activity> getActivities() => _activityBox.getAll();

  /// جلب نشاط من اسمه
  Activity? getActivity(String name) {
    return _activityBox.query(Activity_.name.equals(name)).build().findFirst();
  }

  /// حذف نشاط
  bool deleteActivity(Activity activity) {
    List<Activity> listActivity = _activityBox
        .query(Activity_.name.equals(activity.name!))
        .build()
        .find();
    //إذا كان موجود
    if (listActivity.isNotEmpty) {
      listActivity.first.totalTime =
          listActivity.first.totalTime! - activity.totalTime!;
      return _activityBox.remove(activity.id);
    }
    return false;
  }
  // int deleteActivity() => _activityBox.removeAll();

  /// إضافة تاريخ
  int addHistory(String date, int doneTime, String? activityName) {
    // اضافت التاريخ
    History? object = _historyBox
        .query(History_.date.equals(date))
        .build()
        .find()
        .firstOrNull;
    if (object == null) {
      //يوم جديد
      object = History(date, doneTime);
    } else {
      //تعديل الوقت
      object.todayTime = object.todayTime! + doneTime;
    }

    //إضافة النشاط
    if (activityName != null) {
      Activity? activity = _activityBox
          .query(Activity_.name.equals(activityName))
          .build()
          .findFirst();

      //إذا كان موجود
      if (activity != null) {
        activity.totalTime = activity.totalTime! + doneTime;
      } else {
        //إذا كان غير موجود (جديد)
        activity = Activity(activityName, doneTime);
      }
      _activityBox.put(activity);
    }

    // object.todaySessions.add(Session(activityName, doneTime));
    return _historyBox.put(object);
  }

  /// جلب التاريخ
  List<History> getHistories() => _historyBox.getAll();

  // bool deleteActivityFromHistory(String date, Activity activity) {
  //   History? object = _historyBox
  //       .query(History_.date.equals(date))
  //       .build()
  //       .find()
  //       .firstOrNull;
  //   //احتياط
  //   if (object == null) return false;

  //   deleteActivity(activity);

  //   object.todaySessions.remove(activity);
  //   object.todayTime = object.todayTime! - activity.totalTime!;

  //   return false;
  // }

  int deleteHistory() => _historyBox.removeAll();

  /// إغلاق قاعدة البيانات
  void close() {
    store.close();
  }
}
