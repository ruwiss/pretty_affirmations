import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';

class AppTheme extends BaseTheme {
  @override
  ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: "Calibri",
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF495363).withOpacity(.10),
          secondary: const Color(0xFFadafb2),
          tertiary: const Color(0XFFf9eaea),
          onSurface: const Color(0xFF495363),
          surface: Colors.white,
          primaryFixed: const Color(0xFFadafb2),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF495363)),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(foregroundColor: const Color(0xFFadafb2)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFadafb2)),
      );
}
