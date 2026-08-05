import '../../../data/models/common/api_result.dart';
import '../../repositories/i_subscription_repository.dart';

class VerifyReceiptUseCase {
  final ISubscriptionRepository _repository;

  VerifyReceiptUseCase(this._repository);

  Future<ApiResult<Map<String, dynamic>>> call(String receiptData, {String? environment}) {
    return _repository.verifyReceipt(receiptData, environment: environment);
  }
}
