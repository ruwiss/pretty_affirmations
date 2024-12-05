import 'package:flutter/widgets.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/generated/l10n.dart';
import 'package:pretty_affirmations/services/ad_service.dart';
import 'package:pretty_affirmations/services/revenue_cat_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PricingViewModel extends BaseViewModel {
  bool get isProUser => RevenueCatService().isProUser;
  List<Package> get activePackages => RevenueCatService().getActivePackages();
  Package? _currentPackage;
  Package? get currentPackage => _currentPackage;

  CustomerInfo? _customerInfo;
  CustomerInfo? get customerInfo => _customerInfo;

  String getFormattedPrice(Package package) =>
      RevenueCatService().getFormattedPrice(package);

  bool isPurchased(Package package) =>
      RevenueCatService().isPackagePurchased(package);

  PricingViewModel() {
    _getPurchasedPackage();
    _getCustomerInfo();
  }
  void _getPurchasedPackage() {
    _currentPackage = RevenueCatService().getPurchasedPackage();
  }

  void _getCustomerInfo() {
    _customerInfo = RevenueCatService().customerInfo;
  }

  void onPlanSelected(BuildContext context, Package package) {
    if (isProUser) {
      toastification.show(
        context: context,
        type: ToastificationType.info,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 5),
        title: Text(S.of(context).alreadyProUser),
      );
      return;
    }
    RevenueCatService().purchasePackage(
      package,
      callbacks: RevenueCatCallbacks(
        onCustomerInfoUpdated: (info) {
          _getCustomerInfo();
          _getPurchasedPackage();
          notifyListeners();

          if (isProUser) {
            AdService().disableAds();
            toastification.show(
              context: context,
              type: ToastificationType.success,
              style: ToastificationStyle.flat,
              autoCloseDuration: const Duration(seconds: 5),
              title: Text(S.of(context).purchaseSuccess),
            );
          }
        },
      ),
    );
  }

  void restorePurchases(BuildContext context) {
    RevenueCatService().restorePurchases(
      callbacks: RevenueCatCallbacks(
        onError: (err) => setError(err),
        onCustomerInfoUpdated: (info) {
          _customerInfo = info;
          _getPurchasedPackage();
          notifyListeners();
        },
      ),
    );
  }
}
