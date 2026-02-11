import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'token_manager.dart';

/// Handles real $1/month premium subscription via Google Play
class PurchaseService extends ChangeNotifier {
  static const String _monthlySubId = 'yes_sir_premium_monthly';
  static final Set<String> _productIds = {_monthlySubId};

  final InAppPurchase _iap = InAppPurchase.instance;
  final TokenManager _tokenManager;

  bool _isAvailable = false;
  bool _isPurchasing = false;
  List<ProductDetails> _products = [];
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool get isAvailable => _isAvailable;
  bool get isPurchasing => _isPurchasing;
  List<ProductDetails> get products => _products;
  ProductDetails? get monthlyProduct =>
      _products.isNotEmpty ? _products.first : null;

  PurchaseService({required TokenManager tokenManager})
      : _tokenManager = tokenManager;

  /// Initialize the purchase service
  Future<void> initialize() async {
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      debugPrint('PurchaseService: Store not available');
      notifyListeners();
      return;
    }

    // Listen for purchase updates
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onDone: () => _subscription?.cancel(),
      onError: (error) => debugPrint('PurchaseService error: $error'),
    );

    // Load products
    await _loadProducts();

    // Restore previous purchases
    await _restorePurchases();

    notifyListeners();
  }

  /// Load available products from the store
  Future<void> _loadProducts() async {
    try {
      final response = await _iap.queryProductDetails(_productIds);
      if (response.error != null) {
        debugPrint('PurchaseService: Error loading products: ${response.error}');
        return;
      }
      _products = response.productDetails;
      debugPrint('PurchaseService: Loaded ${_products.length} products');
    } catch (e) {
      debugPrint('PurchaseService: Failed to load products: $e');
    }
  }

  /// Buy the monthly premium subscription
  Future<bool> buyPremium() async {
    if (!_isAvailable) {
      debugPrint('PurchaseService: Store not available');
      return false;
    }

    if (_products.isEmpty) {
      debugPrint('PurchaseService: No products available');
      return false;
    }

    _isPurchasing = true;
    notifyListeners();

    try {
      final productDetails = _products.first;
      final purchaseParam = PurchaseParam(productDetails: productDetails);

      // For subscriptions, use buyNonConsumable
      final success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      if (!success) {
        _isPurchasing = false;
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('PurchaseService: Purchase failed: $e');
      _isPurchasing = false;
      notifyListeners();
      return false;
    }
  }

  /// Handle purchase updates
  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchase in purchaseDetailsList) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _verifyAndDeliver(purchase);
          break;
        case PurchaseStatus.error:
          debugPrint('PurchaseService: Purchase error: ${purchase.error}');
          _isPurchasing = false;
          notifyListeners();
          break;
        case PurchaseStatus.canceled:
          debugPrint('PurchaseService: Purchase canceled');
          _isPurchasing = false;
          notifyListeners();
          break;
        case PurchaseStatus.pending:
          debugPrint('PurchaseService: Purchase pending');
          break;
      }

      // Complete the purchase if needed
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  /// Verify purchase and deliver premium
  Future<void> _verifyAndDeliver(PurchaseDetails purchase) async {
    if (purchase.productID == _monthlySubId) {
      // Activate premium
      await _tokenManager.upgradeToPremium();
      debugPrint('PurchaseService: Premium activated!');
    }
    _isPurchasing = false;
    notifyListeners();
  }

  /// Restore previous purchases
  Future<void> _restorePurchases() async {
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('PurchaseService: Restore failed: $e');
    }
  }

  /// Cancel subscription (redirects to Play Store)
  Future<void> cancelSubscription() async {
    await _tokenManager.downgradeToFree();
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
