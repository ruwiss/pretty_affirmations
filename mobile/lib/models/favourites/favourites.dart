import 'package:realm/realm.dart';

part 'favourites.realm.dart';

@RealmModel()
class _Favourites {
  @PrimaryKey()
  late String id;
  late String content;
  late String categoryKey;
  late String categoryName;
  late DateTime dateTime;
}
