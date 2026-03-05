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
        // For different development scenarios:
        // - Android emulator: 10.0.2.2:5000
        // - Physical device on same WiFi: Your laptop's IP:5000
        // - Physical device via USB: Your laptop's IP:5000
        String baseUrl = 'http://localhost:5000/api';
        
        if (!kIsWeb) {
          if (defaultTargetPlatform == TargetPlatform.android) {
            // For physical devices, use your laptop's IP address
            // This IP was detected automatically: 10.87.156.74
            baseUrl = 'http://10.87.156.74:5001/api'; // Physical device USB/WiFi
            
            // If you're using Android emulator, uncomment this line:
            // baseUrl = 'http://10.0.2.2:5000/api'; // Android emulator only
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
