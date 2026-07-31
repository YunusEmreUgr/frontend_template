import 'package:flutter/material.dart';
import '../../core/init/service_locator.dart';
import '../../core/storage/token_storage.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/get_user_claims_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase = getIt<LoginUseCase>();
  final RegisterUseCase _registerUseCase = getIt<RegisterUseCase>();
  final GetUserClaimsUseCase _getUserClaimsUseCase = getIt<GetUserClaimsUseCase>();
  final LogoutUseCase _logoutUseCase = getIt<LogoutUseCase>();

  AuthState _state = AuthState.initial;
  String? _errorMessage;
  List<String> _userClaims = [];

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  List<String> get userClaims => _userClaims;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;

  Future<void> checkAuthStatus() async {
    _state = AuthState.loading;
    notifyListeners();

    final hasToken = await TokenStorage.hasToken();
    if (hasToken) {
      _state = AuthState.authenticated;
      await fetchUserClaims();
    } else {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _loginUseCase(email, password);

    if (result.isSuccess) {
      _state = AuthState.authenticated;
      await fetchUserClaims();
      notifyListeners();
      return true;
    } else {
      _state = AuthState.error;
      _errorMessage = result.failureOrNull?.message ?? 'Giriş yapılamadı.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _registerUseCase(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );

    if (result.isSuccess) {
      _state = AuthState.authenticated;
      await fetchUserClaims();
      notifyListeners();
      return true;
    } else {
      _state = AuthState.error;
      _errorMessage = result.failureOrNull?.message ?? 'Kayıt olunamadı.';
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchUserClaims() async {
    final result = await _getUserClaimsUseCase();
    if (result.isSuccess) {
      _userClaims = result.dataOrNull ?? [];
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _logoutUseCase();
    _state = AuthState.unauthenticated;
    _userClaims = [];
    _errorMessage = null;
    notifyListeners();
  }
}
