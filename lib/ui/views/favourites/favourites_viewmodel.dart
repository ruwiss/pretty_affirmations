import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/common/common.dart';
import 'package:pretty_affirmations/generated/l10n.dart';
import 'package:pretty_affirmations/models/favourites/favourites.dart';
import 'package:pretty_affirmations/services/favourites_service.dart';
import 'package:share_plus/share_plus.dart';

class FavouritesViewmodel extends BaseViewModel {
  final _favouritesService = getIt<FavouritesService>();

  FavouritesViewmodel() {
    _getFavourites();
  }

  List<Favourites> _favourites = [];
  List<Favourites> get favourites => _favourites.reversed.toList();

  void _getFavourites() {
    _favourites = _favouritesService.getFavourites();
    notifyListeners();
  }

  void onDeleteTap(Favourites favourite) {
    _favouritesService.deleteFavourite(favourite);
    _getFavourites();
  }

  void onShareTap(BuildContext context, Favourites favourite) {
    Share.share("""
"${favourite.content}"

${S.of(context).shareText(kAppUrl)}
""");
  }

  
}
