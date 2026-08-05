import '../../core/network/dio_client.dart';

class SubscriptionRemoteDataSource {
  final DioClient _dioClient;

  SubscriptionRemoteDataSource(this._dioClient);

  /// Apple makbuzunu backend'e gönderip doğrulatır.
  Future<Map<String, dynamic>> verifyReceipt(String receiptData, {String? environment}) async {
    final response = await _dioClient.post(
      '/subscriptions/verify-receipt',
      data: {
        'receiptData': receiptData,
        'environment': environment,
      },
    );
    return response;
  }

  /// Kullanıcının aktif abonelik durumunu çeker.
  Future<Map<String, dynamic>?> getSubscriptionStatus() async {
    final response = await _dioClient.get('/subscriptions/status');
    if (response.containsKey('data')) {
      final data = response['data'];
      if (data == null) return null;
      return Map<String, dynamic>.from(data);
    }
    return null;
  }
}
