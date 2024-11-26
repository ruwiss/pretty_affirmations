// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class AppSettings extends _AppSettings
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  AppSettings({
    String? localeStr,
    String? countryCode,
    Iterable<String> unselectedTopics = const [],
    int dailyNotificationCount = 3,
    DateTime? nextFetchNotificationDate,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<AppSettings>({
        'dailyNotificationCount': 3,
      });
    }
    RealmObjectBase.set(this, 'localeStr', localeStr);
    RealmObjectBase.set(this, 'countryCode', countryCode);
    RealmObjectBase.set<RealmList<String>>(
        this, 'unselectedTopics', RealmList<String>(unselectedTopics));
    RealmObjectBase.set(this, 'dailyNotificationCount', dailyNotificationCount);
    RealmObjectBase.set(
        this, 'nextFetchNotificationDate', nextFetchNotificationDate);
  }

  AppSettings._();

  @override
  String? get localeStr =>
      RealmObjectBase.get<String>(this, 'localeStr') as String?;
  @override
  set localeStr(String? value) => RealmObjectBase.set(this, 'localeStr', value);

  @override
  String? get countryCode =>
      RealmObjectBase.get<String>(this, 'countryCode') as String?;
  @override
  set countryCode(String? value) =>
      RealmObjectBase.set(this, 'countryCode', value);

  @override
  RealmList<String> get unselectedTopics =>
      RealmObjectBase.get<String>(this, 'unselectedTopics')
          as RealmList<String>;
  @override
  set unselectedTopics(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  int get dailyNotificationCount =>
      RealmObjectBase.get<int>(this, 'dailyNotificationCount') as int;
  @override
  set dailyNotificationCount(int value) =>
      RealmObjectBase.set(this, 'dailyNotificationCount', value);

  @override
  DateTime? get nextFetchNotificationDate =>
      RealmObjectBase.get<DateTime>(this, 'nextFetchNotificationDate')
          as DateTime?;
  @override
  set nextFetchNotificationDate(DateTime? value) =>
      RealmObjectBase.set(this, 'nextFetchNotificationDate', value);

  @override
  Stream<RealmObjectChanges<AppSettings>> get changes =>
      RealmObjectBase.getChanges<AppSettings>(this);

  @override
  Stream<RealmObjectChanges<AppSettings>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<AppSettings>(this, keyPaths);

  @override
  AppSettings freeze() => RealmObjectBase.freezeObject<AppSettings>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'localeStr': localeStr.toEJson(),
      'countryCode': countryCode.toEJson(),
      'unselectedTopics': unselectedTopics.toEJson(),
      'dailyNotificationCount': dailyNotificationCount.toEJson(),
      'nextFetchNotificationDate': nextFetchNotificationDate.toEJson(),
    };
  }

  static EJsonValue _toEJson(AppSettings value) => value.toEJson();
  static AppSettings _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return AppSettings(
      localeStr: fromEJson(ejson['localeStr']),
      countryCode: fromEJson(ejson['countryCode']),
      unselectedTopics: fromEJson(ejson['unselectedTopics']),
      dailyNotificationCount:
          fromEJson(ejson['dailyNotificationCount'], defaultValue: 3),
      nextFetchNotificationDate: fromEJson(ejson['nextFetchNotificationDate']),
    );
  }

  static final schema = () {
    RealmObjectBase.registerFactory(AppSettings._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, AppSettings, 'AppSettings', [
      SchemaProperty('localeStr', RealmPropertyType.string, optional: true),
      SchemaProperty('countryCode', RealmPropertyType.string, optional: true),
      SchemaProperty('unselectedTopics', RealmPropertyType.string,
          collectionType: RealmCollectionType.list),
      SchemaProperty('dailyNotificationCount', RealmPropertyType.int),
      SchemaProperty('nextFetchNotificationDate', RealmPropertyType.timestamp,
          optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
