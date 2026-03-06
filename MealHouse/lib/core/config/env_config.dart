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
            // Replace with your actual IP if testing on physical device
            baseUrl = 'http://10.0.2.2:5000/api'; // Android emulator
            
            // If testing on physical device, use your laptop's IP:
            // baseUrl = 'http://YOUR_LAPTOP_IP:5000/api';
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
          baseUrl: 'http://fk408cssoog40csgo4s84k0k.194.238.18.123.sslip.io/api',
          apiKey: 'prod_key',
          environment: AppEnvironment.prod,
        );
        break;
    }
  }
}
