import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/app/router.dart';

class SplashViewmodel extends BaseViewModel {
  void init(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) context.go(AppRouter.homeRoute);
    });
  }
}
