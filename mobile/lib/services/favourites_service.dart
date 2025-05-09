import 'package:pretty_affirmations/common/common.dart';
import 'package:pretty_affirmations/models/affirmation.dart';
import 'package:pretty_affirmations/models/favourites/favourites.dart';
import 'package:realm/realm.dart';

/// Favorileri yönetmek için kullanılan servis sınıfı
class FavouritesService {
  late final Realm _realm;

  /// Servis başlatıldığında Realm veritabanını yapılandırır
  FavouritesService() {
    _realm = Realm(_createConfig());
  }

  /// Realm yapılandırmasını oluşturur
  Configuration _createConfig() {
    return Configuration.local(
      [Favourites.schema],
      schemaVersion: kLocalDbSchemaVersion,
    );
  }

  /// Tüm favorileri içeren RealmResults
  RealmResults<Favourites> get _favourites => _realm.all<Favourites>();

  /// Yeni bir favori ekler
  void _addFavourite(Affirmation affirmation) {
    _realm.write(() {
      _realm.add(affirmation.toFavouriteModel());
    });
  }

  /// Bir favoriyi kaldırır
  void _removeFavourite(Affirmation affirmation) {
    final favourite = _getFavouriteById(affirmation.id);
    if (favourite != null) {
      _realm.write(() {
        _realm.delete(favourite);
      });
    }
  }

  /// Belirli bir favoriyi siler
  void deleteFavourite(Favourites favourite) {
    _realm.write(() {
      _realm.delete(favourite);
    });
  }

  /// ID'ye göre favori bulur
  Favourites? _getFavouriteById(String id) {
    final results = _favourites.query(r'id == $0', [id]);
    return results.isEmpty ? null : results.first;
  }

  /// Bir affirmation'ın favori olup olmadığını kontrol eder
  bool _isFavourite(Affirmation affirmation) {
    return _getFavouriteById(affirmation.id) != null;
  }

  /// Favori durumunu değiştirir ve güncel favori listesini döndürür
  List<Favourites> toggleFavourite(Affirmation affirmation) {
    if (_isFavourite(affirmation)) {
      _removeFavourite(affirmation);
    } else {
      _addFavourite(affirmation);
    }
    return getFavourites();
  }

  /// Tüm favorileri liste olarak döndürür
  List<Favourites> getFavourites() {
    return _favourites.toList();
  }
}
