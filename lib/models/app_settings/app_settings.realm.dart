// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class AppSettings extends _AppSettings
    with RealmEntity, RealmObjectBase, RealmObject {
  AppSettings({
    String? localeStr,
    String? countryCode,
    Iterable<String> unselectedTopics = const [],
    String? lastReadAffirmationId,
  }) {
    RealmObjectBase.set(this, 'localeStr', localeStr);
    RealmObjectBase.set(this, 'countryCode', countryCode);
    RealmObjectBase.set<RealmList<String>>(
        this, 'unselectedTopics', RealmList<String>(unselectedTopics));
    RealmObjectBase.set(this, 'lastReadAffirmationId', lastReadAffirmationId);
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
  String? get lastReadAffirmationId =>
      RealmObjectBase.get<String>(this, 'lastReadAffirmationId') as String?;
  @override
  set lastReadAffirmationId(String? value) =>
      RealmObjectBase.set(this, 'lastReadAffirmationId', value);

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
      'lastReadAffirmationId': lastReadAffirmationId.toEJson(),
    };
  }

  static EJsonValue _toEJson(AppSettings value) => value.toEJson();
  static AppSettings _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return AppSettings(
      localeStr: fromEJson(ejson['localeStr']),
      countryCode: fromEJson(ejson['countryCode']),
      unselectedTopics: fromEJson(ejson['unselectedTopics']),
      lastReadAffirmationId: fromEJson(ejson['lastReadAffirmationId']),
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
      SchemaProperty('lastReadAffirmationId', RealmPropertyType.string,
          optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
