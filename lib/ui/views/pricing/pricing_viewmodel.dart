import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/services/revenue_cat_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PricingViewModel extends BaseViewModel {
  List<Package> get activePackages => RevenueCatService().getActivePackages();

  String getFormattedPrice(Package package) {
    return RevenueCatService().getFormattedPrice(package);
  }
}
