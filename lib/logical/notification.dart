//https://www.youtube.com/watch?v=_eEog7puQaw

// ignore_for_file: depend_on_referenced_packages

/*
1- اضافة الاضافة في ال pubspec.yaml
flutter_timezone
flutter_local_notifications
2- اضافة الصلاحيات في للأنظمة
android\app\src\main\AndroidManifest.xml

<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <uses-permission android:name="android.permission.USE_EXACT_ALARM" />   
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" android:maxSdkVersion="32" />
    
    <application.......
    .
    .
    .
    .
    .
      <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
      <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
          <intent-filter>
              <action android:name="android.intent.action.BOOT_COMPLETED"/>
              <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
              <action android:name="android.intent.action.QUICKBOOT_POWERON" />
              <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
          </intent-filter>
      </receiver>

    </application>


3- اضافة الاشعارات في ال main.dart
NotificationHelper().initializeNotifications();
4- اضافة الاشعارات في الصفحة
NotificationHelper.textNotification("title", "body", {timeInSecond: 5});

*/

import 'dart:developer' show log;
import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:salad_of_achievement/utilities/const.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz; // مكتبات التوقيت
import 'package:timezone/data/latest.dart' as tz; // مكتبات التوقيت

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  static final onClickNotification = BehaviorSubject<String>();

  Future<void> initializeNotifications() async {
    _notificationsPlugin.initialize(
      const InitializationSettings(
        // android\app\src\main\res\mipmap-mdpi\app_icon.png
        android: AndroidInitializationSettings('@mipmap/launcher_icon'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onNotificationTap,
    );
    // نجهز التوقيت
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  static void onNotificationTap(NotificationResponse notificationResponse) {
    onClickNotification.add("${notificationResponse.actionId}#${notificationResponse.payload}");
  }

  static void textNotification(String title, String body, {int timeInSecond = 10, String payload = ''}) async {
    timeInSecond = max(1, timeInSecond);
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'BaselChannelName',
      'channel_name',
      ticker: 'ticker',
      playSound: true,

      // android\app\src\main\res\raw\notification.mp3  بدون الامتداد و لازم raw
      sound: RawResourceAndroidNotificationSound('notification'),
      importance: Importance.max,
      priority: Priority.high,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'save_action', // معرف الفعل
          'حفظ', // اسم الفعل
          titleColor: kActionColor,
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'cancel_action',
          'إلغاء',
          titleColor: Colors.red,
          showsUserInterface: true,
        ),
      ],
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: DarwinNotificationDetails());
    await _notificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      payload: payload,
      tz.TZDateTime.now(tz.local).add(Duration(seconds: timeInSecond)),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // لو حطيتها بتظهر الاشعار بعد الوقت اللي حطيته بالثانية
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, // لو حطيتها بتظهر الاشعار بعد الوقت اللي حطيته بالثانية
    );
  }

  static void cancelNotification() async {
    log("تم الغاء الاشعارات");
    await _notificationsPlugin.cancelAll();
  }
}
