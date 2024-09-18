import 'dart:io';

import 'package:path_provider/path_provider.dart';

class MyLogger {
  static String _fileName = "debug";
  static Future<String> get _localPath async {
    Directory? directory = await getExternalStorageDirectory(); //يتأكد من وجود تخزين خارجي في حال وجوده يحفظ عليه
    directory ??= await getApplicationDocumentsDirectory(); //  في حال عدم وجود تخزين خارجي يحفظ على الملف الأصل
    return directory.path;
  }

  static Future<File> get _localFile async {
    final String path = await _localPath;
    return File('$path/$_fileName.txt');
  }

  set fileName(String name) {
    if (name != "") {
      _fileName = name;
    } else {
      print("الاسم فارغ");
    }
  }

  /// تطبع الرسالة و تحفظها في ملف قابل للقراءة لا تدعم العربية
  static Future<File> log(String data) async {
    final File file = await _localFile;
    print(data);
    return file.writeAsString('$data\n', mode: FileMode.append);
  }
}


// موضع الملف 
// mtp://SAMSUNG_SAMSUNG_Android_RZCWA0X10FP/%D9%85%D9%83%D8%A7%D9%86%20%D8%A7%D9%84%D8%AA%D8%AE%D8%B2%D9%8A%D9%86%20%D8%A7%D9%84%D8%AF%D8%A7%D8%AE%D9%84%D9%8A/Android/data/com.example.salad_of_achievement/files/
// لا تبان البينات و البرنامج يعمل 