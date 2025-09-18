// //https://www.youtube.com/watch?v=_eEog7puQaw

// // ignore_for_file: depend_on_referenced_packages

// /*
// 1- اضافة الاضافة في ال pubspec.yaml
// flutter_timezone
// flutter_local_notifications
// 2- اضافة الصلاحيات في للأنظمة
// android\app\src\main\AndroidManifest.xml

// <manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
//     <uses-permission android:name="android.permission.USE_EXACT_ALARM" />   
//     <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" android:maxSdkVersion="32" />
    
//     <application.......
//     .
//     .
//     .
//     .
//     .
//       <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
//       <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
//           <intent-filter>
//               <action android:name="android.intent.action.BOOT_COMPLETED"/>
//               <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
//               <action android:name="android.intent.action.QUICKBOOT_POWERON" />
//               <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
//           </intent-filter>
//       </receiver>

//     </application>


// 3- اضافة الاشعارات في ال main.dart
// NotificationHelper().initializeNotifications();
// 4- اضافة الاشعارات في الصفحة
// NotificationHelper.textNotification("title", "body", {timeInSecond: 5});

// */

// import 'dart:developer' show log;

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_timezone/flutter_timezone.dart';
// import 'package:timezone/timezone.dart' as tz; // مكتبات التوقيت
// import 'package:timezone/data/latest.dart' as tz;

// import '../Pages/active_session.dart'; // مكتبات التوقيت

// class NotificationHelper {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

//   Future<void> initializeNotifications() async {
//     // Request permissions for Android
//     // await _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();

//     await _notificationsPlugin.initialize(
//       const InitializationSettings(
//         // android\app\src\main\res\mipmap-mdpi\app_icon.png
//         android: AndroidInitializationSettings('@mipmap/launcher_icon'),
//         iOS: DarwinInitializationSettings(),
//       ),
//     );
//     // نجهز التوقيت
//     tz.initializeTimeZones();
//     final String timeZoneName = await FlutterTimezone.getLocalTimezone();
//     tz.setLocalLocation(tz.getLocation(timeZoneName));
//   }

//   static void textNotification(String title, String body, {int timeInSecond = 1}) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       'BaselChannelName',
//       'channel_name',
//       ticker: 'ticker',
//       playSound: true,
//       // android\app\src\main\res\raw\notification.mp3  بدون الامتداد و لازم raw
//       sound: RawResourceAndroidNotificationSound('notification'),
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: DarwinNotificationDetails());
//     log("الأشعار سوف يظهر بعد ${(timeInSecond ~/ 60)} دقيقة و ${timeInSecond % 60} ثانية");
//     inform += "${DateTime.now()} - الأشعار سوف يظهر بعد ${(timeInSecond ~/ 60)} دقيقة و ${timeInSecond % 60} ثانية\n";
//     // await _notificationsPlugin.zonedSchedule(
//     //   0,
//     //   title,
//     //   body,
//     //   tz.TZDateTime.now(tz.local).add(Duration(minutes: (timeInSecond ~/ 60), seconds: timeInSecond % 60)),
//     //   platformChannelSpecifics,
//     //   androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // لو حطيتها بتظهر الاشعار بعد الوقت اللي حطيته بالثانية
//     // );
//   }

//   static void cancelNotification() async {
//     log("تم الغاء الاشعارات");
//     inform += "${DateTime.now()} - تم الغاء الاشعارات\n";
//     await _notificationsPlugin.cancelAll();
//   }
// }
