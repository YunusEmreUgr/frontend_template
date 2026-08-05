import '../../data/models/common/api_result.dart';

abstract class ISubscriptionRepository {
  /// Makbuz doğrulama işlemi.
  Future<ApiResult<Map<String, dynamic>>> verifyReceipt(String receiptData, {String? environment});

  /// Abonelik durumu sorgulama işlemi.
  Future<ApiResult<Map<String, dynamic>?>> getSubscriptionStatus();
}
