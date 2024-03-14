import 'package:hijri/hijri_calendar.dart';
import 'package:objectbox/objectbox.dart';

@Entity() //لازمة لتحويله إلى قاعدة البيانات
class SettingData {
  //أنا احط المعرف بنفسي
  @Id(assignable: true)
  int id;
  int star1;
  int star2;
  int star3;

  SettingData(
      {required this.star1,
      required this.star2,
      required this.star3,
      this.id = 1});

  @override
  String toString() {
    return 'SettingData{id: $id, star1: $star1, star2: $star2, star3: $star3}\n';
  }
}

@Entity()
class Activity {
  @Id()
  int id;
  String? name;
  //الوقت الكلي للنشاط
  int? totalTime = 0;

  Activity(this.name, this.totalTime, {this.id = 0});

  @override
  String toString({bool withId = false}) {
    if (withId) {
      return 'id: $id, name: $name, totalTime: $totalTime';
    } else {
      return 'name: $name, totalTime: $totalTime';
    }
  }
}

@Entity()
class History {
  @Id()
  int id = 0;
  @Unique() //لكي لا يتكرر التاريخ
  String? date;
  int? todayTime = 0;
  // I was trying to use a custom type but it seems that object box only works with basic types
  // try to find a solution for this
  // I stopped here
  List<Session> todaySessions = [];

  History(this.date, this.todayTime, {this.id = 0});

  @override
  String toString({bool withId = false}) {
    if (withId) {
      return 'id: $id, date: $date, todayTime: $todayTime , todaySessions: $todaySessions';
    } else {
      return 'date: $date, todayTime: $todayTime , todaySessions: $todaySessions';
    }
  }

  static String todayFormate({String language = "ar"}) {
    String date = "";

    HijriCalendar.language = language;
    date =
        "${HijriCalendar.now().dayWeName} , ${HijriCalendar.now().toFormat("dd MM yyyy")}";

    return date;
  }
}

class Session {
  String? name;
  int? totalTime = 0;

  Session(this.name, this.totalTime);

  @override
  String toString({bool withId = false}) =>
      'name: $name, totalTime: $totalTime';
}
