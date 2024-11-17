import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/app/router.dart';
import 'package:pretty_affirmations/app/base.dart';
import 'package:pretty_affirmations/models/affirmation.dart';
import 'package:pretty_affirmations/services/api_service.dart';

class SplashViewmodel extends BaseViewModel {
  final _apiService = getIt.get<ApiService>();

  void init(BuildContext context) {
    _getAffirmations(context).then((data) {
      if (context.mounted) {
        context.go(AppRouter.homeRoute);
        context.read<AppBase>().affirmations = data;
      }
    });
  }

  Future<Affirmations> _getAffirmations(BuildContext context) async {
    final locale = context.read<AppBase>().localeStr;
    final affirmations = await _apiService.getAffirmations(locale: locale);
    return affirmations!;
  }
}
