import '../../data/models/common/api_result.dart';
import '../entities/token_entity.dart';

abstract class IAuthRepository {
  Future<ApiResult<TokenEntity>> login(String email, String password);
  Future<ApiResult<TokenEntity>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });
  Future<ApiResult<List<String>>> getUserClaims();
  Future<ApiResult<TokenEntity>> googleLogin(String idToken, {String? firstName, String? lastName});
  Future<ApiResult<TokenEntity>> appleLogin({
    required String identityToken,
    String? authorizationCode,
    String? givenName,
    String? familyName,
    String? email,
  });
  Future<void> logout();
}
