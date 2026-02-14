import 'package:flutter/foundation.dart';

enum AppEnvironment { dev, prod }

class EnvConfig {
  final String baseUrl;
  final String apiKey;
  final AppEnvironment environment;

  EnvConfig({
    required this.baseUrl,
    required this.apiKey,
    required this.environment,
  });
}

class Environment {
  static late EnvConfig config;

  static void init(AppEnvironment env) {
    switch (env) {
      case AppEnvironment.dev:
        // For Android emulator, use 10.0.2.2. For web/iOS, use localhost.
        String baseUrl = 'http://localhost:5000';
        if (!kIsWeb) {
          if (defaultTargetPlatform == TargetPlatform.android) {
            baseUrl = 'http://10.0.2.2:5000';
          }
        }
        
        config = EnvConfig(
          baseUrl: baseUrl,
          apiKey: 'dev_key',
          environment: AppEnvironment.dev,
        );
        break;
      case AppEnvironment.prod:
        config = EnvConfig(
          baseUrl: 'https://api.messapp.com/api',
          apiKey: 'prod_key',
          environment: AppEnvironment.prod,
        );
        break;
    }
  }
}
