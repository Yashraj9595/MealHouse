import 'package:flutter/foundation.dart';

class AppConfig {
  static const String _environment = String.fromEnvironment(
    'FLUTTER_ENV',
    defaultValue: 'development',
  );

  static String get environment => _environment;
  
  static bool get isDevelopment => _environment == 'development';
  static bool get isProduction => _environment == 'production';
  static bool get isStaging => _environment == 'staging';

  // API Configuration
  /// Must include trailing `/` so Dio joins paths like `auth/login` correctly.
  static String get apiBaseUrl {
    if (kReleaseMode) {
      return 'https://your-production-api.com/api/v1/';
    } else if (isDevelopment) {
      if (kIsWeb) {
        return 'http://localhost:5000/api/v1/';
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        return 'http://10.0.2.2:5000/api/v1/';
      } else {
        return 'http://localhost:5000/api/v1/';
      }
    } else {
      return 'https://your-staging-api.com/api/v1/';
    }
  }

  static String get imageBaseUrl {
    final baseUrl = apiBaseUrl;
    // Deriving the base URL without /api/v1/
    return baseUrl.replaceFirst('/api/v1/', '');
  }

  // App Configuration
  static String get appName {
    switch (_environment) {
      case 'production':
        return 'Meal House';
      case 'staging':
        return 'Meal House (Staging)';
      default:
        return 'Meal House (Dev)';
    }
  }

  static bool get enableDebugMode => !kReleaseMode;
  static bool get enableLogging => isDevelopment;
  
  // Timeout Configuration
  static Duration get connectTimeout => const Duration(seconds: 10);
  static Duration get receiveTimeout => const Duration(seconds: 5);
  static Duration get sendTimeout => const Duration(seconds: 5);
  
  // Security Configuration
  static bool get requireHttps => isProduction;
  
  // Feature Flags
  static bool get enableAnalytics => isProduction;
  static bool get enableCrashReporting => !isDevelopment;
  
  @override
  String toString() {
    return '''
AppConfig:
  Environment: $_environment
  API Base URL: $apiBaseUrl
  App Name: $appName
  Debug Mode: $enableDebugMode
  Logging: $enableLogging
  Require HTTPS: $requireHttps
    ''';
  }
}
