import 'package:pretty_affirmations/models/affirmation.dart';
import 'package:pretty_affirmations/models/favourites/favourites.dart';
import 'package:realm/realm.dart';

class FavouritesService {
  final Configuration _config = Configuration.local(
    [Favourites.schema],
    schemaVersion: 1,
  );

  late final Realm _realm;

  FavouritesService() {
    _realm = Realm(_config);
  }

  void _addFavourite(Affirmation affirmation) {
    final favourite = affirmation.toFavouriteModel();
    _realm.write(() {
      _realm.add(favourite);
    });
  }

  void _removeFavourite(Affirmation affirmation) {
    final favourite =
        _realm.all<Favourites>().query(r'id == $0', [affirmation.id]).first;
    _realm.write(() {
      _realm.delete(favourite);
    });
  }

  void deleteFavourite(Favourites favourite) {
    _realm.write(() {
      _realm.delete(favourite);
    });
  }

  bool _isFavourite(Affirmation affirmation) {
    return _realm
        .all<Favourites>()
        .query(r'id == $0', [affirmation.id]).isNotEmpty;
  }

  List<Favourites> toggleFavourite(Affirmation affirmation) {
    if (_isFavourite(affirmation)) {
      _removeFavourite(affirmation);
    } else {
      _addFavourite(affirmation);
    }
    return getFavourites();
  }

  List<Favourites> getFavourites() {
    return _realm.all<Favourites>().toList();
  }
}
