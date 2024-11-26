import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

const String channelKey = 'affirmation_alert_0';

class NotificationController {
  NotificationController._();
  static ReceivedAction? initialAction;

  ///  *********************************************
  ///     INITIALIZATIONS
  ///  *********************************************
  ///
  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
        null, //'resource://drawable/res_app_icon',//
        [
          NotificationChannel(
            channelKey: channelKey,
            channelName: 'Affirmation',
            channelDescription: 'Daily affirmation notification',
            playSound: true,
            onlyAlertOnce: false,
            groupAlertBehavior: GroupAlertBehavior.Children,
            importance: NotificationImportance.High,
            defaultPrivacy: NotificationPrivacy.Public,
            defaultColor: Colors.deepPurple,
            ledColor: Colors.deepPurple,
          )
        ],
        debug: true);

    // Get initial notification action is optional
    initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);
  }

  static Future<void> clearAllScheduledNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  static Future<void> notificationPermission() async {
    if (await AwesomeNotifications().isNotificationAllowed()) {
      if (!await AwesomeNotifications()
          .requestPermissionToSendNotifications()) {
        return;
      }
    }
  }

  static Future<void> cancelNotifications() async {
    await AwesomeNotifications().cancelAll();
  }
}

Future<void> myNotifyScheduleInHours({
  required DateTime dateTime,
  required String title,
  required String msg,
  required String emoji,
  bool repeatNotif = false,
}) async {
  await AwesomeNotifications().createNotification(
    schedule: NotificationCalendar(
      day: dateTime.day,
      hour: dateTime.hour,
      minute: 0,
      second: 0,
      repeats: repeatNotif,
    ),
    content: NotificationContent(
      id: -1,
      channelKey: channelKey,
      title: '$emoji $title',
      body: msg,
      customSound: 'resource://raw/notif',
    ),
  );
}
