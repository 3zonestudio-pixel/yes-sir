import 'package:flutter/material.dart';
import 'token_manager.dart';

/// Premium subscription service — Coming Soon!
/// This is a stub until in-app purchases are ready for launch.
class PurchaseService extends ChangeNotifier {
  final TokenManager _tokenManager;

  bool _isAvailable = false;
  bool _isPurchasing = false;

  bool get isAvailable => _isAvailable;
  bool get isPurchasing => _isPurchasing;

  PurchaseService({required TokenManager tokenManager})
      : _tokenManager = tokenManager;

  /// Initialize — currently a no-op (Coming Soon)
  Future<void> initialize() async {
    _isAvailable = false;
    debugPrint('PurchaseService: Premium coming soon!');
    notifyListeners();
  }

  /// Buy premium — not yet available
  Future<bool> buyPremium() async {
    debugPrint('PurchaseService: Premium coming soon!');
    return false;
  }

  /// Cancel subscription
  Future<void> cancelSubscription() async {
    await _tokenManager.downgradeToFree();
    notifyListeners();
  }
}
