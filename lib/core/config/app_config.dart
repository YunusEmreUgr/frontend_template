import 'package:flutter/foundation.dart';

enum AppEnvironment { dev, staging, prod }

class AppConfig {
  final AppEnvironment environment;
  final String apiBaseUrl;
  final String appTitle;
  final bool enableLogging;
  final bool useMockData;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  static late AppConfig _instance;

  AppConfig._internal({
    required this.environment,
    required this.apiBaseUrl,
    required this.appTitle,
    required this.enableLogging,
    this.useMockData = false,
    required this.connectTimeout,
    required this.receiveTimeout,
  });

  static void init({required AppEnvironment environment, bool useMockData = false}) {
    switch (environment) {
      case AppEnvironment.dev:
        final defaultDevUrl = kIsWeb
            ? 'http://localhost:5212/api/v1'
            : (defaultTargetPlatform == TargetPlatform.android
                ? 'http://10.0.2.2:5212/api/v1'
                : 'http://localhost:5212/api/v1');

        _instance = AppConfig._internal(
          environment: AppEnvironment.dev,
          apiBaseUrl: defaultDevUrl,
          appTitle: 'Enterprise App (Dev)',
          enableLogging: true,
          useMockData: useMockData,
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
          useMockData: useMockData,
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
          useMockData: false,
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

