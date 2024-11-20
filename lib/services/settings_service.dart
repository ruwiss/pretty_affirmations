import 'dart:async';
import 'dart:ui';
import 'package:pretty_affirmations/generated/l10n.dart';
import 'package:pretty_affirmations/models/app_settings/affirmation_last_reads.dart';
import 'package:pretty_affirmations/models/app_settings/app_settings.dart';
import 'package:realm/realm.dart';

class SettingsService {
  late final Realm _realm;
  late AppSettings _settings;
  final _localeController = StreamController<Locale>.broadcast();
  final Configuration _config = Configuration.local(
    [AppSettings.schema, AffirmationLastReads.schema],
    schemaVersion: 1,
  );

  Stream<Locale> get localeStream => _localeController.stream;

  SettingsService() {
    _initializeRealm();
  }

  void _initializeRealm() {
    _realm = Realm(_config);
    _settings = _getOrCreateSettings();
  }

  AppSettings _getOrCreateSettings() {
    return _realm.all<AppSettings>().isNotEmpty
        ? _realm.all<AppSettings>().single
        : _createDefaultSettings();
  }

  AppSettings _createDefaultSettings() {
    final settings = AppSettings();
    _realm.write(() => _realm.add(settings));
    return settings;
  }

  Locale? get currentLocale {
    final localeStr = _settings.localeStr;
    if (localeStr != null) {
      return Locale(localeStr, _settings.countryCode);
    }
    return null;
  }

  Future<Locale> changeLocale(Locale locale) async {
    _realm.write(() {
      _settings.localeStr = locale.languageCode;
      _settings.countryCode = locale.countryCode;
    });

    await S.load(locale);
    _localeController.add(locale);

    return locale;
  }

  List<String> getUnselectedTopics() => _settings.unselectedTopics.toList();

  void setUnselectedTopics(List<String> topics) {
    _realm.write(() {
      _settings.unselectedTopics
        ..clear()
        ..addAll(topics);
    });
  }

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

  String? getLastReadAffirmationId({String? categoryKey}) {
    final key = categoryKey ?? 'all';
    final result = _getLastReadsByCategory(key);
    return result.isEmpty ? null : result.single.lastReadId;
  }

  RealmResults<AffirmationLastReads> _getLastReadsByCategory(
      String categoryKey) {
    return _realm
        .all<AffirmationLastReads>()
        .query(r'categoryKey == $0', [categoryKey]);
  }

  void dispose() {
    _localeController.close();
  }
}
