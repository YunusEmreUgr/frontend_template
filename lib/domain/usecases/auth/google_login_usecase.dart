import '../../../data/models/common/api_result.dart';
import '../../entities/token_entity.dart';
import '../../repositories/i_auth_repository.dart';

class GoogleLoginUseCase {
  final IAuthRepository _repository;

  GoogleLoginUseCase(this._repository);

  Future<ApiResult<TokenEntity>> call(String idToken, {String? firstName, String? lastName}) {
    return _repository.googleLogin(idToken, firstName: firstName, lastName: lastName);
  }
}
