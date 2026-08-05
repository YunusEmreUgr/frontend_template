import '../../../data/models/common/api_result.dart';
import '../../entities/token_entity.dart';
import '../../repositories/i_auth_repository.dart';

class AppleLoginUseCase {
  final IAuthRepository _repository;

  AppleLoginUseCase(this._repository);

  Future<ApiResult<TokenEntity>> call({
    required String identityToken,
    String? authorizationCode,
    String? givenName,
    String? familyName,
    String? email,
  }) {
    return _repository.appleLogin(
      identityToken: identityToken,
      authorizationCode: authorizationCode,
      givenName: givenName,
      familyName: familyName,
      email: email,
    );
  }
}
