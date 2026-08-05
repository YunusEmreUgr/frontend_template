import '../../../data/models/common/api_result.dart';
import '../../repositories/i_user_repository.dart';

class DeleteAccountUseCase {
  final IUserRepository _repository;

  DeleteAccountUseCase(this._repository);

  Future<ApiResult<bool>> call() {
    return _repository.deleteAccount();
  }
}
