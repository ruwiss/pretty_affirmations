import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/app/base.dart';
import 'package:pretty_affirmations/app/notification.dart';
import 'package:pretty_affirmations/common/common.dart';
import 'package:pretty_affirmations/generated/l10n.dart';
import 'package:pretty_affirmations/models/affirmation.dart';
import 'package:pretty_affirmations/models/favourites/favourites.dart';
import 'package:pretty_affirmations/models/menu_item.dart';
import 'package:pretty_affirmations/services/ad_service.dart';
import 'package:pretty_affirmations/services/api_service.dart';
import 'package:pretty_affirmations/services/favourites_service.dart';
import 'package:pretty_affirmations/services/schedule_service.dart';
import 'package:pretty_affirmations/services/settings_service.dart';
import 'package:share_plus/share_plus.dart';

class HomeViewModel extends BaseViewModel {
  final MenuItem? affirmationCategory;
  final BuildContext context;
  HomeViewModel(this.context, this.affirmationCategory) {
    _init(context);
    runBusyFuture(_getAffirmations());
  }

  final _apiService = getIt.get<ApiService>();
  final _settingsService = getIt.get<SettingsService>();
  final _favouritesService = getIt.get<FavouritesService>();
  final _scheduleService = getIt.get<ScheduleService>();
  final _adService = AdService();

  // Reklam gösterilen indexleri tutmak için set
  final Set<int> _shownAdIndexes = {};
  // Çekilen sayfaları tutmak için yeni set
  final Set<int> _loadedIndex = {0};

  final PageController _pageController = PageController();
  PageController get pageController => _pageController;

  Affirmations? _affirmations;
  Affirmations get affirmations => _affirmations!;

  late final String _localeStr;
  bool _isLoading = false;
  bool _hasReachedEnd = false;

  List<Favourites> _favourites = [];

  void _init(BuildContext context) {
    final appBase = context.read<AppBase>();
    _localeStr = appBase.localeStr;
    _affirmations = appBase.affirmations;
    _favourites = _favouritesService.getFavourites();
    _scheduleService.checkAndScheduleAffirmations();
    _adService.loadInterstitialAd(key: "home");
  }

  void _clearAffirmations() {
    _affirmations?.data.clear();
    _affirmations?.total = 0;
  }

  Future<void> _getAffirmations({int page = 0}) async {
    if (_isLoading) return;
    if (page == 0) {
      _clearAffirmations();
      _loadedIndex
        ..clear()
        ..add(0);
    }

    _isLoading = true;
    final affirmations = await _apiService.getAffirmations(
      locale: _localeStr,
      page: page,
      categoryFilter: affirmationCategory,
      startFromLastRead: page == 0,
    );

    if (affirmations == null) {
      _hasReachedEnd = true;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _affirmations!
      ..data.addAll(affirmations.data)
      ..page = affirmations.page
      ..total = _affirmations!.total + affirmations.total;

    _isLoading = false;
    notifyListeners();
  }

  bool showGoToFirstPageButton(index) =>
      _hasReachedEnd && index >= _affirmations!.data.length - 1;

  void goToFirstPage() {
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void onPageIndexChanged(int index) async {
    if (_loadedIndex.contains(index)) return;
    if (!_hasReachedEnd && index % 5 == 0) {
      await _getAffirmations(page: _affirmations!.page + 1);
      _loadedIndex.add(index);
    }

    // Her [kAffirmationScrollCountForAd] katı kaydırmada geçiş reklamı göster
    if (index > 0 &&
        index % kAffirmationScrollCountForAd == 0 &&
        !_shownAdIndexes.contains(index)) {
      _adService.showInterstitialAd(key: "home");
      _shownAdIndexes.add(index);
    }

    final currentAffirmation = _affirmations!.data[index];
    _settingsService.setLastReadAffirmationId(
      currentAffirmation.id,
      categoryKey: affirmationCategory?.categoryKey,
    );
  }

  void toggleFavourite(Affirmation affirmation) {
    _favourites = _favouritesService.toggleFavourite(affirmation);
    notifyListeners();
  }

  bool isFavourite(Affirmation affirmation) =>
      _favourites.any((favourite) => favourite.id == affirmation.id);

  void onShareTap(BuildContext context, Affirmation affirmation) {
    Share.share("""
"${affirmation.content}"

${S.of(context).shareText(kAppUrl)}
""");
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
