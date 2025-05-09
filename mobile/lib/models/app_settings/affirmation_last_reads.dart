import 'package:realm/realm.dart';

part 'affirmation_last_reads.realm.dart';

@RealmModel()
class _AffirmationLastReads {
  String categoryKey = 'all';
  late String lastReadId;
}
