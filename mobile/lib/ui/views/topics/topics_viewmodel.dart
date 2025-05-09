import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/app/base.dart';
import 'package:pretty_affirmations/common/extensions/string_extensions.dart';
import 'package:pretty_affirmations/models/menu_item.dart';
import 'package:pretty_affirmations/services/api_service.dart';
import 'package:pretty_affirmations/services/settings_service.dart';

class TopicsViewmodel extends BaseViewModel {
  final _apiService = getIt<ApiService>();
  final _settingsService = getIt<SettingsService>();
  List<MenuItem> _menuItems = [];

  List<MenuItem> get menuItems => _menuItems;

  void init(BuildContext context) {
    final locale = context.read<AppBase>().localeStr;
    runBusyFuture(_getTopics(locale));
    _listenLocale();
  }

  late StreamSubscription<Locale> _localeSubscription;
  void _listenLocale() {
    _localeSubscription = _settingsService.localeStream.listen((locale) {
      runBusyFuture(_getTopics(locale.toLocaleStr()));
    });
  }

  Future<void> _getTopics(String locale) async {
    _menuItems = await _apiService.getCategories(locale);
  }

  @override
  void dispose() {
    _localeSubscription.cancel();
    super.dispose();
  }
}
