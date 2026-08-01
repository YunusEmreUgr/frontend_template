enum AppEnvironment { dev, staging, prod }

class AppConfig {
  final AppEnvironment environment;
  final String apiBaseUrl;
  final String appTitle;
  final bool enableLogging;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  static late AppConfig _instance;

  AppConfig._internal({
    required this.environment,
    required this.apiBaseUrl,
    required this.appTitle,
    required this.enableLogging,
    required this.connectTimeout,
    required this.receiveTimeout,
  });

  static void init({required AppEnvironment environment}) {
    switch (environment) {
      case AppEnvironment.dev:
        _instance = AppConfig._internal(
          environment: AppEnvironment.dev,
          apiBaseUrl: 'https://localhost:7089/api/v1',
          appTitle: 'Enterprise App (Dev)',
          enableLogging: true,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        );
        break;
      case AppEnvironment.staging:
        _instance = AppConfig._internal(
          environment: AppEnvironment.staging,
          apiBaseUrl: 'https://staging-api.enterprise.com/api/v1',
          appTitle: 'Enterprise App (Staging)',
          enableLogging: true,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        );
        break;
      case AppEnvironment.prod:
        _instance = AppConfig._internal(
          environment: AppEnvironment.prod,
          apiBaseUrl: 'https://api.enterprise.com/api/v1',
          appTitle: 'Enterprise App',
          enableLogging: false,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        );
        break;
    }
  }

  static AppConfig get instance => _instance;

  static bool get isDev => _instance.environment == AppEnvironment.dev;
  static bool get isStaging => _instance.environment == AppEnvironment.staging;
  static bool get isProd => _instance.environment == AppEnvironment.prod;
}
