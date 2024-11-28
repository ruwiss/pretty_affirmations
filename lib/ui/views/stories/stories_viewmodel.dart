import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/app/base.dart';
import 'package:pretty_affirmations/common/common.dart';
import 'package:pretty_affirmations/common/extensions/string_extensions.dart';
import 'package:pretty_affirmations/models/story.dart';
import 'package:pretty_affirmations/services/ad_service.dart';
import 'package:pretty_affirmations/services/api_service.dart';
import 'package:pretty_affirmations/services/settings_service.dart';

class StoriesViewmodel extends BaseViewModel {
  final _apiService = getIt.get<ApiService>();
  final _settingsService = getIt.get<SettingsService>();
  final adService = AdService();

  Story? _story;
  Story get story => _story!;

  void init(BuildContext context) async {
    adService.loadBannerAd(
      key: 'stories',
      adUnitId: kStoryBannerAdId,
      callbacks: AdCallbacks(onAdLoaded: () => notifyListeners()),
    );
    final locale = context.read<AppBase>().localeStr;
    runBusyFuture(_getDailyStory(locale));
    _listenLocale();
  }

  Future<void> _getDailyStory(String locale) async {
    _story = await _apiService.getDailyStory(locale);
  }

  late StreamSubscription<Locale> _localeSubscription;
  void _listenLocale() {
    _localeSubscription = _settingsService.localeStream.listen((locale) {
      runBusyFuture(_getDailyStory(locale.toLocaleStr()));
    });
  }

  @override
  void dispose() {
    _localeSubscription.cancel();
    super.dispose();
  }
}
