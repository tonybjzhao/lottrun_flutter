import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Product ID ────────────────────────────────────────────────────────────────
// Must exactly match App Store Connect / Play Console product ID.
// iOS checklist:
//   • Product created in App Store Connect → In-App Purchases
//   • Status: Ready to Submit / Approved (or "Approved" for sandbox)
//   • Paid Apps Agreement, tax, and banking completed
//   • Test via TestFlight or a StoreKit Configuration file (sandbox)
// Android checklist:
//   • App uploaded to at least one testing track (internal/alpha)
//   • Product created in Play Console → Monetize → In-app products, status Active
//   • Tester added as licensed tester or internal tester
const String kPremiumProductId = 'lottrun_premium_lifetime';
const String _kPremiumKey = 'premium_unlocked';

enum PurchaseResult { pending, unavailable, error }

enum ProductLoadState { loading, loaded, notFound, storeUnavailable }

class PremiumService extends ChangeNotifier {
  PremiumService._();
  static final instance = PremiumService._();

  bool _isPremium = false;
  bool _isPurchasing = false;
  ProductDetails? _product;
  ProductLoadState _loadState = ProductLoadState.loading;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  bool get isPremium => _isPremium;
  bool get isPurchasing => _isPurchasing;
  ProductDetails? get product => _product;
  ProductLoadState get loadState => _loadState;
  String get displayPrice => _product?.price ?? '\$9.99';

  // True only when the button should be enabled
  bool get canPurchase =>
      !_isPurchasing && _product != null && _loadState == ProductLoadState.loaded;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_kPremiumKey) ?? false;
    notifyListeners();

    final available = await InAppPurchase.instance.isAvailable();
    debugPrint('[PremiumService] store isAvailable: $available');

    if (!available) {
      _loadState = ProductLoadState.storeUnavailable;
      notifyListeners();
      return;
    }

    _sub = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _sub?.cancel(),
    );

    await _loadProduct();
  }

  Future<void> _loadProduct() async {
    _loadState = ProductLoadState.loading;
    notifyListeners();

    debugPrint('[PremiumService] querying product ids: {$kPremiumProductId}');
    final response = await InAppPurchase.instance
        .queryProductDetails({kPremiumProductId});

    debugPrint('[PremiumService] returned product count: ${response.productDetails.length}');
    debugPrint('[PremiumService] notFoundIDs: ${response.notFoundIDs}');

    if (response.productDetails.isNotEmpty) {
      _product = response.productDetails.first;
      _loadState = ProductLoadState.loaded;
      debugPrint('[PremiumService] product loaded: "${_product!.title}" @ ${_product!.price}');
    } else {
      _loadState = ProductLoadState.notFound;
      debugPrint('[PremiumService] product NOT found — check App Store Connect / Play Console');
      debugPrint('[PremiumService] notFoundIDs: ${response.notFoundIDs}');
    }
    notifyListeners();
  }

  Future<PurchaseResult> purchase() async {
    if (_product == null) return PurchaseResult.unavailable;
    _isPurchasing = true;
    notifyListeners();
    debugPrint('[PremiumService] initiating purchase: $kPremiumProductId');
    try {
      final param = PurchaseParam(productDetails: _product!);
      await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
      return PurchaseResult.pending;
    } catch (e) {
      debugPrint('[PremiumService] purchase error: $e');
      _isPurchasing = false;
      notifyListeners();
      return PurchaseResult.error;
    }
  }

  // Restore does not require productDetails — calls restorePurchases directly.
  Future<PurchaseResult> restore() async {
    final available = await InAppPurchase.instance.isAvailable();
    if (!available) return PurchaseResult.unavailable;
    _isPurchasing = true;
    notifyListeners();
    debugPrint('[PremiumService] restoring purchases');
    try {
      await InAppPurchase.instance.restorePurchases();
      return PurchaseResult.pending;
    } catch (e) {
      debugPrint('[PremiumService] restore error: $e');
      _isPurchasing = false;
      notifyListeners();
      return PurchaseResult.error;
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      debugPrint('[PremiumService] purchase update — id: ${p.productID}, status: ${p.status}');
      if (p.productID != kPremiumProductId) continue;
      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        if (p.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(p);
        }
        await _unlock();
      } else if (p.status == PurchaseStatus.error) {
        debugPrint('[PremiumService] purchase error detail: ${p.error}');
        _isPurchasing = false;
        notifyListeners();
      } else if (p.status == PurchaseStatus.canceled) {
        debugPrint('[PremiumService] purchase cancelled by user');
        _isPurchasing = false;
        notifyListeners();
      } else if (p.status == PurchaseStatus.pending) {
        debugPrint('[PremiumService] purchase pending (e.g. Ask to Buy)');
      }
    }
  }

  Future<void> _unlock() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPremiumKey, true);
    _isPremium = true;
    _isPurchasing = false;
    debugPrint('[PremiumService] premium unlocked');
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
