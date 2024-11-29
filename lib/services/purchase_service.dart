import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

/// in_app_purchase eklentisini kullanan satın alma işlemlerini yöneten servis sınıfı.
///
/// Bu singleton sınıf şunları yönetir:
/// * Mağazadan (App Store / Play Store) ürün sorgulama
/// * Satın alma işlemlerini işleme ve doğrulama
/// * Satın almaları geri yükleme
/// * Satın alma durumu takibi
///
/// Kullanım örneği:
/// ```dart
/// final purchaseService = PurchaseService();
/// await purchaseService.initialize(
///   productIds: ['product_1', 'product_2'],
///   onError: (message) => print(message),
/// );
/// ```
class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final StreamController<List<PurchaseDetails>> _purchaseController =
      StreamController<List<PurchaseDetails>>.broadcast();
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final List<ProductDetails> _products = [];
  final List<PurchaseDetails> _purchases = [];
  bool _isAvailable = false;

  Stream<List<PurchaseDetails>> get purchaseStream =>
      _purchaseController.stream;
  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => List.unmodifiable(_products);
  List<PurchaseDetails> get purchases => List.unmodifiable(_purchases);

  /// Satın alma servisini başlatır ve gerekli stream'leri ve dinleyicileri ayarlar.
  ///
  /// Parametreler:
  /// * [productIds]: Mağazadan sorgulanacak ürün kimlikleri listesi
  /// * [onError]: İsteğe bağlı hata işleme geri çağrısı
  /// * [onPurchasesUpdated]: Satın almalar güncellendiğinde tetiklenecek isteğe bağlı geri çağrı
  ///
  /// Fırlatılan Hatalar:
  /// * Mağaza kullanılamıyorsa Exception
  /// * Ürün sorgusu başarısız olursa Exception
  Future<void> initialize({
    required List<String> productIds,
    Function(String message)? onError,
    Function(List<PurchaseDetails>)? onPurchasesUpdated,
  }) async {
    try {
      _isAvailable = await _inAppPurchase.isAvailable();
      if (!_isAvailable) {
        onError?.call('Mağaza kullanılamıyor');
        return;
      }

      await _getProducts(productIds, onError);
      _setupPurchaseStream(onPurchasesUpdated);
    } catch (e) {
      onError?.call('Satın alma servisi başlatılırken hata oluştu: $e');
    }
  }

  /// Verilen ürün kimlikleri için mağazadan ürün detaylarını sorgular.
  ///
  /// Parametreler:
  /// * [productIds]: Sorgulanacak ürün kimlikleri listesi
  /// * [onError]: İsteğe bağlı hata işleme geri çağrısı
  ///
  /// Not: Ürünler başarılı sorgu sonrasında [_products] listesinde saklanır
  Future<void> _getProducts(
    List<String> productIds,
    Function(String message)? onError,
  ) async {
    try {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(productIds.toSet());

      if (response.error != null) {
        onError?.call('Ürünler yüklenirken hata oluştu: ${response.error}');
        return;
      }

      if (response.productDetails.isEmpty) {
        onError?.call('Ürün bulunamadı');
        return;
      }

      _products
        ..clear()
        ..addAll(response.productDetails);
    } catch (e) {
      onError?.call('Ürünler yüklenirken hata oluştu: $e');
    }
  }

  /// Satın alma stream'ini satın alma güncellemelerini işleyecek şekilde ayarlar
  void _setupPurchaseStream(
      [Function(List<PurchaseDetails>)? onPurchasesUpdated]) {
    _subscription?.cancel();
    _subscription = _inAppPurchase.purchaseStream.listen(
      (List<PurchaseDetails> purchases) {
        _handlePurchaseUpdates(purchases, onPurchasesUpdated);
      },
      onError: (error) {
        _purchaseController.addError(error);
      },
    );
  }

  /// Satın alma güncellemelerini işler
  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchases,
    Function(List<PurchaseDetails>)? onPurchasesUpdated,
  ) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.error) {
        _purchaseController.addError(purchase.error!);
      } else if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        if (await _verifyPurchase(purchase)) {
          await _deliverProduct(purchase);
          if (!_purchases.any((p) => p.productID == purchase.productID)) {
            _purchases.add(purchase);
          }
        } else {
          _purchaseController.addError(Exception('Geçersiz satın alma'));
        }
      }

      if (purchase.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchase);
      }
    }

    onPurchasesUpdated?.call(_purchases);
    _purchaseController.add(purchases);
  }

  /// Satın almayı doğrular (kendi doğrulama mantığınızı uygulayın)
  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    // Satın alma doğrulama mantığınızı burada uygulayın
    // Bu, sunucu tarafında doğrulama içerebilir
    return true;
  }

  /// Satın alınan ürünü teslim eder
  Future<void> _deliverProduct(PurchaseDetails purchase) async {
    // Ürün teslimat mantığınızı burada uygulayın
  }

  /// Belirtilen ürün için satın alma işlemini başlatır.
  ///
  /// Parametreler:
  /// * [product]: Satın alınacak ürün detayları nesnesi
  /// * [onError]: İsteğe bağlı hata işleme geri çağrısı
  ///
  /// Not:
  /// * Abonelik ürünleri için [buyNonConsumable] kullanılır
  /// * Tek seferlik satın almalar için [buyConsumable] kullanılır
  Future<void> purchaseProduct(
    ProductDetails product, {
    Function(String message)? onError,
  }) async {
    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );

      if (product.id.startsWith('subscription')) {
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      onError?.call('Ürün satın alınırken hata oluştu: $e');
    }
  }

  /// Önceden satın alınan ürünleri geri yükler.
  ///
  /// Bu özellikle iOS'ta kullanıcıların birden fazla cihazı olabileceği için önemlidir.
  ///
  /// Parametreler:
  /// * [onError]: İsteğe bağlı hata işleme geri çağrısı
  /// * [onRestoreCompleted]: Geri yükleme tamamlandığında tetiklenecek isteğe bağlı geri çağrı
  ///
  /// Not: Geri yüklenen satın almalar [_purchases] listesine eklenecektir
  Future<void> restorePurchases({
    Function(String message)? onError,
    Function(List<PurchaseDetails>)? onRestoreCompleted,
  }) async {
    try {
      await _inAppPurchase.restorePurchases();
      onRestoreCompleted?.call(_purchases);
    } catch (e) {
      onError?.call('Satın almalar geri yüklenirken hata oluştu: $e');
    }
  }

  /// Servisi sonlandırır
  void dispose() {
    _subscription?.cancel();
    _purchaseController.close();
  }

  /// Belirli bir ürünün detaylarını kimliğini kullanarak getirir.
  ///
  /// Parametreler:
  /// * [productId]: Ürünün benzersiz kimliği
  ///
  /// Dönüş Değeri:
  /// * Bulunursa [ProductDetails]
  /// * Bulunamazsa null
  ProductDetails? getProductById(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Belirli bir ürünün satın alınıp alınmadığını kontrol eder.
  ///
  /// Parametreler:
  /// * [productId]: Ürünün benzersiz kimliği
  ///
  /// Dönüş Değeri:
  /// * Ürün satın alınmış ve doğrulanmışsa true
  /// * Aksi durumda false
  bool isProductPurchased(String productId) {
    return _purchases.any((purchase) =>
        purchase.productID == productId &&
        (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored));
  }

  /// Başarıyla satın alınan tüm ürünlerin listesini döndürür.
  ///
  /// Dönüş Değeri:
  /// * Tamamlanan tüm satın almalar için [PurchaseDetails] listesi
  /// * Sadece [PurchaseStatus.purchased] veya [PurchaseStatus.restored] durumundaki satın almaları içerir
  List<PurchaseDetails> getPurchasedProducts() {
    return _purchases
        .where((purchase) =>
            purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored)
        .toList();
  }
}
