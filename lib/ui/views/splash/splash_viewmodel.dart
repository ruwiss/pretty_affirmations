import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/app/notification.dart';
import 'package:pretty_affirmations/app/router.dart';
import 'package:pretty_affirmations/app/base.dart';
import 'package:pretty_affirmations/models/affirmation.dart';
import 'package:pretty_affirmations/services/api_service.dart';
import 'package:pretty_affirmations/services/schedule_service.dart';
import 'package:pretty_affirmations/services/settings_service.dart';

class SplashViewmodel extends BaseViewModel {
  final _apiService = getIt.get<ApiService>();
  final _scheduleService = getIt.get<ScheduleService>();

  void init(BuildContext context) {
    _setupNotifications();
    Future.wait([
      // olumlamaları al (senkron)
      _getAffirmations(context),
      // en az 1,5 saniye beklet
      Future.delayed(const Duration(milliseconds: 1500)),
    ]).then((results) {
      if (context.mounted) {
        final data = results[0] as Affirmations;
        context.go(AppRouter.homeRoute);

        final appBase = context.read<AppBase>();
        if (appBase.affirmationsLoaded) return;
        appBase.affirmations = data;
        appBase.affirmationsLoaded = true;
      }
    });

    "Reklamlar Etkin: ${getIt<SettingsService>().getAdsEnabled()}".log();
  }

  Future<Affirmations> _getAffirmations(BuildContext context) async {
    // cihaz dilini al
    final locale = context.read<AppBase>().localeStr;
    // olumlamaları getir
    final affirmations = await _apiService.getAffirmations(
        locale: locale, startFromLastRead: true);
    // günlük girişi kaydet
    _apiService.dailyEntry(locale);
    return affirmations!;
  }

  void _setupNotifications() {
    NotificationController.initializeLocalNotifications().then((_) {
      //NotificationController.scheduleTestNotification();
      _scheduleService.checkAndScheduleAffirmations();
    });
  }
}
