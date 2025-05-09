// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favourites.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class Favourites extends _Favourites
    with RealmEntity, RealmObjectBase, RealmObject {
  Favourites(
    String id,
    String content,
    String categoryKey,
    String categoryName,
    DateTime dateTime,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'content', content);
    RealmObjectBase.set(this, 'categoryKey', categoryKey);
    RealmObjectBase.set(this, 'categoryName', categoryName);
    RealmObjectBase.set(this, 'dateTime', dateTime);
  }

  Favourites._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get content => RealmObjectBase.get<String>(this, 'content') as String;
  @override
  set content(String value) => RealmObjectBase.set(this, 'content', value);

  @override
  String get categoryKey =>
      RealmObjectBase.get<String>(this, 'categoryKey') as String;
  @override
  set categoryKey(String value) =>
      RealmObjectBase.set(this, 'categoryKey', value);

  @override
  String get categoryName =>
      RealmObjectBase.get<String>(this, 'categoryName') as String;
  @override
  set categoryName(String value) =>
      RealmObjectBase.set(this, 'categoryName', value);

  @override
  DateTime get dateTime =>
      RealmObjectBase.get<DateTime>(this, 'dateTime') as DateTime;
  @override
  set dateTime(DateTime value) => RealmObjectBase.set(this, 'dateTime', value);

  @override
  Stream<RealmObjectChanges<Favourites>> get changes =>
      RealmObjectBase.getChanges<Favourites>(this);

  @override
  Stream<RealmObjectChanges<Favourites>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Favourites>(this, keyPaths);

  @override
  Favourites freeze() => RealmObjectBase.freezeObject<Favourites>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'content': content.toEJson(),
      'categoryKey': categoryKey.toEJson(),
      'categoryName': categoryName.toEJson(),
      'dateTime': dateTime.toEJson(),
    };
  }

  static EJsonValue _toEJson(Favourites value) => value.toEJson();
  static Favourites _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'content': EJsonValue content,
        'categoryKey': EJsonValue categoryKey,
        'categoryName': EJsonValue categoryName,
        'dateTime': EJsonValue dateTime,
      } =>
        Favourites(
          fromEJson(id),
          fromEJson(content),
          fromEJson(categoryKey),
          fromEJson(categoryName),
          fromEJson(dateTime),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Favourites._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, Favourites, 'Favourites', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('content', RealmPropertyType.string),
      SchemaProperty('categoryKey', RealmPropertyType.string),
      SchemaProperty('categoryName', RealmPropertyType.string),
      SchemaProperty('dateTime', RealmPropertyType.timestamp),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
