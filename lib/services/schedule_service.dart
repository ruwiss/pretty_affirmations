import 'package:hayiqu/hayiqu.dart';
import 'package:intl/intl.dart';
import 'package:pretty_affirmations/app/notification.dart';
import 'package:pretty_affirmations/common/extensions/string_extensions.dart';
import 'package:pretty_affirmations/generated/l10n.dart';
import 'package:pretty_affirmations/models/affirmation.dart';

import 'api_service.dart';
import 'settings_service.dart';

/// Bildirim zamanlaması için kullanılan servis
class ScheduleService {
  final _apiService = getIt<ApiService>();
  final _settingsService = getIt<SettingsService>();

  /// Bildirimleri kontrol eder ve zamanlar
  Future<void> checkAndScheduleAffirmations({bool force = false}) async {
    // Günlük bildirim sayısını al
    final int dailyNotificationCount =
        _settingsService.getDailyNotificationCount();

    // Bildirim sayısı 0 ise işlemi sonlandır
    if (dailyNotificationCount == 0) return;

    // Bir sonraki bildirim zamanlaması için kontrol
    if (!_shouldFetchNewAffirmations() && !force) return;

    // Rastgele olumlamalar al
    final scheduledAffirmations = await _fetchRandomAffirmations();
    if (scheduledAffirmations == null) return;

    // Bildirim sayısına göre gün hesapla
    final int itemCount = scheduledAffirmations.data.length;
    final int forDays = itemCount ~/ dailyNotificationCount;

    // Bir sonraki fetch tarihini ayarla
    _updateNextFetchDate(forDays);

    // Bildirimleri zamanla
    await _scheduleNotifications(
      scheduledAffirmations,
      dailyNotificationCount,
      forDays,
    );
  }

  /// Yeni olumlamalar getirilmeli mi kontrolü
  bool _shouldFetchNewAffirmations() {
    final nextFetch = _settingsService.nextFetchScheduleNotification();
    if (nextFetch == null) return true;

    final previousDate = nextFetch.subtract(const Duration(days: 1));
    return DateTime.now().isAfter(previousDate);
  }

  /// Rastgele olumlamalar getirir
  Future<Affirmations?> _fetchRandomAffirmations() {
    return _apiService.getRandomAffirmations(
      locale: _settingsService.currentLocale?.toLocaleStr() ??
          Intl.getCurrentLocale(),
    );
  }

  /// Bir sonraki fetch tarihini günceller
  void _updateNextFetchDate(int forDays) {
    final nextDate = DateTime.now().add(Duration(days: forDays));
    _settingsService.setNextFetchNotificationDate(nextDate);
  }

  /// Bildirimleri zamanlar
  Future<void> _scheduleNotifications(
    Affirmations affirmations,
    int dailyCount,
    int forDays,
  ) async {
    // Bildirim izinlerini kontrol et
    await NotificationController.notificationPermission();
    await NotificationController.clearAllScheduledNotifications();

    // Bildirim saatlerini al (örn: günde 3 bildirim için [8, 12, 18])
    final List<int> notificationHours = _getNotificationHours(dailyCount);

    // Şu anki tarih
    final DateTime today = DateTime.now();

    // Elimizdeki olumlama mesajlarını sırayla kullan
    int currentMessageIndex = 0;

    // Her gün için bildirim oluştur
    for (int dayOffset = 0; dayOffset < forDays; dayOffset++) {
      // O günün tarihini hesapla
      final DateTime targetDate = today.add(Duration(days: dayOffset));

      // O gün için belirlenen her saatte bildirim oluştur
      for (final int hour in notificationHours) {
        // Eğer tüm mesajlar kullanıldıysa döngüyü bitir
        if (currentMessageIndex >= affirmations.data.length) break;

        // Bildirimi oluştur
        final String affirmationMessage =
            affirmations.data[currentMessageIndex].content;
        await _createNotification(
          currentDay: targetDate,
          hour: hour,
          message: affirmationMessage,
        );

        // Sonraki mesaja geç
        currentMessageIndex++;
      }
    }
  }

  /// Tek bir bildirim oluşturur
  Future<void> _createNotification({
    required DateTime currentDay,
    required int hour,
    required String message,
  }) async {
    final dateTime = DateTime(
      currentDay.year,
      currentDay.month,
      currentDay.day,
      hour,
    );

    await myNotifyScheduleInHours(
      dateTime: dateTime,
      title: _randomNotificationTitle(),
      msg: message,
      emoji: _randomNotificationEmoji(),
    );
  }

  /// Bildirim saatlerini döndürür
  List<int> _getNotificationHours(int dailyNotificationCount) {
    return switch (dailyNotificationCount) {
      1 => [12], // Günde 1 bildirim: Öğlen 12'de
      2 => [11, 15], // Günde 2 bildirim: 11:00 ve 15:00'te
      3 => [8, 12, 18], // Günde 3 bildirim: Sabah, öğlen ve akşam
      4 => [9, 12, 16, 21], // Günde 4 bildirim: Sabah, öğlen, ikindi ve akşam
      _ => [],
    };
  }

  /// Rastgele bir bildirim emojisi döndürür
  String _randomNotificationEmoji() {
    const emojis = [
      "🌟",
      "💖",
      "🌈",
      "☀️",
      "✨",
      "🍀",
      "🌻",
      "💫",
      "🕊️",
      "🌸",
      "🎉",
      "🏞️",
      "💎",
      "🔥",
      "📖",
      "💐",
      "🧘‍♂️",
      "🎨",
      "🚀",
      "🦋",
      "🎵",
      "🌍",
      "🪐",
      "💡",
    ];
    return (List.from(emojis)..shuffle()).first;
  }

  /// Rastgele bir bildirim başlığı döndürür
  String _randomNotificationTitle() {
    final titles = [
      S.current.notificationTitle1,
      S.current.notificationTitle2,
      S.current.notificationTitle3,
      S.current.notificationTitle4,
      S.current.notificationTitle5,
      S.current.notificationTitle6,
      S.current.notificationTitle7,
      S.current.notificationTitle8,
      S.current.notificationTitle9,
    ];
    return (List.from(titles)..shuffle()).first;
  }
}
