# Meal House - Flutter Architecture Guide

## 📁 Project Structure

This project follows **Clean Architecture** principles with proper separation of concerns and modular design.

```
lib/
├── core/                           # Core application logic
│   ├── config/                     # Configuration management
│   │   ├── app_config.dart         # Environment-specific settings
│   │   ├── environment.dart        # Environment enum
│   │   └── env_manager.dart        # Environment manager
│   ├── di/                         # Dependency injection
│   │   └── service_locator.dart    # Service locator setup
│   └── utils/                      # Core utilities
│
├── features/                       # Feature-based modules
│   ├── auth/                      # Authentication feature
│   │   ├── data/                   # Data layer
│   │   │   ├── models/            # Data models (DTOs)
│   │   │   ├── repositories/       # Repository implementations
│   │   │   └── services/          # API services
│   │   ├── domain/                # Domain layer
│   │   │   ├── entities/          # Business entities
│   │   │   ├── repositories/       # Repository interfaces
│   │   │   └── usecases/          # Business logic use cases
│   │   └── presentation/           # Presentation layer
│   │       ├── screens/           # UI screens
│   │       ├── widgets/           # Feature-specific widgets
│   │       └── providers/         # State management
│   ├── user/                      # User management feature
│   ├── mess_owner/                # Mess owner feature
│   ├── wallet/                    # Wallet feature
│   └── notifications/             # Notifications feature
│
├── shared/                        # Shared utilities and components
│   ├── api/                       # API configuration
│   │   └── api_client.dart        # HTTP client
│   ├── constants/                 # App constants
│   │   ├── app_constants.dart     # General constants
│   │   └── api_endpoints.dart     # API endpoints
│   ├── exceptions/                # Custom exceptions
│   │   └── app_exceptions.dart    # Exception classes
│   ├── extensions/                # Dart extensions
│   │   ├── string_extensions.dart # String extensions
│   │   └── datetime_extensions.dart # DateTime extensions
│   ├── utils/                     # Utility functions
│   │   ├── validators.dart        # Input validators
│   │   └── helpers.dart           # Helper functions
│   ├── widgets/                   # Reusable widgets
│   │   ├── custom_button.dart     # Custom button widget
│   │   └── custom_text_field.dart # Custom text field widget
│   └── theme/                     # App theming
│       └── app_theme.dart         # Theme configuration
│
├── routes/                        # Navigation configuration
├── services/                      # Global services
└── main.dart                      # App entry point
```

## 🏗️ Architecture Layers

### 1. **Presentation Layer** (UI)
- **Screens**: Complete UI pages
- **Widgets**: Reusable UI components
- **Providers/Controllers**: State management (BLoC, Provider, etc.)

### 2. **Domain Layer** (Business Logic)
- **Entities**: Core business objects
- **Repositories**: Abstract interfaces for data access
- **Use Cases**: Specific business operations

### 3. **Data Layer** (Data Access)
- **Models**: Data transfer objects (DTOs)
- **Repository Implementations**: Concrete implementations
- **Services**: API clients and external service integrations

### 4. **Core Layer** (Infrastructure)
- **Configuration**: Environment and app settings
- **Dependency Injection**: Service locator setup
- **Shared Utilities**: Common functions and extensions

## 🔧 Key Components

### **Environment Configuration**
- **Development**: `http://10.0.2.2:5000/api/v1` (Android emulator)
- **Staging**: `https://staging-api.com/api/v1`
- **Production**: `https://production-api.com/api/v1`

### **Dependency Injection**
Uses **GetIt** for service location:
```dart
final apiClient = sl<ApiClient>();
final loginUseCase = sl<LoginUseCase>();
```

### **Error Handling**
Custom exception hierarchy:
- `AppException` (base)
- `ServerException`, `NetworkException`, `ValidationException`
- `AuthenticationException`, `AuthorizationException`

### **API Client**
Enhanced HTTP client with:
- Automatic token management
- Request/response logging
- Error handling
- File upload/download support

## 📦 Dependencies

### **Core Dependencies**
- `dio`: HTTP client
- `flutter_secure_storage`: Secure storage
- `get_it`: Dependency injection
- `equatable`: Value equality
- `intl`: Internationalization

### **UI Dependencies**
- `google_fonts`: Custom fonts
- `flutter/material.dart`: Material Design

## 🚀 Getting Started

### **1. Environment Setup**
```bash
# Development
flutter run --dart-define=FLUTTER_ENV=development

# Staging
flutter run --dart-define=FLUTTER_ENV=staging

# Production
flutter run --release --dart-define=FLUTTER_ENV=production
```

### **2. Dependency Installation**
```bash
flutter pub get
```

### **3. Build Commands**
```bash
# Development build
flutter build apk --debug --dart-define=FLUTTER_ENV=development

# Production build
flutter build apk --release --dart-define=FLUTTER_ENV=production
```

## 📱 Usage Examples

### **API Calls**
```dart
// Using the API client directly
final apiClient = sl<ApiClient>();
final response = await apiClient.get('/users');

// Using use cases (recommended)
final loginUseCase = sl<LoginUseCase>();
final user = await loginUseCase.execute(email, password);
```

### **Custom Widgets**
```dart
// Custom button
CustomButton(
  text: 'Login',
  onPressed: () {},
  type: ButtonType.primary,
  size: ButtonSize.medium,
)

// Custom text field
CustomTextField(
  labelText: 'Email',
  type: TextFieldType.email,
  validator: Validators.validateEmail,
)
```

### **Utilities**
```dart
// String extensions
'email@domain.com'.isEmail // true
'Hello World'.capitalize // 'Hello world'

// DateTime extensions
DateTime.now().timeAgo // '2 minutes ago'

// Helpers
Helpers.formatCurrency(99.99) // '₹99.99'
Helpers.showSuccessSnackBar(context, 'Success!')
```

## 🎯 Best Practices

### **1. Feature Organization**
- Each feature is self-contained with its own data, domain, and presentation layers
- Features communicate through well-defined interfaces
- No direct dependencies between features

### **2. Dependency Management**
- All dependencies are injected through the service locator
- No direct instantiation of services in UI code
- Easy to mock for testing

### **3. Error Handling**
- All exceptions are handled consistently
- User-friendly error messages
- Proper error logging

### **4. Code Reusability**
- Shared widgets for common UI patterns
- Utility functions for common operations
- Extensions for enhanced functionality

### **5. Configuration Management**
- Environment-specific settings
- Easy switching between environments
- Secure storage of sensitive data

## 🧪 Testing

### **Unit Tests**
```bash
flutter test
```

### **Integration Tests**
```bash
flutter test integration_test/
```

## 📝 Adding New Features

1. **Create feature structure**:
   ```
   features/new_feature/
   ├── data/
   ├── domain/
   └── presentation/
   ```

2. **Define domain entities** in `domain/entities/`

3. **Create repository interface** in `domain/repositories/`

4. **Implement use cases** in `domain/usecases/`

5. **Create repository implementation** in `data/repositories/`

6. **Build UI components** in `presentation/`

7. **Register dependencies** in `core/di/service_locator.dart`

## 🔒 Security

- **Secure Storage**: Uses `flutter_secure_storage` for sensitive data
- **HTTPS**: Enforced in production environment
- **Token Management**: Automatic refresh and secure storage
- **Input Validation**: Comprehensive validation for all user inputs

## 📊 Performance

- **Lazy Loading**: Dependencies are created when first used
- **Caching**: Appropriate caching strategies
- **Image Optimization**: Efficient image loading
- **Memory Management**: Proper disposal of resources

## 🌍 Internationalization

The app is structured to support multiple languages:
- `intl` package for date/number formatting
- Centralized string management
- Environment-specific configurations

---

This architecture ensures:
✅ **Scalability** - Easy to add new features
✅ **Maintainability** - Clean, organized code
✅ **Testability** - Dependency injection and separation of concerns
✅ **Performance** - Optimized resource usage
✅ **Security** - Best practices for data protection
