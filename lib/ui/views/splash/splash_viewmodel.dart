import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/app/router.dart';
import 'package:pretty_affirmations/app/base.dart';
import 'package:pretty_affirmations/models/affirmation.dart';
import 'package:pretty_affirmations/services/api_service.dart';

class SplashViewmodel extends BaseViewModel {
  final _apiService = getIt.get<ApiService>();

  void init(BuildContext context) {
    Future.wait([
      _getAffirmations(context),
      Future.delayed(const Duration(milliseconds: 1500)),
    ]).then((results) {
      if (context.mounted) {
        final data = results[0] as Affirmations;
        context.go(AppRouter.homeRoute);
        context.read<AppBase>().affirmations = data;
      }
    });
  }

  Future<Affirmations> _getAffirmations(BuildContext context) async {
    final locale = context.read<AppBase>().localeStr;
    final affirmations = await _apiService.getAffirmations(locale: locale);
    _apiService.dailyEntry(locale);
    return affirmations!;
  }
}
