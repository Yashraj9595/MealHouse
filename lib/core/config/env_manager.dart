import 'package:flutter/foundation.dart';
import 'app_config.dart';
import 'environment.dart';

class EnvManager {
  static Environment? _currentEnvironment;
  
  static Environment get currentEnvironment {
    _currentEnvironment ??= _getEnvironmentFromConfig();
    return _currentEnvironment!;
  }
  
  static Environment _getEnvironmentFromConfig() {
    final envString = AppConfig.environment;
    
    switch (envString.toLowerCase()) {
      case 'production':
      case 'prod':
        return Environment.production;
      case 'staging':
      case 'stage':
        return Environment.staging;
      case 'development':
      case 'dev':
      default:
        return Environment.development;
    }
  }
  
  static bool get isDevelopment => currentEnvironment.isDevelopment;
  static bool get isStaging => currentEnvironment.isStaging;
  static bool get isProduction => currentEnvironment.isProduction;
  
  static void initialize() {
    if (kDebugMode) {
      print('🚀 Environment: ${currentEnvironment.name}');
      print('🔗 API URL: ${AppConfig.apiBaseUrl}');
      print('📱 App Name: ${AppConfig.appName}');
    }
  }
}
