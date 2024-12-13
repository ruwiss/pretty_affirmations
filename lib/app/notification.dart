import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:hayiqu/hayiqu.dart';

const String channelKey = 'affirmation_alert_1';

class NotificationController {
  NotificationController._();

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeLocalNotifications() async {
    tz.initializeTimeZones();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelKey,
      'Affirmation',
      description: 'Daily affirmation notification',
      importance: Importance.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notif'),
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_stat_logo');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Bildirime tıklandığında yapılacak işlemler
      },
    );
  }

  static Future<bool> notificationPermission() async {
    // Flutter Local Notifications'ın kendi izin mekanizmasını kullan
    final bool? result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    "Bildirim izni: $result".log();
    return result ?? false;
  }

  static Future<void> clearAllScheduledNotifications() =>
      flutterLocalNotificationsPlugin.cancelAll();

  static Future<void> cancelNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Test için 15 saniyelik bildirim gönderme fonksiyonu
  static Future<void> scheduleTestNotification() async {
    final now = DateTime.now();
    final scheduledDate = now.add(const Duration(minutes: 1));

    await myNotifyScheduleInHours(
      dateTime: scheduledDate,
      title: 'Test Bildirimi',
      msg: '1 dakikalık test bildirimi başarıyla çalıştı!',
      emoji: '✨',
    );

    'Test bildirimi ${scheduledDate.toString()} için planlandı'.log();
  }
}

Future<void> myNotifyScheduleInHours({
  required DateTime dateTime,
  required String title,
  required String msg,
  required String emoji,
}) async {
  final now = DateTime.now();
  if (dateTime.isBefore(now)) {
    'Bildirim zamanı geçmiş: $dateTime'.log();
    return;
  }

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
    fullScreenIntent: true,
    playSound: true,
    enableLights: true,
    styleInformation: BigTextStyleInformation(''),
  );

  NotificationDetails platformChannelSpecifics =
      const NotificationDetails(android: androidDetails);

  try {
    final scheduledDate = tz.TZDateTime.from(dateTime, tz.local);

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

    'Bildirim başarıyla zamanlandı - ID: $notificationId, Tarih: $scheduledDate'
        .log();
  } catch (e) {
    'Bildirim zamanlama hatası: $e'.log();
  }
}
