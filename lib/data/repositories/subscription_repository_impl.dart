import '../../core/errors/api_exception.dart';
import '../../core/errors/failures.dart';
import '../../domain/repositories/i_subscription_repository.dart';
import '../datasources/subscription_remote_data_source.dart';
import '../models/common/api_result.dart';

class SubscriptionRepositoryImpl implements ISubscriptionRepository {
  final SubscriptionRemoteDataSource _remoteDataSource;

  SubscriptionRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<Map<String, dynamic>>> verifyReceipt(String receiptData, {String? environment}) async {
    try {
      final data = await _remoteDataSource.verifyReceipt(receiptData, environment: environment);
      return ApiResult.success(data);
    } on ApiException catch (e) {
      return ApiResult.failure(ServerFailure(message: e.message, code: e.errorCode));
    } catch (e) {
      return ApiResult.failure(ServerFailure(message: 'Ödeme makbuzu doğrulanırken bir hata oluştu.'));
    }
  }

  @override
  Future<ApiResult<Map<String, dynamic>?>> getSubscriptionStatus() async {
    try {
      final data = await _remoteDataSource.getSubscriptionStatus();
      return ApiResult.success(data);
    } on ApiException catch (e) {
      return ApiResult.failure(ServerFailure(message: e.message, code: e.errorCode));
    } catch (e) {
      return ApiResult.failure(ServerFailure(message: 'Abonelik durumu kontrol edilirken bir hata oluştu.'));
    }
  }
}
