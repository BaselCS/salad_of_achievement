import 'dart:developer' show log;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// Simple notification helper class for Salad of Achievement app
///
/// Features:
/// - Send immediate notifications (فوري)
/// - Send scheduled notifications after 5 seconds (بعد خمس ثواني)
/// - Cancel all notifications
/// - Custom sound support
class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  /// Initialize the notification system
  static Future<void> initializeNotifications() async {
    if (_isInitialized) return;

    try {
      if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

        await androidImplementation?.requestNotificationsPermission();
        await androidImplementation?.requestExactAlarmsPermission();
      }

      // Initialize notifications
      const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');

      const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

      await _notificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: _onNotificationTapped);

      // Initialize timezone data
      tz.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      _isInitialized = true;
      log('✅ Notification system initialized successfully');
    } catch (e) {
      log('❌ Failed to initialize notifications: $e');
      rethrow;
    }
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    log('🔔 Notification tapped with payload: $payload');
  }

  /// Send an immediate notification (إشعار فوري)
  static Future<void> sendImmediateNotification({required int id, required String title, required String message, String? imagePath, String? payload}) async {
    if (!_isInitialized) {
      await initializeNotifications();
    }

    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'salad_achievement_immediate',
        'Immediate Notifications',
        channelDescription: 'Immediate notifications',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('done_sound'),
        enableVibration: true,
        ticker: 'تنبيه فوري',
      );

      const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'done_sound.mp3',
      );

      final NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidDetails, iOS: iOSDetails);

      await _notificationsPlugin.show(id, title, message, platformChannelSpecifics, payload: payload);

      log('🔔 Immediate notification sent: $title');
    } catch (e) {
      log('❌ Failed to send immediate notification: $e');
      rethrow;
    }
  }

  /// Send a scheduled notification after 5 seconds (إشعار بعد خمس ثواني)
  static Future<void> sendScheduledNotification({required int id, required String title, required String message, String? imagePath, String? payload}) async {
    if (!_isInitialized) {
      await initializeNotifications();
    }

    try {
      final scheduledTime = DateTime.now().add(const Duration(seconds: 5 * 60));

      // Create notification details
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'salad_achievement_scheduled',
        'Scheduled Notifications',
        channelDescription: 'Scheduled notifications after 5 seconds',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('done_sound'),
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
        ticker: 'تنبيه مؤجل',
      );

      const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'done_sound.mp3',
      );

      final NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidDetails, iOS: iOSDetails);

      // Convert DateTime to TZDateTime
      final tz.TZDateTime scheduledTZTime = tz.TZDateTime.from(scheduledTime, tz.local);

      // Schedule the notification
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        message,
        scheduledTZTime,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      log('🔔 Notification scheduled for 5 seconds: $title');
    } catch (e) {
      log('❌ Failed to schedule notification: $e');
      rethrow;
    }
  }

  /// Cancel all notifications (إلغاء جميع الإشعارات)
  static Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      log('🚫 All notifications cancelled');
    } catch (e) {
      log('❌ Failed to cancel notifications: $e');
    }
  }
}
