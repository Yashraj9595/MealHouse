import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/config/app_config.dart';
import '../constants/api_endpoints.dart';
import 'package:meal_house/core/constants/app_constants.dart';
import 'package:meal_house/core/error/app_exceptions.dart';

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    webOptions: WebOptions(
      dbName: 'MealHouse',
      publicKey: 'MealHouseKey',
    ),
  );
  
  // Base URL from environment configuration
  static String get baseUrl => AppConfig.apiBaseUrl;

  static String _withTrailingSlash(String url) =>
      url.endsWith('/') ? url : '$url/';

  ApiClient() : _dio = Dio(BaseOptions(
    baseUrl: _withTrailingSlash(baseUrl),
    connectTimeout: AppConfig.connectTimeout,
    receiveTimeout: AppConfig.receiveTimeout,
    sendTimeout: AppConfig.sendTimeout,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  )) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add authentication token
        final token = await _storage.read(key: AppConstants.accessTokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        // Add request logging in debug mode
        if (AppConfig.enableLogging) {
          print('🌐 API Request: ${options.method} ${options.uri}');
          if (options.data != null) {
            print('📤 Request Data: ${options.data}');
          }
        }
        
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Log response in debug mode
        if (AppConfig.enableLogging) {
          print('✅ API Response: ${response.statusCode} ${response.requestOptions.uri}');
          print('📥 Response Data: ${response.data}');
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        // Log error in debug mode
        if (AppConfig.enableLogging) {
          print('❌ API Error: ${e.requestOptions.method} ${e.requestOptions.uri}');
          print('📄 Error: ${e.message}');
          if (e.response?.data != null) {
            print('📋 Error Response: ${e.response?.data}');
          }
        }
        
        // Handle token refresh
        if (e.response?.statusCode == 401) {
          try {
            await _refreshToken();
            // Retry the original request
            final token = await _storage.read(key: AppConstants.accessTokenKey);
            if (token != null) {
              e.requestOptions.headers['Authorization'] = 'Bearer $token';
              final response = await _dio.fetch(e.requestOptions);
              return handler.resolve(response);
            }
          } catch (refreshError) {
            // Refresh failed, clear tokens and proceed with error
            await clearTokens();
          }
        }
        
        return handler.next(e);
      },
    ));
  }

  Future<void> _refreshToken() async {
    final refreshToken = await _storage.read(key: AppConstants.refreshTokenKey);
    if (refreshToken == null) {
      throw const AuthenticationException('No refresh token available');
    }
    
    try {
      final response = await _dio.post(ApiEndpoints.refreshToken, data: {
        'refreshToken': refreshToken,
      });
      
      if (response.statusCode == 200 && response.data['data'] != null) {
        final token = response.data['data']['token'];
        final newRefreshToken = response.data['data']['refreshToken'];
        final userData = response.data['data']['user'];
        final role = userData['role'];
        
        await saveToken(token);
        await saveUserRole(role);
        if (newRefreshToken != null) {
          await _storage.write(key: AppConstants.refreshTokenKey, value: newRefreshToken);
        }
      }
    } catch (e) {
      throw AuthenticationException('Token refresh failed');
    }
  }

  Dio get dio => _dio;

  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.accessTokenKey, value: token);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  Future<void> saveUserRole(String role) async {
    await _storage.write(key: AppConstants.userRoleKey, value: role);
  }

  Future<String?> getUserRole() async {
    return await _storage.read(key: AppConstants.userRoleKey);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.refreshTokenKey);
  }

  // Generic GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  // Generic POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  // Generic PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  // Generic DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  // Generic PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  // Upload file
  Future<Response<T>> upload<T>(
    String path,
    String filePath, {
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
    Options? options,
  }) async {
    try {
      final formData = FormData.fromMap({
        ...?data,
        'file': await MultipartFile.fromFile(filePath),
      });
      
      return await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: options,
      );
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  // Download file
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Options? options,
  }) async {
    try {
      return await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        options: options,
      );
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }
}
