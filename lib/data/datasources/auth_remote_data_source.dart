import '../../core/network/dio_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/auth/login_request.dart';
import '../models/auth/register_request.dart';
import '../models/auth/token_model.dart';

class AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSource(this._dioClient);

  Future<TokenModel> login(LoginRequest request) async {
    final response = await _dioClient.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );
    
    final data = response.containsKey('data') ? response['data'] : response;
    return TokenModel.fromJson(data);
  }

  Future<TokenModel> register(RegisterRequest request) async {
    final response = await _dioClient.post(
      ApiEndpoints.register,
      data: request.toJson(),
    );

    final data = response.containsKey('data') ? response['data'] : response;
    return TokenModel.fromJson(data);
  }

  Future<List<String>> getUserClaims() async {
    final response = await _dioClient.get(ApiEndpoints.getUserClaims);
    final data = response.containsKey('data') ? response['data'] : response;
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }
    return [];
  }

  Future<TokenModel> googleLogin(String idToken, {String? firstName, String? lastName}) async {
    final response = await _dioClient.post(
      '/auth/google-login',
      data: {
        'idToken': idToken,
        'firstName': firstName,
        'lastName': lastName,
      },
    );
    final data = response.containsKey('data') ? response['data'] : response;
    return TokenModel.fromJson(data);
  }

  Future<TokenModel> appleLogin({
    required String identityToken,
    String? authorizationCode,
    String? givenName,
    String? familyName,
    String? email,
  }) async {
    final response = await _dioClient.post(
      '/auth/apple-login',
      data: {
        'identityToken': identityToken,
        'authorizationCode': authorizationCode,
        'givenName': givenName,
        'familyName': familyName,
        'email': email,
      },
    );
    final data = response.containsKey('data') ? response['data'] : response;
    return TokenModel.fromJson(data);
  }
}
