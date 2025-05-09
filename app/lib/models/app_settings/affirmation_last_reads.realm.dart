// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'affirmation_last_reads.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class AffirmationLastReads extends _AffirmationLastReads
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  AffirmationLastReads(
    String lastReadId, {
    String categoryKey = 'all',
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<AffirmationLastReads>({
        'categoryKey': 'all',
      });
    }
    RealmObjectBase.set(this, 'categoryKey', categoryKey);
    RealmObjectBase.set(this, 'lastReadId', lastReadId);
  }

  AffirmationLastReads._();

  @override
  String get categoryKey =>
      RealmObjectBase.get<String>(this, 'categoryKey') as String;
  @override
  set categoryKey(String value) =>
      RealmObjectBase.set(this, 'categoryKey', value);

  @override
  String get lastReadId =>
      RealmObjectBase.get<String>(this, 'lastReadId') as String;
  @override
  set lastReadId(String value) =>
      RealmObjectBase.set(this, 'lastReadId', value);

  @override
  Stream<RealmObjectChanges<AffirmationLastReads>> get changes =>
      RealmObjectBase.getChanges<AffirmationLastReads>(this);

  @override
  Stream<RealmObjectChanges<AffirmationLastReads>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<AffirmationLastReads>(this, keyPaths);

  @override
  AffirmationLastReads freeze() =>
      RealmObjectBase.freezeObject<AffirmationLastReads>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'categoryKey': categoryKey.toEJson(),
      'lastReadId': lastReadId.toEJson(),
    };
  }

  static EJsonValue _toEJson(AffirmationLastReads value) => value.toEJson();
  static AffirmationLastReads _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'lastReadId': EJsonValue lastReadId,
      } =>
        AffirmationLastReads(
          fromEJson(lastReadId),
          categoryKey: fromEJson(ejson['categoryKey'], defaultValue: 'all'),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(AffirmationLastReads._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, AffirmationLastReads, 'AffirmationLastReads', [
      SchemaProperty('categoryKey', RealmPropertyType.string),
      SchemaProperty('lastReadId', RealmPropertyType.string),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
