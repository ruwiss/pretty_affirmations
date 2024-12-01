import 'dart:async';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pretty_affirmations/app/locator.dart';
import 'package:pretty_affirmations/app/router.dart';
import 'package:pretty_affirmations/app/base.dart';
import 'app/notification.dart';
import 'generated/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await setupLocator(registerDependencies);
  await NotificationController.initializeLocalNotifications();
  await NotificationController.notificationPermission();
  unawaited(MobileAds.instance.initialize());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppBase(),
      child: Consumer<AppBase>(
        builder: (context, value, child) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter.router,
            theme: value.lightTheme,
            locale: value.locale,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: child!,
              );
            },
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
          );
        },
      ),
    );
  }
}
