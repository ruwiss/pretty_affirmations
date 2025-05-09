import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension LocaleToString on Locale? {
  String toLocaleStr() {
    if (this == null) return Intl.getCurrentLocale();
    if (this!.countryCode == null) return this!.languageCode;
    return "${this?.languageCode}_${this!.countryCode}";
  }
}
