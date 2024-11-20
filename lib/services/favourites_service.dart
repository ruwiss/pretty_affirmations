import 'package:pretty_affirmations/models/affirmation.dart';
import 'package:pretty_affirmations/models/favourites/favourites.dart';
import 'package:realm/realm.dart';

class FavouritesService {
  late final Realm _realm;

  FavouritesService() {
    _realm = Realm(_createConfig());
  }

  Configuration _createConfig() {
    return Configuration.local(
      [Favourites.schema],
      schemaVersion: 1,
    );
  }

  RealmResults<Favourites> get _favourites => _realm.all<Favourites>();

  void _addFavourite(Affirmation affirmation) {
    _realm.write(() {
      _realm.add(affirmation.toFavouriteModel());
    });
  }

  void _removeFavourite(Affirmation affirmation) {
    final favourite = _getFavouriteById(affirmation.id);
    if (favourite != null) {
      _realm.write(() {
        _realm.delete(favourite);
      });
    }
  }

  void deleteFavourite(Favourites favourite) {
    _realm.write(() {
      _realm.delete(favourite);
    });
  }

  Favourites? _getFavouriteById(String id) {
    final results = _favourites.query(r'id == $0', [id]);
    return results.isEmpty ? null : results.first;
  }

  bool _isFavourite(Affirmation affirmation) {
    return _getFavouriteById(affirmation.id) != null;
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
    return _favourites.toList();
  }
}
