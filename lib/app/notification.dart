import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

const String channelKey = 'affirmation_alert_0';

class NotificationController {
  NotificationController._();

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  ///  *********************************************
  ///     BAŞLATMA
  ///  *********************************************
  ///
  static Future<void> initializeLocalNotifications() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> clearAllScheduledNotifications() =>
      flutterLocalNotificationsPlugin.cancelAll();

  static Future<void> notificationPermission() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static Future<void> cancelNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

Future<void> myNotifyScheduleInHours({
  required DateTime dateTime,
  required String title,
  required String msg,
  required String emoji,
}) async {
  if (dateTime.isBefore(DateTime.now())) return;

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    channelKey,
    'Affirmation',
    channelDescription: 'Daily affirmation notification',
    importance: Importance.high,
    priority: Priority.high,
    sound: RawResourceAndroidNotificationSound('notif'),
    color: Colors.deepPurple,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  final scheduledDate = tz.TZDateTime.from(
    DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      0,
    ),
    tz.local,
  );

  await NotificationController.flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    '$emoji $title',
    msg,
    scheduledDate,
    platformChannelSpecifics,
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}
