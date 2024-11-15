import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/common/extensions/string_extensions.dart';
import 'package:pretty_affirmations/services/settings_service.dart';
import 'package:pretty_affirmations/ui/views/home/colors.dart';

class AppBase extends BaseTheme {
  Locale? locale = getIt<SettingsService>().currentLocale;

  String get localeStr => locale.toLocaleStr();

  void changeLocale(Locale locale) async {
    this.locale = locale;
    await getIt<SettingsService>().changeLocale(locale);
    notifyListeners();
  }

  List<Color> get homeColors => HomeViewColors.colors;

  final _colorPrimary = const Color(0xFF495363).withOpacity(.10);
  final _colorPrimaryFixed = const Color(0xFFadafb2);
  final _colorSecondary = const Color(0xFFadafb2);
  final _colorTertiary = const Color(0XFFf9eaea);
  final _colorOnSurface = const Color(0xFF495363);
  final _colorSurface = Colors.white;

  @override
  ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: _colorSurface,
        fontFamily: "Calibri",
        colorScheme: ColorScheme.light(
          primary: _colorPrimary,
          primaryFixed: _colorPrimaryFixed,
          secondary: _colorSecondary,
          tertiary: _colorTertiary,
          onSurface: _colorOnSurface,
          surface: _colorSurface,
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: _colorOnSurface),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(foregroundColor: _colorSecondary),
        ),
        iconTheme: IconThemeData(color: _colorSecondary),
        dividerTheme: DividerThemeData(color: _colorPrimary, thickness: 0.5),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _colorTertiary,
            foregroundColor: _colorOnSurface,
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
}
