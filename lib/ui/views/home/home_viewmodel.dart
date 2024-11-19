import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/app/base.dart';
import 'package:pretty_affirmations/models/affirmation.dart';
import 'package:pretty_affirmations/services/api_service.dart';
import 'package:pretty_affirmations/services/settings_service.dart';

class HomeViewModel extends BaseViewModel {
  final _apiService = getIt.get<ApiService>();
  final _settingsService = getIt.get<SettingsService>();

  late final Affirmations _affirmations;
  Affirmations get affirmations => _affirmations;

  late final String _localeStr;
  bool _isLoading = false;
  bool _hasReachedEnd = false;

  void init(BuildContext context) {
    final appBase = context.read<AppBase>();
    _localeStr = appBase.localeStr;
    _affirmations = appBase.affirmations;
  }

  Future<void> _getAffirmations({int page = 0}) async {
    if (_isLoading) return;

    _isLoading = true;
    final affirmations =
        await _apiService.getAffirmations(locale: _localeStr, page: page);

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
    _pageController?.animateToPage(
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
    _settingsService.setLastReadAffirmationId(currentAffirmation.id);
  }

  PageController? _pageController;
  void setPageController(PageController controller) {
    _pageController = controller;
  }

  @override
  void dispose() {
    _pageController = null;
    super.dispose();
  }
}
