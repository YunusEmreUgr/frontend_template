import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../network/auth_interceptor.dart';
import '../network/dio_client.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/get_user_claims_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

final getIt = GetIt.instance;

class ServiceLocator {
  static late GlobalKey<NavigatorState> _navigatorKey;

  static void setup(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;

    // --- Core Dependencies ---
    getIt.registerLazySingleton<AuthInterceptor>(() => AuthInterceptor());
    getIt.registerLazySingleton<DioClient>(() => DioClient(getIt<AuthInterceptor>()));

    // --- Data Sources ---
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(getIt<DioClient>()),
    );

    // --- Repositories ---
    getIt.registerLazySingleton<IAuthRepository>(
      () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
    );

    // --- Use Cases ---
    getIt.registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(getIt<IAuthRepository>()),
    );
    getIt.registerLazySingleton<RegisterUseCase>(
      () => RegisterUseCase(getIt<IAuthRepository>()),
    );
    getIt.registerLazySingleton<GetUserClaimsUseCase>(
      () => GetUserClaimsUseCase(getIt<IAuthRepository>()),
    );
    getIt.registerLazySingleton<LogoutUseCase>(
      () => LogoutUseCase(getIt<IAuthRepository>()),
    );
  }

  static void onLogout() {
    _navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
