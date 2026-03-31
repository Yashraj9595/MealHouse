# Environment Configuration Setup

This document explains how to set up and use environment configurations in the Meal House Flutter app.

## 📁 Environment Files

The app uses different environment configurations:

- `.env.development` - Development environment
- `.env.staging` - Staging environment  
- `.env.production` - Production environment

## 🚀 Usage

### Development Mode (Default)
```bash
flutter run
# or explicitly
flutter run --dart-define=FLUTTER_ENV=development
```

### Staging Mode
```bash
flutter run --dart-define=FLUTTER_ENV=staging
```

### Production Mode
```bash
flutter run --release --dart-define=FLUTTER_ENV=production
```

## 🔧 Building for Different Environments

### Development APK
```bash
flutter build apk --debug --dart-define=FLUTTER_ENV=development
```

### Staging APK
```bash
flutter build apk --release --dart-define=FLUTTER_ENV=staging
```

### Production APK
```bash
flutter build apk --release --dart-define=FLUTTER_ENV=production
```

### Use Build Script
```bash
chmod +x scripts/build_scripts.sh
./scripts/build_scripts.sh
```

## 📱 Platform-Specific URLs

The app automatically detects the platform and uses the appropriate URL:

- **Android Emulator**: `http://10.0.2.2:5000/api/v1`
- **iOS Simulator**: `http://localhost:5000/api/v1`
- **Web/Desktop**: `http://localhost:5000/api/v1`

## 🔍 Environment Variables Available

- `FLUTTER_ENV` - Current environment (development/staging/production)
- `API_BASE_URL` - Backend API URL
- `APP_NAME` - Application name
- `DEBUG_MODE` - Enable debug features
- `ENABLE_LOGGING` - Enable console logging
- `ENABLE_ANALYTICS` - Enable analytics tracking
- `ENABLE_CRASH_REPORTING` - Enable crash reporting
- `REQUIRE_HTTPS` - Enforce HTTPS in production

## 🛠️ Configuration Files

### Core Configuration
- `lib/core/config/app_config.dart` - Main configuration class
- `lib/core/config/environment.dart` - Environment enum
- `lib/core/config/env_manager.dart` - Environment manager

### Usage in Code
```dart
import '../core/config/app_config.dart';

// Get API URL
final apiUrl = AppConfig.apiBaseUrl;

// Check environment
if (AppConfig.isDevelopment) {
  // Development-specific code
}

// Get app name
final appName = AppConfig.appName;
```

## 🔐 Security Notes

- Production builds require HTTPS
- Debug features are disabled in production
- Sensitive data should not be stored in environment files
- Use `.env` files for local development only

## 🐛 Debugging

To see current environment configuration:
```dart
import '../core/config/app_config.dart';

print(AppConfig.toString());
```

This will display:
- Current environment
- API URL
- App name
- Debug settings
- Security settings
