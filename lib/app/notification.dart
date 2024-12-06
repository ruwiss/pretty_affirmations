import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:hayiqu/hayiqu.dart';

const String channelKey = 'affirmation_alert_0';

class NotificationController {
  NotificationController._();

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeLocalNotifications() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Bildirime tıklandığında yapılacak işlemler
      },
    );
  }

  static Future<void> notificationPermission() async {
    // Flutter Local Notifications'ın kendi izin mekanizmasını kullan
    final bool? result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    "Bildirim izni: $result".log();
  }

  static Future<void> clearAllScheduledNotifications() =>
      flutterLocalNotificationsPlugin.cancelAll();

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
  final now = DateTime.now();
  if (dateTime.isBefore(now)) return;

  final int notificationId =
      DateTime.now().millisecondsSinceEpoch.remainder(100000);

  const androidDetails = AndroidNotificationDetails(
    channelKey,
    'Affirmation',
    channelDescription: 'Daily affirmation notification',
    importance: Importance.high,
    priority: Priority.high,
    sound: RawResourceAndroidNotificationSound('notif'),
    color: Colors.deepPurple,
    enableVibration: true,
    visibility: NotificationVisibility.public,
  );

  NotificationDetails platformChannelSpecifics =
      const NotificationDetails(android: androidDetails);

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
    notificationId,
    '$emoji $title',
    msg,
    scheduledDate,
    platformChannelSpecifics,
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}
