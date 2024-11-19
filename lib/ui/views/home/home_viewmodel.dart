import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/app/base.dart';
import 'package:pretty_affirmations/models/affirmation.dart';
import 'package:pretty_affirmations/models/menu_item.dart';
import 'package:pretty_affirmations/services/api_service.dart';
import 'package:pretty_affirmations/services/settings_service.dart';

class HomeViewModel extends BaseViewModel {
  final MenuItem? affirmationCategory;
  final BuildContext context;
  HomeViewModel(this.context, this.affirmationCategory) {
    _init(context);
    if (affirmationCategory != null) {
      runBusyFuture(_getAffirmations());
    }
  }

  final _apiService = getIt.get<ApiService>();
  final _settingsService = getIt.get<SettingsService>();

  final PageController _pageController = PageController();
  PageController get pageController => _pageController;

  late final Affirmations _affirmations;
  Affirmations get affirmations => _affirmations;

  late final String _localeStr;
  bool _isLoading = false;
  bool _hasReachedEnd = false;

  void _init(BuildContext context) {
    final appBase = context.read<AppBase>();
    _localeStr = appBase.localeStr;
    _affirmations = appBase.affirmations;
  }

  void _clearAffirmations() {
    _affirmations.data.clear();
    _affirmations.total = 0;
  }

  Future<void> _getAffirmations({int page = 0}) async {
    if (_isLoading) return;
    if (page == 0) _clearAffirmations();

    _isLoading = true;
    final affirmations = await _apiService.getAffirmations(
      locale: _localeStr,
      page: page,
      categoryFilter: affirmationCategory?.id,
    );

    if (affirmations == null) {
      _hasReachedEnd = true;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _affirmations
      ..data.addAll(affirmations.data)
      ..page = affirmations.page
      ..total = _affirmations.total + affirmations.total;

    _isLoading = false;
    notifyListeners();
  }

  bool showGoToFirstPageButton(index) =>
      _hasReachedEnd && index >= _affirmations.data.length - 1;

  void goToFirstPage() {
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void onPageIndexChanged(int index) async {
    if (!_hasReachedEnd && index >= _affirmations.data.length - 2) {
      await _getAffirmations(page: _affirmations.page + 1);
    }
    final currentAffirmation = _affirmations.data[index];
    _settingsService.setLastReadAffirmationId(
      currentAffirmation.id,
      categoryKey: affirmationCategory?.categoryKey,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
