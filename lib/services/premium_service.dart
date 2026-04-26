import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kPremiumProductId = 'lottrun_premium_lifetime';
const String _kPremiumKey = 'premium_unlocked';

class PremiumService extends ChangeNotifier {
  PremiumService._();
  static final instance = PremiumService._();

  bool _isPremium = false;
  bool _isLoading = false;
  ProductDetails? _product;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  String get displayPrice => _product?.price ?? '\$9.99';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_kPremiumKey) ?? false;
    notifyListeners();

    final available = await InAppPurchase.instance.isAvailable();
    if (!available) return;

    _sub = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _sub?.cancel(),
    );

    await _loadProduct();
  }

  Future<void> _loadProduct() async {
    final response = await InAppPurchase.instance
        .queryProductDetails({kPremiumProductId});
    if (response.productDetails.isNotEmpty) {
      _product = response.productDetails.first;
      notifyListeners();
    }
  }

  Future<PurchaseResult> purchase() async {
    if (_product == null) {
      await _loadProduct();
      if (_product == null) return PurchaseResult.unavailable;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final param = PurchaseParam(productDetails: _product!);
      await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
      return PurchaseResult.pending;
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return PurchaseResult.error;
    }
  }

  Future<PurchaseResult> restore() async {
    _isLoading = true;
    notifyListeners();
    try {
      await InAppPurchase.instance.restorePurchases();
      return PurchaseResult.pending;
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return PurchaseResult.error;
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.productID != kPremiumProductId) continue;
      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        if (p.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(p);
        }
        await _unlock();
      } else if (p.status == PurchaseStatus.error ||
          p.status == PurchaseStatus.canceled) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _unlock() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPremiumKey, true);
    _isPremium = true;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

enum PurchaseResult { pending, unavailable, error }
