import '../../../data/models/common/api_result.dart';
import '../../repositories/i_subscription_repository.dart';

class GetSubscriptionStatusUseCase {
  final ISubscriptionRepository _repository;

  GetSubscriptionStatusUseCase(this._repository);

  Future<ApiResult<Map<String, dynamic>?>> call() {
    return _repository.getSubscriptionStatus();
  }
}
