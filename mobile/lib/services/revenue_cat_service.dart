import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat servis durumlarını takip etmek için enum
enum RevenueCatStatus {
  initial,
  initializing,
  ready,
  error,
}

/// RevenueCat hata tiplerini tanımlamak için enum
enum RevenueCatErrorType {
  initialization,
  purchase,
  restore,
  offering,
  subscription,
  unknown,
}

/// Paket durumlarını takip etmek için enum
enum PackageType { monthly, annual, lifetime, custom }

/// RevenueCat hata sınıfı
class RevenueCatError {
  final RevenueCatErrorType type;
  final String message;
  final dynamic originalError;

  RevenueCatError({
    required this.type,
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'RevenueCatError(type: $type, message: $message)';
}

/// RevenueCat konfigürasyon modeli
class RevenueCatConfig {
  final String apiKey;
  final List<String> entitlementIds;
  final bool debugLogsEnabled;

  const RevenueCatConfig({
    required this.apiKey,
    required this.entitlementIds,
    this.debugLogsEnabled = false,
  });
}

/// RevenueCat callback'leri için model
class RevenueCatCallbacks {
  final Function(CustomerInfo)? onCustomerInfoUpdated;
  final Function(RevenueCatError)? onError;
  final Function(Offerings)? onOfferingsUpdated;

  const RevenueCatCallbacks({
    this.onCustomerInfoUpdated,
    this.onError,
    this.onOfferingsUpdated,
  });
}

/// RevenueCat servisi
/// Bu servis, RevenueCat'in tüm özelliklerini yönetir
class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  late final RevenueCatConfig _config;
  RevenueCatStatus _status = RevenueCatStatus.initial;
  CustomerInfo? _customerInfo;
  Offerings? _offerings;
  Function(CustomerInfo)? _customerInfoSubscription;
  final _purchaseController = StreamController<bool>.broadcast();

  /// Getter'lar
  RevenueCatStatus get status => _status;
  CustomerInfo? get customerInfo => _customerInfo;
  Offerings? get offerings => _offerings;
  Stream<bool> get purchaseStream => _purchaseController.stream;
  bool get isProUser => _customerInfo?.activeSubscriptions.isNotEmpty ?? false;

  /// Servisin hazır olup olmadığını kontrol eder
  bool get isReady => _status == RevenueCatStatus.ready;

  /// Satın alma işlemi öncesi kontroller
  Future<bool> canMakePurchases() async {
    if (!isReady) return false;
    try {
      return await Purchases.canMakePayments();
    } catch (e) {
      _logDebug('Satın alma kontrolü başarısız: $e');
      return false;
    }
  }

  /// Servisi başlatır
  Future<void> initialize({
    required RevenueCatConfig config,
    RevenueCatCallbacks? callbacks,
  }) async {
    if (_status == RevenueCatStatus.initializing ||
        _status == RevenueCatStatus.ready) {
      return;
    }

    try {
      _status = RevenueCatStatus.initializing;
      _config = config;

      // RevenueCat konfigürasyonu
      await Purchases.setLogLevel(
        config.debugLogsEnabled ? LogLevel.debug : LogLevel.info,
      );

      await Purchases.configure(
        PurchasesConfiguration(config.apiKey),
      );

      // Listener'ı StreamSubscription olarak sakla
      _customerInfoSubscription = (customerInfo) {
        _customerInfo = customerInfo;
        _handleEntitlementChange(
            customerInfo, callbacks?.onCustomerInfoUpdated);
      };
      Purchases.addCustomerInfoUpdateListener(_customerInfoSubscription!);

      // İlk customer bilgilerini al
      _customerInfo = await Purchases.getCustomerInfo();

      // Mevcut ürünleri al
      await _fetchOfferings(callbacks?.onOfferingsUpdated);

      _status = RevenueCatStatus.ready;
      _logDebug('RevenueCat başarıyla başlatıldı');
    } catch (e) {
      _status = RevenueCatStatus.error;
      final error = RevenueCatError(
        type: RevenueCatErrorType.initialization,
        message: 'RevenueCat başlatılırken hata: $e',
        originalError: e,
      );
      _handleError(error, callbacks?.onError);
    }
  }

  /// Ürünleri getirir
  Future<void> _fetchOfferings([Function(Offerings)? onOfferings]) async {
    try {
      final offerings = await Purchases.getOfferings();
      _offerings = offerings;
      onOfferings?.call(offerings);
      _logDebug(
          'Ürünler başarıyla getirildi: ${offerings.current?.identifier}');
    } catch (e) {
      final error = RevenueCatError(
        type: RevenueCatErrorType.offering,
        message: 'Ürünler getirilirken hata: $e',
        originalError: e,
      );
      throw error;
    }
  }

  /// Ürün satın alma işlemini gerçekleştirir
  Future<void> purchasePackage(
    Package package, {
    RevenueCatCallbacks? callbacks,
  }) async {
    try {
      _logDebug('Satın alma başlatıldı: ${package.identifier}');

      // CustomerInfo direkt olarak dönüyor artık
      _customerInfo = await Purchases.purchasePackage(package);

      _handleEntitlementChange(
        _customerInfo!,
        callbacks?.onCustomerInfoUpdated,
      );

      _logDebug('Satın alma başarılı: ${package.identifier}');
    } catch (e) {
      final error = RevenueCatError(
        type: RevenueCatErrorType.purchase,
        message: 'Satın alma işlemi başarısız: $e',
        originalError: e,
      );
      _handleError(error, callbacks?.onError);
      rethrow;
    }
  }

  /// Kullanıcının satın aldığı paketi getirir
  Package? getPurchasedPackage() {
    // Aktif yetkileri al
    final activeEntitlements = getActiveEntitlements();
    if (activeEntitlements.isEmpty) return null;

    // Aktif yetkilerden birini kullanarak paketi bul
    for (final entitlement in activeEntitlements) {
      final package = getPackageByIdentifier(entitlement.productIdentifier);
      if (package != null) {
        return package;
      }
    }

    return null;
  }

  /// Satın almaları geri yükler
  Future<void> restorePurchases({
    RevenueCatCallbacks? callbacks,
  }) async {
    try {
      _logDebug('Satın almalar geri yükleniyor');

      final customerInfo = await Purchases.restorePurchases();
      _customerInfo = customerInfo;

      _handleEntitlementChange(
        customerInfo,
        callbacks?.onCustomerInfoUpdated,
      );

      _logDebug('Satın almalar başarıyla geri yüklendi');
    } catch (e) {
      final error = RevenueCatError(
        type: RevenueCatErrorType.restore,
        message: 'Satın almalar geri yüklenirken hata: $e',
        originalError: e,
      );
      _handleError(error, callbacks?.onError);
      rethrow;
    }
  }

  /// Kullanıcı kimliğini ayarlar
  Future<void> loginUser(
    String userId, {
    RevenueCatCallbacks? callbacks,
  }) async {
    try {
      await Purchases.logIn(userId);
      _customerInfo = await Purchases.getCustomerInfo();
      _logDebug('Kullanıcı kimliği ayarlandı: $userId');
    } catch (e) {
      final error = RevenueCatError(
        type: RevenueCatErrorType.unknown,
        message: 'Kullanıcı kimliği ayarlanırken hata: $e',
        originalError: e,
      );
      _handleError(error, callbacks?.onError);
      rethrow;
    }
  }

  /// Kullanıcı oturumunu kapatır
  Future<void> logoutUser({RevenueCatCallbacks? callbacks}) async {
    try {
      await Purchases.logOut();
      _customerInfo = await Purchases.getCustomerInfo();
      _logDebug('Kullanıcı oturumu kapatıldı');
    } catch (e) {
      final error = RevenueCatError(
        type: RevenueCatErrorType.unknown,
        message: 'Oturum kapatılırken hata: $e',
        originalError: e,
      );
      _handleError(error, callbacks?.onError);
      rethrow;
    }
  }

  /// Abonelik durumunu kontrol eder
  Future<void> checkSubscriptionStatus({
    RevenueCatCallbacks? callbacks,
  }) async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _customerInfo = customerInfo;
      _handleEntitlementChange(customerInfo, callbacks?.onCustomerInfoUpdated);
    } catch (e) {
      final error = RevenueCatError(
        type: RevenueCatErrorType.subscription,
        message: 'Abonelik durumu kontrol edilirken hata: $e',
        originalError: e,
      );
      _handleError(error, callbacks?.onError);
      rethrow;
    }
  }

  /// Yetki değişikliklerini işler
  void _handleEntitlementChange(
    CustomerInfo customerInfo,
    Function(CustomerInfo)? onCustomerInfoUpdated,
  ) {
    final hasAnyEntitlement = _config.entitlementIds.any(
      (id) => customerInfo.entitlements.active[id] != null,
    );
    _purchaseController.add(hasAnyEntitlement);
    onCustomerInfoUpdated?.call(customerInfo);
    _logDebug('Yetki durumu güncellendi: $hasAnyEntitlement');
  }

  /// Hataları işler
  void _handleError(RevenueCatError error, Function(RevenueCatError)? onError) {
    _logDebug('Hata oluştu: ${error.toString()}');
    onError?.call(error);
  }

  /// Debug logları
  void _logDebug(String message) {
    if (_config.debugLogsEnabled) {
      debugPrint('RevenueCat: $message');
    }
  }

  /// Servisi temizler
  void dispose() {
    if (_customerInfoSubscription != null) {
      Purchases.removeCustomerInfoUpdateListener(_customerInfoSubscription!);
    }
    _purchaseController.close();
  }

  /// Aktif paketleri getirir
  List<Package> getActivePackages() {
    return _offerings?.current?.availablePackages ?? [];
  }

  /// Belirli bir paketi ID'ye göre getirir
  Package? getPackageByIdentifier(String identifier) {
    identifier.log();
    try {
      return _offerings?.current?.availablePackages.firstWhere(
        (package) => package.storeProduct.identifier.contains(identifier),
      );
    } catch (e) {
      _logDebug('Paket bulunamadı: $identifier');
      return null;
    }
  }

  /// Aylık paketi getirir
  Package? getMonthlyPackage() {
    return _offerings?.current?.monthly;
  }

  /// Yıllık paketi getirir
  Package? getAnnualPackage() {
    return _offerings?.current?.annual;
  }

  /// Lifetime paketi getirir
  Package? getLifetimePackage() {
    return _offerings?.current?.lifetime;
  }

  /// Özel bir offering'i getirir
  Offering? getOffering(String identifier) {
    return _offerings?.getOffering(identifier);
  }

  /// Tüm aktif yetkileri getirir
  List<EntitlementInfo> getActiveEntitlements() {
    return _customerInfo?.entitlements.active.values.toList() ?? [];
  }

  /// Belirli bir yetkinin aktif olup olmadığını kontrol eder
  bool hasActiveEntitlement(String entitlementId) {
    return _customerInfo?.entitlements.active[entitlementId] != null;
  }

  /// Belirli tipteki paketi getirir
  Package? getPackageByType(PackageType type) {
    return switch (type) {
      PackageType.monthly => _offerings?.current?.monthly,
      PackageType.annual => _offerings?.current?.annual,
      PackageType.lifetime => _offerings?.current?.lifetime,
      PackageType.custom => null,
    };
  }

  /// Paket fiyatını formatlar
  String getFormattedPrice(Package package) {
    return package.storeProduct.priceString
        .replaceAll("TRY", "₺")
        .replaceAll("USD", "\$")
        .replaceAll(" ", "");
  }

  /// Paket süresini getirir
  String getPackageDuration(Package package) {
    final identifier = package.identifier.toLowerCase();
    if (identifier.contains('month')) return 'Monthly';
    if (identifier.contains('year')) return 'Yearly';
    if (identifier.contains('lifetime')) return 'Lifetime';
    return '';
  }

  /// Belirli bir entitlement için abonelik bitiş tarihini getirir
  DateTime? getSubscriptionExpiryDate(String entitlementId) {
    final dateStr =
        _customerInfo?.entitlements.active[entitlementId]?.expirationDate;
    return dateStr != null ? DateTime.parse(dateStr) : null;
  }

  /// Belirli bir entitlement için otomatik yenileme durumunu getirir
  bool isAutoRenewEnabled(String entitlementId) {
    return _customerInfo?.entitlements.active[entitlementId]?.willRenew ??
        false;
  }

  /// Belirli bir entitlement için deneme süresinde olup olmadığını kontrol eder
  bool isInTrialPeriod(String entitlementId) {
    return _customerInfo?.entitlements.active[entitlementId]?.periodType ==
        PeriodType.trial;
  }

  /// Özel özellik takibi için
  Future<void> setAttributes(Map<String, String> attributes) async {
    try {
      for (final entry in attributes.entries) {
        await Purchases.setAttributes({entry.key: entry.value});
      }
    } catch (e) {
      _logDebug('Özellik ayarlama başarısız: $e');
    }
  }

  /// Belirli bir paketin satın alınıp alınmadığını kontrol eder
  bool isPackagePurchased(Package package) {
    // Aktif yetkileri al
    final activeEntitlements = getActiveEntitlements();
    if (activeEntitlements.isEmpty) return false;

    // Paket ID'sini kontrol et
    final packageIdentifier = package.storeProduct.defaultOption?.id;

    // Aktif yetkiler içinde bu pakete ait bir yetki var mı kontrol et
    return activeEntitlements.any((entitlement) {
      // Paket ID'si ile yetki ID'si eşleşiyorsa veya
      // yetki ID'si config'de tanımlı yetkilerden biriyse true döner
      entitlement.productPlanIdentifier.log();
      return entitlement.productPlanIdentifier == packageIdentifier ||
          _config.entitlementIds.contains(entitlement.identifier);
    });
  }
}
