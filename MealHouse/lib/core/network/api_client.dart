import 'package:dio/dio.dart';
import 'package:MealHouse/core/config/env_config.dart';
import 'package:MealHouse/core/constants/api_constants.dart';
import 'package:MealHouse/core/services/secure_storage_service.dart';
import 'package:MealHouse/core/di/injection.dart';

class ApiClient {
  late Dio _dio;
  static final ApiClient _instance = ApiClient._internal();
  
  factory ApiClient() => _instance;
  ApiClient._internal() {
    _initDio();
  }

  void _initDio() {
    _dio = Dio(BaseOptions(
      baseUrl: Environment.config.baseUrl,
      connectTimeout: const Duration(seconds: 10), // Increased timeout
      receiveTimeout: const Duration(seconds: 10), // Increased timeout
      sendTimeout: const Duration(seconds: 10), // Increased timeout
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Connection': 'keep-alive', // Keep connection alive
      },
    ));

    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        final token = await getIt<SecureStorageService>().getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // Handle 401 unauthorized
        if (error.response?.statusCode == 401) {
          // Clear token and navigate to login
          getIt<SecureStorageService>().deleteToken();
          // You can add navigation logic here
        }
        handler.next(error);
      },
    ));

    // Add caching interceptor for better performance
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add cache control for GET requests
        if (options.method == 'GET') {
          options.headers['Cache-Control'] = 'max-age=60'; // Cache for 60 seconds
        }
        handler.next(options);
      },
    ));

    // Add logging interceptor for debug mode
    if (Environment.config.environment == AppEnvironment.dev) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: false, // Disable request body logging for faster performance
        responseBody: false, // Disable response body logging for faster performance
        requestHeader: true,
        responseHeader: false,
      ));
    }
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Handle Dio errors
  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Something went wrong';
        
        switch (statusCode) {
          case 400:
            return 'Bad request: $message';
          case 401:
            return 'Unauthorized: Please login again.';
          case 403:
            return 'Forbidden: You don\'t have permission to access this resource.';
          case 404:
            return 'Not found: The requested resource was not found.';
          case 500:
            return 'Server error: Please try again later.';
          default:
            return 'Error ($statusCode): $message';
        }
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      case DioExceptionType.unknown:
        return 'An unexpected error occurred. Please try again.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  // Get dio instance for custom requests
  Dio get dio => _dio;
}