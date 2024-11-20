import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';

extension GoRouterExtension on GoRouter {
  void popUntilPath(String ancestorPath) {
    while (routerDelegate.currentConfiguration.matches.last.matchedLocation !=
        ancestorPath) {
      if (!canPop()) {
        return;
      }
      pop();
    }
  }
}

extension ResponsiveValue on BuildContext {
  double responsive(num value) {
    final width = MediaQuery.of(this).size.width;
    final height = MediaQuery.of(this).size.height;
    final shortestSide = MediaQuery.of(this).size.shortestSide;

    // Referans ekran boyutu (örn: iPhone 12)
    const baseWidth = 390.0;
    const baseHeight = 844.0;

    // Ekran boyutuna göre ölçekleme faktörü
    final widthFactor = width / baseWidth;
    final heightFactor = height / baseHeight;

    // Cihaz tipine göre ölçekleme
    double scaleFactor;
    if (shortestSide < 600) {
      // Telefon
      scaleFactor = (widthFactor + heightFactor) / 2;
    } else {
      // Tablet
      scaleFactor = ((widthFactor + heightFactor) / 2) * 0.8;
    }

    // Minimum ve maksimum ölçekleme sınırları
    scaleFactor = scaleFactor.clamp(0.8, 1.4);

    return value * scaleFactor;
  }
}
