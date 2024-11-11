import 'package:flutter/material.dart';
import 'package:pretty_affirmations/common/common.dart';

enum AppLanguage {
  en("English", "en", null, AppVectors.flagEN),
  zh("中文", "zh", null, AppVectors.flagCN),
  ru("Русский", "ru", null, AppVectors.flagRU),
  tr("Türkçe", "tr", "TR", AppVectors.flagTR);

  final String name;
  final String languageCode;
  final String? countryCode;
  final String svg;

  Locale get getLocale => Locale(languageCode, countryCode);

  const AppLanguage(this.name, this.languageCode, this.countryCode, this.svg);
}
