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
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notif'),
      enableVibration: true,
      enableLights: true,
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
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation == null) {
      return false;
    }

    try {
      // Bildirim izni
      final bool? notificationResult =
          await androidImplementation.requestNotificationsPermission();

      // Tam zamanlı bildirimler için izin
      final bool? exactAlarmsResult =
          await androidImplementation.requestExactAlarmsPermission();

      "Bildirim izinleri: Notification=$notificationResult, ExactAlarms=$exactAlarmsResult"
          .log();

      // Tüm izinlerin alındığından emin olalım
      return (notificationResult ?? false) && (exactAlarmsResult ?? true);
    } catch (e) {
      "Bildirim izinleri alınırken hata: $e".log();
      return false;
    }
  }

  static Future<void> clearAllScheduledNotifications() =>
      flutterLocalNotificationsPlugin.cancelAll();

  static Future<void> cancelNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Test için 15 saniyelik bildirim gönderme fonksiyonu
  static Future<void> scheduleTestNotification() async {
    await clearAllScheduledNotifications();

    final now = DateTime.now();

    // İlk bildirim - 1 dakika sonra
    await myNotifyScheduleInHours(
      dateTime: now.add(const Duration(minutes: 1)),
      title: 'Test Bildirimi 1',
      msg: 'Birinci test bildirimi!',
      emoji: '✨',
    );

    // İkinci bildirim - 2 dakika sonra
    await myNotifyScheduleInHours(
      dateTime: now.add(const Duration(minutes: 2)),
      title: 'Test Bildirimi 2',
      msg: 'İkinci test bildirimi!',
      emoji: '🌟',
    );
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

  final int notificationId = dateTime.millisecondsSinceEpoch ~/ 1000;

  const androidDetails = AndroidNotificationDetails(
    channelKey,
    'Affirmation',
    channelDescription: 'Daily affirmation notification',
    importance: Importance.max,
    priority: Priority.max,
    sound: RawResourceAndroidNotificationSound('notif'),
    color: Color(0xFFf9eaea),
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    'Bildirim başarıyla zamanlandı - ID: $notificationId, Tarih: $scheduledDate'
        .log();
  } catch (e) {
    'Bildirim zamanlama hatası: $e'.log();
  }
}
