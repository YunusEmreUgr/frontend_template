import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/foundation.dart';
import '../../core/config/app_config.dart';
import '../../core/init/service_locator.dart';
import '../../domain/usecases/subscription/get_subscription_status_usecase.dart';
import '../../domain/usecases/subscription/verify_receipt_usecase.dart';

enum SubscriptionState { initial, loading, loaded, error }

class SubscriptionProvider extends ChangeNotifier {
  final GetSubscriptionStatusUseCase _getStatusUseCase = getIt<GetSubscriptionStatusUseCase>();
  final VerifyReceiptUseCase _verifyReceiptUseCase = getIt<VerifyReceiptUseCase>();

  SubscriptionState _state = SubscriptionState.initial;
  bool _isPremium = false;
  String _subscriptionTier = 'Free';
  DateTime? _expirationDate;
  String? _errorMessage;

  SubscriptionState get state => _state;
  bool get isPremium => _isPremium;
  String get subscriptionTier => _subscriptionTier;
  DateTime? get expirationDate => _expirationDate;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == SubscriptionState.loading;

  // IAP Altyapısı
  final InAppPurchase? _iap = kIsWeb ? null : InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  SubscriptionProvider() {
    _initIAP();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _initIAP() {
    if (kIsWeb) return;
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap!.purchaseStream;
    _subscription = purchaseUpdated.listen(
      (purchaseDetailsList) {
        _handlePurchaseUpdates(purchaseDetailsList);
      },
      onDone: () => _subscription?.cancel(),
      onError: (error) {
        _errorMessage = 'Ödeme akışı dinleme hatası: $error';
        notifyListeners();
      },
    );
  }

  /// Sunucudan kullanıcının güncel abonelik durumunu çeker.
  Future<void> fetchSubscriptionStatus() async {
    _state = SubscriptionState.loading;
    _errorMessage = null;
    notifyListeners();

    if (AppConfig.instance.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      // Mock veride durumu değiştirmeden var olan mock premium değerini koru
      _state = SubscriptionState.loaded;
      notifyListeners();
      return;
    }

    final result = await _getStatusUseCase();
    if (result.isSuccess) {
      final data = result.dataOrNull;
      if (data != null) {
        _isPremium = data['isActive'] == true;
        _subscriptionTier = data['subscriptionTier'] ?? 'Free';
        if (data['expirationDate'] != null) {
          _expirationDate = DateTime.tryParse(data['expirationDate'].toString());
        }
      } else {
        _isPremium = false;
        _subscriptionTier = 'Free';
        _expirationDate = null;
      }
      _state = SubscriptionState.loaded;
    } else {
      _state = SubscriptionState.error;
      _errorMessage = result.failureOrNull?.message ?? 'Abonelik durumu sorgulanamadı.';
    }
    notifyListeners();
  }

  /// App Store ürünlerini yükler (Örn: premium_monthly, premium_yearly).
  Future<void> loadProducts(List<String> productIds) async {
    if (AppConfig.instance.useMockData || kIsWeb) {
      // Mock modunda veya web'de örnek App Store paketleri üret
      _products = [
        ProductDetails(
          id: 'subscription_premium_monthly',
          title: 'Premium Aylık',
          description: 'Tüm profesyonel araçlara sınırsız erişim elde edin.',
          price: '₺129.99',
          rawPrice: 129.99,
          currencyCode: 'TRY',
        ),
        ProductDetails(
          id: 'subscription_premium_yearly',
          title: 'Premium Yıllık',
          description: 'Yıllık abonelik ile %40 tasarruf sağlayın.',
          price: '₺949.99',
          rawPrice: 949.99,
          currencyCode: 'TRY',
        ),
      ];
      notifyListeners();
      return;
    }

    final bool available = await _iap!.isAvailable();
    if (!available) {
      _errorMessage = 'Uygulama içi satın alımlar şu anda kullanılamıyor.';
      notifyListeners();
      return;
    }

    final ProductDetailsResponse response = await _iap.queryProductDetails(productIds.toSet());
    if (response.notFoundIDs.isNotEmpty) {
      // Bulunamayan ürün kimlikleri loglanabilir
    }

    _products = response.productDetails;
    notifyListeners();
  }

  /// Abonelik satın alma işlemini başlatır.
  Future<void> purchaseSubscription(ProductDetails product) async {
    _state = SubscriptionState.loading;
    _errorMessage = null;
    notifyListeners();

    if (AppConfig.instance.useMockData) {
      await Future.delayed(const Duration(milliseconds: 1000));
      // Satın alım başarılı simülasyonu
      _isPremium = true;
      _subscriptionTier = product.id.contains('yearly') ? 'Premium (Yıllık)' : 'Premium (Aylık)';
      _expirationDate = DateTime.now().add(product.id.contains('yearly') ? const Duration(days: 365) : const Duration(days: 30));
      _state = SubscriptionState.loaded;
      notifyListeners();
      return;
    }

    if (kIsWeb) {
      // Web'de backend doğrulaması için mock makbuz gönder
      final mockReceipt = 'mock_${product.id}';
      final success = await _verifyReceiptWithBackend(mockReceipt);
      if (success) {
        _isPremium = true;
        _subscriptionTier = product.id.contains('yearly') ? 'Premium (Yıllık)' : 'Premium (Aylık)';
        _expirationDate = DateTime.now().add(product.id.contains('yearly') ? const Duration(days: 365) : const Duration(days: 30));
        _state = SubscriptionState.loaded;
      } else {
        _state = SubscriptionState.error;
        _errorMessage = 'Abonelik sunucu tarafından doğrulanmadı.';
      }
      notifyListeners();
      return;
    }

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    try {
      await _iap!.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      _state = SubscriptionState.error;
      _errorMessage = 'Satın alma işlemi başlatılamadı: $e';
      notifyListeners();
    }
  }

  /// Geçmiş satın alımları geri yükler (Restore Purchases).
  Future<void> restorePurchases() async {
    _state = SubscriptionState.loading;
    _errorMessage = null;
    notifyListeners();

    if (AppConfig.instance.useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      _isPremium = true;
      _subscriptionTier = 'Premium (Restore)';
      _expirationDate = DateTime.now().add(const Duration(days: 30));
      _state = SubscriptionState.loaded;
      notifyListeners();
      return;
    }

    if (kIsWeb) {
      // Web'de sunucudan aktif durumu sorgula
      await fetchSubscriptionStatus();
      return;
    }

    try {
      await _iap!.restorePurchases();
    } catch (e) {
      _state = SubscriptionState.error;
      _errorMessage = 'Satın alımları geri yükleme hatası: $e';
      notifyListeners();
    }
  }

  /// Apple'dan gelen satın alma güncellemelerini yönetir.
  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _state = SubscriptionState.loading;
        notifyListeners();
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        _state = SubscriptionState.error;
        _errorMessage = purchaseDetails.error?.message ?? 'Ödeme işleminde hata oluştu.';
        notifyListeners();
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap?.completePurchase(purchaseDetails);
        }
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // Backend doğrulaması yap
        final String? receipt = purchaseDetails.verificationData.localVerificationData;
        if (receipt != null) {
          final success = await _verifyReceiptWithBackend(receipt);
          if (success) {
            _isPremium = true;
            _subscriptionTier = 'Premium';
            _state = SubscriptionState.loaded;
          } else {
            _state = SubscriptionState.error;
            _errorMessage = 'Makbuz backend tarafında doğrulanamadı.';
          }
        } else {
          _state = SubscriptionState.error;
          _errorMessage = 'Cihaz üzerinde yerel ödeme makbuzu bulunamadı.';
        }
        notifyListeners();

        if (purchaseDetails.pendingCompletePurchase) {
          await _iap?.completePurchase(purchaseDetails);
        }
      }
    }
  }

  /// Yerel makbuz verisini backend API'sine doğrulama için gönderir.
  Future<bool> _verifyReceiptWithBackend(String receiptData) async {
    final result = await _verifyReceiptUseCase(receiptData, environment: AppConfig.isDev ? 'Sandbox' : 'Production');
    if (result.isSuccess) {
      // Backend doğrulamayı tamamladı, son durum için profili güncelleyelim.
      await fetchSubscriptionStatus();
      return true;
    }
    return false;
  }
}
