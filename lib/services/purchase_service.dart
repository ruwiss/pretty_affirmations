import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';

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

  /// Initialize the purchase service
  Future<void> initialize({
    required List<String> productIds,
    Function(String message)? onError,
    Function(List<PurchaseDetails>)? onPurchasesUpdated,
  }) async {
    try {
      _isAvailable = await _inAppPurchase.isAvailable();
      if (!_isAvailable) {
        onError?.call('Store is not available');
        return;
      }

      await _getProducts(productIds, onError);
      _setupPurchaseStream(onPurchasesUpdated);
    } catch (e) {
      onError?.call('Failed to initialize purchase service: $e');
    }
  }

  /// Get available products from store
  Future<void> _getProducts(
    List<String> productIds,
    Function(String message)? onError,
  ) async {
    try {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(productIds.toSet());

      if (response.error != null) {
        onError?.call('Error loading products: ${response.error}');
        return;
      }

      if (response.productDetails.isEmpty) {
        onError?.call('No products found');
        return;
      }

      _products
        ..clear()
        ..addAll(response.productDetails);
    } catch (e) {
      onError?.call('Failed to get products: $e');
    }
  }

  /// Setup purchase stream for handling purchase updates
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

  /// Handle purchase updates
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
          _purchaseController.addError(Exception('Invalid purchase'));
        }
      }

      if (purchase.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchase);
      }
    }

    onPurchasesUpdated?.call(_purchases);
    _purchaseController.add(purchases);
  }

  /// Verify the purchase (implement your own verification logic)
  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    // Implement your purchase verification logic here
    // This might include server-side validation
    return true;
  }

  /// Deliver the purchased product
  Future<void> _deliverProduct(PurchaseDetails purchase) async {
    // Implement your product delivery logic here
  }

  /// Purchase a product
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
      onError?.call('Failed to purchase product: $e');
    }
  }

  /// Restore purchases
  Future<void> restorePurchases({
    Function(String message)? onError,
    Function(List<PurchaseDetails>)? onRestoreCompleted,
  }) async {
    try {
      await _inAppPurchase.restorePurchases();
      onRestoreCompleted?.call(_purchases);
    } catch (e) {
      onError?.call('Failed to restore purchases: $e');
    }
  }

  /// Dispose the service
  void dispose() {
    _subscription?.cancel();
    _purchaseController.close();
  }

  /// Get product details by ID
  ProductDetails? getProductById(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Check if a product is purchased
  bool isProductPurchased(String productId) {
    return _purchases.any((purchase) =>
        purchase.productID == productId &&
        (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored));
  }

  /// Get all purchased products
  List<PurchaseDetails> getPurchasedProducts() {
    return _purchases
        .where((purchase) =>
            purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored)
        .toList();
  }
}
