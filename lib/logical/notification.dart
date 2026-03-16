import 'dart:developer' show log;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:salad_of_achievement/main.dart';

class NotificationHelper {
  static bool _isInitialized = false;

  /// Initialize the notification system
  static Future<void> initializeNotifications() async {
    if (_isInitialized) return;

    try {
      // Initialize Awesome Notifications
      await AwesomeNotifications().initialize(
        'resource://drawable/ic_notification', // Use simple notification icon
        [
          NotificationChannel(
            channelKey: 'salad_achievement_immediate',
            channelName: 'Immediate Notifications',
            channelDescription: 'Immediate notifications for salad achievement',
            defaultColor: const Color(0xFF9D50DD),
            ledColor: const Color(0xFF9D50DD),
            importance: NotificationImportance.High,
            channelShowBadge: true,
            playSound: true,
            soundSource: 'resource://raw/done_sound',
            enableVibration: true,
            vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
          ),
          NotificationChannel(
            channelKey: 'salad_achievement_scheduled',
            channelName: 'Scheduled Notifications',
            channelDescription: 'Scheduled notifications after specified time',
            defaultColor: const Color(0xFF9D50DD),
            ledColor: const Color(0xFF9D50DD),
            importance: NotificationImportance.High,
            channelShowBadge: true,
            playSound: true,
            soundSource: 'resource://raw/done_sound',
            enableVibration: true,
            vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
          ),
        ],
      );

      // Request comprehensive notification permissions for release mode
      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        // Request all necessary permissions
        await AwesomeNotifications().requestPermissionToSendNotifications(
          channelKey: 'salad_achievement_immediate',
          permissions: [
            NotificationPermission.Alert,
            NotificationPermission.Sound,
            NotificationPermission.Badge,
            NotificationPermission.Vibration,
            NotificationPermission.Light,
            NotificationPermission.CriticalAlert,
            NotificationPermission.FullScreenIntent,
          ],
        );
      }

      log('🔔 Notification permissions granted: ${await AwesomeNotifications().isNotificationAllowed()}');

      // Set up notification listeners
      AwesomeNotifications().setListeners(
        onActionReceivedMethod: _onNotificationTapped,
        onNotificationCreatedMethod: _onNotificationCreated,
        onNotificationDisplayedMethod: _onNotificationDisplayed,
        onDismissActionReceivedMethod: _onDismissActionReceived,
      );

      _isInitialized = true;
      log('✅ Awesome Notification system initialized successfully');
    } catch (e) {
      log('❌ Failed to initialize notifications: $e');
      rethrow;
    }
  }

  /// Handle notification tap actions send arguments to active session page as payload
  /// payload : "[sessionTime,activityName,isFromNotification]"
  static Future<void> _onNotificationTapped(ReceivedAction receivedAction) async {
    // payload: "$sessionTime#:#$activityName",
    final List<String> payload = receivedAction.payload?['payload']!.split('#:#') ?? ['No payload'];

    log('🔔 Notification tapped with payload: $payload');
    // Handle navigation or other actions based on payload
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/activeSection',
      (route) => route.isFirst,
      arguments: [
        payload[0], payload[1], // payload[1]== activityName payload[0] == sessionTime
        true, // isFromNotification always true when coming from notification tap
      ],
    );
  }

  /// Handle notification created
  static Future<void> _onNotificationCreated(ReceivedNotification receivedNotification) async {
    log('🔔 Notification created: ${receivedNotification.title}');
  }

  /// Handle notification displayed
  static Future<void> _onNotificationDisplayed(ReceivedNotification receivedNotification) async {
    log('🔔 Notification displayed: ${receivedNotification.title}');
  }

  /// Handle notification dismissed
  static Future<void> _onDismissActionReceived(ReceivedAction receivedAction) async {
    log('🔔 Notification dismissed: ${receivedAction.title}');
  }

  /// Send an immediate notification (إشعار فوري)
  static Future<void> sendImmediateNotification({required int id, required String title, required String message, String? imagePath, String? payload}) async {
    if (!_isInitialized) {
      await initializeNotifications();
    }

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'salad_achievement_immediate',
          groupKey: 'salad_achievement_group',
          title: title,
          body: message,
          summary: "أنهيت جلسة ",
          payload: payload != null ? {'payload': payload} : null,
          notificationLayout: NotificationLayout.Default,
          wakeUpScreen: true,
          category: NotificationCategory.Reminder,
          displayOnForeground: true,
          displayOnBackground: true,
          icon: 'resource://drawable/ic_notification',
        ),
      );

      log('🔔 Immediate notification sent: $title');
    } catch (e) {
      log('❌ Failed to send immediate notification: $e');
      rethrow;
    }
  }

  /// Send a scheduled notification after specified seconds (إشعار بعد خمس ثواني)
  static Future<void> sendScheduledNotification({
    required int id,
    required String title,
    required String message,
    required int seconds,
    String? imagePath,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initializeNotifications();
    }

    try {
      final DateTime scheduledTime = DateTime.now().add(Duration(seconds: seconds));

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'salad_achievement_scheduled',
          title: title,
          body: message,
          payload: payload != null ? {'payload': payload} : null,
          notificationLayout: NotificationLayout.Default,
          wakeUpScreen: true,
          category: NotificationCategory.Reminder,
          displayOnForeground: true,
          displayOnBackground: true,
          // add later
          // autoDismissible: ,
          icon: 'resource://drawable/ic_notification',
        ),
        schedule: NotificationCalendar(
          year: scheduledTime.year,
          month: scheduledTime.month,
          day: scheduledTime.day,
          hour: scheduledTime.hour,
          minute: scheduledTime.minute,
          second: scheduledTime.second,
          allowWhileIdle: true,
          preciseAlarm: true,
        ),
      );

      log("📅 Scheduled for $scheduledTime");
      log('🔔 Notification scheduled for $seconds seconds: $title');
    } catch (e) {
      log('❌ Failed to schedule notification: $e');
      rethrow;
    }
  }

  /// Cancel all notifications (إلغاء جميع الإشعارات)
  static Future<void> cancelAllNotifications() async {
    try {
      await AwesomeNotifications().cancelAll();
      log('🚫 All notifications cancelled');
    } catch (e) {
      log('❌ Failed to cancel notifications: $e');
    }
  }

  /// Check notification status for release mode debugging
  static Future<void> verifyNotificationSetup() async {
    try {
      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
      List<NotificationModel> scheduledNotifications = await AwesomeNotifications().listScheduledNotifications();

      log('🔍 Notification Setup Verification:');
      log('   - Permissions allowed: $isAllowed');
      log('   - Scheduled notifications: ${scheduledNotifications.length}');
      log('   - Initialization status: $_isInitialized');

      if (!isAllowed) {
        log('⚠️ Notifications not allowed - request permissions');
      }
    } catch (e) {
      log('❌ Error verifying notification setup: $e');
    }
  }

  /// Force reinitialize for release mode issues
  static Future<void> forceReinitialize() async {
    try {
      _isInitialized = false;
      await initializeNotifications();
      await verifyNotificationSetup();
      log('🔄 Notification system reinitialized');
    } catch (e) {
      log('❌ Failed to reinitialize notifications: $e');
    }
  }
}
