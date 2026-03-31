class AppConstants {
  // App Information
  static const String appName = 'Meal House';
  static const String appVersion = '1.0.0';
  
  // API Constants
  static const String apiTimeout = '15000';
  static const int connectTimeoutSeconds = 10;
  static const int receiveTimeoutSeconds = 5;
  static const int sendTimeoutSeconds = 5;
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userRoleKey = 'user_role';
  static const String userProfileKey = 'user_profile';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String themeKey = 'theme_mode';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int maxNameLength = 50;
  static const int maxEmailLength = 100;
  
  // UI Constants
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 20.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  
  // Animation Durations
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationLong = Duration(milliseconds: 500);
  
  // Network
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  
  // Cache
  static const Duration cacheExpiration = Duration(hours: 1);
  static const Duration userCacheExpiration = Duration(days: 1);
  
  // Private constructor to prevent instantiation
  AppConstants._();
}
