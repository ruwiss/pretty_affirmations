import 'package:realm/realm.dart';

part 'app_settings.realm.dart';

@RealmModel()
class _AppSettings {
  String? localeStr;
  String? countryCode;
  late List<String> unselectedTopics;
  String? lastReadAffirmationId;
}
