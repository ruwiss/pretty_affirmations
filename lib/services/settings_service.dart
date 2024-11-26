import 'dart:async';
import 'dart:ui';
import 'package:pretty_affirmations/common/common.dart';
import 'package:pretty_affirmations/generated/l10n.dart';
import 'package:pretty_affirmations/models/app_settings/affirmation_last_reads.dart';
import 'package:pretty_affirmations/models/app_settings/app_settings.dart';
import 'package:realm/realm.dart';

/// Uygulama ayarlarını yöneten servis sınıfı
class SettingsService {
  late final Realm _realm;
  late AppSettings _settings;
  final _localeController = StreamController<Locale>.broadcast();
  final Configuration _config = Configuration.local(
    [AppSettings.schema, AffirmationLastReads.schema],
    schemaVersion: kLocalDbSchemaVersion,
  );

  /// Dil değişikliklerini dinlemek için kullanılan stream
  Stream<Locale> get localeStream => _localeController.stream;

  SettingsService() {
    _initializeRealm();
  }

  /// Realm veritabanını başlatır
  void _initializeRealm() {
    _realm = Realm(_config);
    _settings = _getOrCreateSettings();
  }

  /// Mevcut ayarları getirir veya yeni bir ayar oluşturur
  AppSettings _getOrCreateSettings() {
    return _realm.all<AppSettings>().isNotEmpty
        ? _realm.all<AppSettings>().single
        : _createDefaultSettings();
  }

  /// Varsayılan ayarları oluşturur
  AppSettings _createDefaultSettings() {
    final settings = AppSettings();
    _realm.write(() => _realm.add(settings));
    return settings;
  }

  /// Mevcut dil ayarını döndürür
  Locale? get currentLocale {
    final localeStr = _settings.localeStr;
    if (localeStr != null) {
      return Locale(localeStr, _settings.countryCode);
    }
    return null;
  }

  /// Dil ayarını değiştirir
  Future<Locale> changeLocale(Locale locale) async {
    _realm.write(() {
      _settings.localeStr = locale.languageCode;
      _settings.countryCode = locale.countryCode;
    });

    await S.load(locale);
    _localeController.add(locale);

    return locale;
  }

  /// Seçilmemiş konuları döndürür
  List<String> getUnselectedTopics() => _settings.unselectedTopics.toList();

  /// Seçilmemiş konuları ayarlar
  void setUnselectedTopics(List<String> topics) {
    _realm.write(() {
      _settings.unselectedTopics
        ..clear()
        ..addAll(topics);
    });
  }

  /// Son okunan affirmation ID'sini ayarlar
  void setLastReadAffirmationId(String id, {String? categoryKey}) {
    final key = categoryKey ?? 'all';
    final results = _getLastReadsByCategory(key);

    _realm.write(() {
      if (results.isNotEmpty) {
        results.single.lastReadId = id;
      } else {
        _realm.add(AffirmationLastReads(id, categoryKey: key));
      }
    });
  }

  /// Son okunan affirmation ID'sini getirir
  String? getLastReadAffirmationId({String? categoryKey}) {
    final key = categoryKey ?? 'all';
    final result = _getLastReadsByCategory(key);
    return result.isEmpty ? null : result.single.lastReadId;
  }

  /// Belirli bir kategori için son okumaları getirir
  RealmResults<AffirmationLastReads> _getLastReadsByCategory(
      String categoryKey) {
    return _realm
        .all<AffirmationLastReads>()
        .query(r'categoryKey == $0', [categoryKey]);
  }

  /// Günlük bildirim sayısını getirir
  int getDailyNotificationCount() => _settings.dailyNotificationCount;

  /// Günlük bildirim sayısını ayarlar
  void setDailyNotificationCount(int count) {
    _realm.write(() => _settings.dailyNotificationCount = count);
  }

  /// Bir sonraki bildirim çekme zamanını döndürür
  DateTime? nextFetchScheduleNotification() =>
      _settings.nextFetchNotificationDate;

  /// Bir sonraki bildirim çekme zamanını ayarlar
  void setNextFetchNotificationDate(DateTime? date) {
    _realm.write(() => _settings.nextFetchNotificationDate = date);
  }

  /// Reklamların etkin olup olmadığını ayarlar
  void setAdsEnabled(bool enabled) {
    _realm.write(() => _settings.adsEnabled = enabled);
  }

  /// Reklamların etkin olup olmadığını döndürür
  bool getAdsEnabled() => _settings.adsEnabled;

  /// Servis kapatılırken çağrılır
  void dispose() {
    _localeController.close();
  }
}
