import 'package:hijri/hijri_calendar.dart';

class HijriLogic {
  static String hijriDateToDayName(String date) {
    //تقسيم التاريخ
    List<String> dayData = date.split("/");

    //تحويل التاريخ الهجري الى ميلادي
    int year = int.parse(arabicToEnglishNumber(dayData[0]));
    int month = int.parse(arabicToEnglishNumber(dayData[1]));
    int day = int.parse(arabicToEnglishNumber(dayData[2]));
    DateTime data = HijriCalendar().hijriToGregorian(year, month, day);

    //استرجاع اسم اليوم
    String dayName = HijriCalendar.fromDate(data).dayWeName;
    return dayName;
  }

  static String arabicToEnglishNumber(String input) {
    final Map<String, String> arabicIndicToStandard = {'٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4', '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9'};
    return input.split('').map((char) => arabicIndicToStandard[char] ?? char).join();
  }
}
