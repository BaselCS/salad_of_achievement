import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:salad_of_achievement/Pages/active_session.dart';
import 'package:salad_of_achievement/main.dart';
import 'package:salad_of_achievement/logical/app_logger.dart';
import 'package:salad_of_achievement/utilities/const.dart';
import 'package:salad_of_achievement/utilities/page_animation.dart';

class NotificationHelper {
  static bool _isInitialized = false;
  static ReceivedAction? _pendingNavigationAction;
  static bool _retryScheduled = false;

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

      AppLogger.log(
        '🔔 Notification permissions granted: ${await AwesomeNotifications().isNotificationAllowed()}',
        tag: 'notification',
      );

      // Set up notification listeners
      AwesomeNotifications().setListeners(
        onActionReceivedMethod: _onNotificationTapped,
        onNotificationCreatedMethod: _onNotificationCreated,
        onNotificationDisplayedMethod: _onNotificationDisplayed,
        onDismissActionReceivedMethod: _onDismissActionReceived,
      );

      _isInitialized = true;
      AppLogger.log(
        '✅ Awesome Notification system initialized successfully',
        tag: 'notification',
      );
    } catch (e) {
      AppLogger.log(
        '❌ Failed to initialize notifications: $e',
        tag: 'notification',
      );
      rethrow;
    }
  }

  /// Check for initial notification action (when app is launched from notification)
  static Future<void> checkInitialNotification() async {
    try {
      final ReceivedAction? receivedAction = await AwesomeNotifications()
          .getInitialNotificationAction(removeFromActionEvents: true);
      if (receivedAction != null) {
        AppLogger.log(
          '🚀 App launched from notification: ${receivedAction.payload}',
          tag: 'notification',
        );
        _handleNotificationNavigation(receivedAction);
      }
    } catch (e) {
      AppLogger.log(
        '❌ Failed to check initial notification: $e',
        tag: 'notification',
      );
    }
  }

  /// Centralized navigation handler
  static void _handleNotificationNavigation(ReceivedAction receivedAction) {
    // payload: "$sessionTime#:#$activityName",
    final String? rawPayload = receivedAction.payload?['payload'];
    if (rawPayload == null) {
      AppLogger.log('⚠️ Notification payload is missing', tag: 'notification');
      return;
    }

    final List<String> payload = rawPayload.split('#:#');
    if (payload.length < 2) {
      AppLogger.log('⚠️ Invalid payload format: $payload', tag: 'notification');
      return;
    }

    AppLogger.log('🔔 Navigating with payload: $payload', tag: 'notification');

    // Check if navigator is ready
    if (navigatorKey.currentState == null) {
      AppLogger.log(
        '⚠️ Navigator state is null, deferring navigation',
        tag: 'notification',
      );
      _pendingNavigationAction = receivedAction;
      _schedulePendingNavigationRetry();
      return;
    }

    _pendingNavigationAction = null;

    navigatorKey.currentState?.pushAndRemoveUntil(
      comeFromDownRoute(
        ActiveSectionPage(arguments: [payload[0], payload[1], true]),
      ),
      (route) => route.isFirst,
    );
  }

  static void _schedulePendingNavigationRetry() {
    if (_retryScheduled) {
      return;
    }

    _retryScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _retryScheduled = false;
      final ReceivedAction? pendingAction = _pendingNavigationAction;
      if (pendingAction != null) {
        _handleNotificationNavigation(pendingAction);
      }
    });
  }

  /// Handle notification tap actions send arguments to active session page as payload
  /// payload : "[sessionTime,activityName,isFromNotification]"
  static Future<void> _onNotificationTapped(
    ReceivedAction receivedAction,
  ) async {
    AppLogger.log(
      '🔔 Notification tapped: ${receivedAction.title}',
      tag: 'notification',
    );
    _handleNotificationNavigation(receivedAction);
  }

  /// Handle notification created
  static Future<void> _onNotificationCreated(
    ReceivedNotification receivedNotification,
  ) async {
    AppLogger.log(
      '🔔 Notification created: ${receivedNotification.title}',
      tag: 'notification',
    );
  }

  /// Handle notification displayed
  static Future<void> _onNotificationDisplayed(
    ReceivedNotification receivedNotification,
  ) async {
    AppLogger.log(
      '🔔 Notification displayed: ${receivedNotification.title}',
      tag: 'notification',
    );
  }

  /// Handle notification dismissed
  static Future<void> _onDismissActionReceived(
    ReceivedAction receivedAction,
  ) async {
    AppLogger.log(
      '🔔 Notification dismissed: ${receivedAction.title}',
      tag: 'notification',
    );
  }

  /// Send an immediate notification (إشعار فوري)
  static Future<void> sendImmediateNotification({
    required int id,
    required String title,
    required String message,
    String? imagePath,
    String? payload,
  }) async {
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

      AppLogger.log(
        '🔔 Immediate notification sent: $title',
        tag: 'notification',
      );
    } catch (e) {
      AppLogger.log(
        '❌ Failed to send immediate notification: $e',
        tag: 'notification',
      );
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
      final int scaledSeconds = seconds <= 0
          ? 0
          : (seconds < kTimeAccelerationFactor
                ? 1
                : (seconds / kTimeAccelerationFactor).ceil());
      final DateTime scheduledTime = DateTime.now().add(
        Duration(seconds: scaledSeconds),
      );

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

      AppLogger.log("📅 Scheduled for $scheduledTime", tag: 'notification');
      AppLogger.log(
        '🔔 Notification scheduled for $scaledSeconds real seconds ($seconds virtual seconds): $title',
        tag: 'notification',
      );
    } catch (e) {
      AppLogger.log(
        '❌ Failed to schedule notification: $e',
        tag: 'notification',
      );
      rethrow;
    }
  }

  /// Cancel all notifications (إلغاء جميع الإشعارات)
  static Future<void> cancelAllNotifications() async {
    try {
      await AwesomeNotifications().cancelAll();
      AppLogger.log('🚫 All notifications cancelled', tag: 'notification');
    } catch (e) {
      AppLogger.log(
        '❌ Failed to cancel notifications: $e',
        tag: 'notification',
      );
    }
  }

  /// Check notification status for release mode debugging
  static Future<void> verifyNotificationSetup() async {
    try {
      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
      List<NotificationModel> scheduledNotifications =
          await AwesomeNotifications().listScheduledNotifications();

      AppLogger.log('🔍 Notification Setup Verification:', tag: 'notification');
      AppLogger.log(
        '   - Permissions allowed: $isAllowed',
        tag: 'notification',
      );
      AppLogger.log(
        '   - Scheduled notifications: ${scheduledNotifications.length}',
        tag: 'notification',
      );
      AppLogger.log(
        '   - Initialization status: $_isInitialized',
        tag: 'notification',
      );

      if (!isAllowed) {
        AppLogger.log(
          '⚠️ Notifications not allowed - request permissions',
          tag: 'notification',
        );
      }
    } catch (e) {
      AppLogger.log(
        '❌ Error verifying notification setup: $e',
        tag: 'notification',
      );
    }
  }

  /// Force reinitialize for release mode issues
  static Future<void> forceReinitialize() async {
    try {
      _isInitialized = false;
      await initializeNotifications();
      await verifyNotificationSetup();
      AppLogger.log(
        '🔄 Notification system reinitialized',
        tag: 'notification',
      );
    } catch (e) {
      AppLogger.log(
        '❌ Failed to reinitialize notifications: $e',
        tag: 'notification',
      );
    }
  }
}
