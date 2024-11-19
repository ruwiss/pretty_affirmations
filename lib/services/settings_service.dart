import 'dart:async';
import 'dart:ui';
import 'package:pretty_affirmations/generated/l10n.dart';
import 'package:pretty_affirmations/models/app_settings/app_settings.dart';
import 'package:realm/realm.dart';

class SettingsService {
  SettingsService() {
    _init();
  }
  // StreamController to notify listeners about locale changes
  final _localeController = StreamController<Locale>.broadcast();

  // Expose a stream that listeners can subscribe to
  Stream<Locale> get localeStream => _localeController.stream;

  final Configuration _config =
      Configuration.local([AppSettings.schema], schemaVersion: 4);
  late final Realm _realm;
  late AppSettings _settings;

  void _init() {
    _realm = Realm(_config);
    _settings = _realm.all<AppSettings>().isNotEmpty
        ? _realm.all<AppSettings>().single
        : _createDefaultSettings();
  }

  AppSettings _createDefaultSettings() {
    final settings = AppSettings();
    _realm.write(() {
      _realm.add(settings);
    });
    return settings;
  }

  Locale? get currentLocale {
    if (_settings.localeStr != null) {
      return Locale(_settings.localeStr!, _settings.countryCode);
    }
    return null;
  }

  Future<Locale> changeLocale(Locale locale) async {
    _realm.write(() {
      _settings.localeStr = locale.languageCode;
      _settings.countryCode = locale.countryCode;
    });
    await S.load(locale);

    // Notify listeners that the locale has changed
    _localeController.add(locale);
    return locale;
  }

  List<String> getUnselectedTopics() {
    return _settings.unselectedTopics.toList();
  }

  void setUnselectedTopics(List<String> topics) {
    _realm.write(() {
      _settings.unselectedTopics.clear();
      _settings.unselectedTopics.addAll(topics);
    });
  }

  void setLastReadAffirmationId(String id) {
    _realm.write(() {
      _settings.lastReadAffirmationId = id;
    });
  }

  String? getLastReadAffirmationId() {
    return _settings.lastReadAffirmationId;
  }

  // Close the stream controller when no longer needed
  void dispose() {
    _localeController.close();
  }
}
