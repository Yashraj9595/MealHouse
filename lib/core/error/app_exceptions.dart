import 'package:dio/dio.dart';

abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;
  
  const AppException(this.message, {this.code, this.details});
  
  @override
  String toString() => message;
}

class ServerException extends AppException {
  const ServerException(super.message, {super.code, super.details});
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.details});
}

class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.details});
}

class AuthenticationException extends AppException {
  const AuthenticationException(super.message, {super.code, super.details});
}

class AuthorizationException extends AppException {
  const AuthorizationException(super.message, {super.code, super.details});
}

class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.code, super.details});
}

class TimeoutException extends AppException {
  const TimeoutException(super.message, {super.code, super.details});
}

class CacheException extends AppException {
  const CacheException(super.message, {super.code, super.details});
}

class ParseException extends AppException {
  const ParseException(super.message, {super.code, super.details});
}

class UnknownException extends AppException {
  const UnknownException(super.message, {super.code, super.details});
}

class ExceptionHandler {
  static AppException handleException(dynamic exception) {
    if (exception is AppException) {
      return exception;
    }
    
    if (exception is DioException) {
      return _handleDioException(exception);
    }
    
    if (exception is FormatException) {
      return const ParseException('Invalid data format');
    }
    
    if (exception is TypeError) {
      return const ParseException('Data type error');
    }
    
    return UnknownException(
      exception.toString(),
      details: exception,
    );
  }
  
  static AppException _handleDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException('Connection timeout');
      
      case DioExceptionType.badResponse:
        return _handleHttpException(exception);
      
      case DioExceptionType.cancel:
        return const NetworkException('Request cancelled');
      
      case DioExceptionType.connectionError:
        return const NetworkException('No internet connection');
      
      case DioExceptionType.unknown:
        return UnknownException(
          exception.message ?? 'Unknown network error',
          details: exception,
        );
      
      default:
        return UnknownException(
          exception.message ?? 'Unknown error',
          details: exception,
        );
    }
  }
  
  static AppException _handleHttpException(DioException exception) {
    final statusCode = exception.response?.statusCode;
    final message = exception.response?.data?['message'] ?? 'Server error';
    
    switch (statusCode) {
      case 400:
        return ValidationException(message);
      case 401:
        return const AuthenticationException('Unauthorized access');
      case 403:
        return const AuthorizationException('Access forbidden');
      case 404:
        return const NotFoundException('Resource not found');
      case 408:
        return const TimeoutException('Request timeout');
      case 429:
        return const ServerException('Too many requests');
      case 500:
        return const ServerException('Internal server error');
      case 502:
        return const ServerException('Bad gateway');
      case 503:
        return const ServerException('Service unavailable');
      case 504:
        return const ServerException('Gateway timeout');
      default:
        return ServerException(message, code: statusCode?.toString());
    }
  }
  
  static String getErrorMessage(AppException exception) {
    switch (exception.runtimeType) {
      case ServerException:
        return 'Server error: ${exception.message}';
      case NetworkException:
        return 'Network error: ${exception.message}';
      case ValidationException:
        return 'Validation error: ${exception.message}';
      case AuthenticationException:
        return 'Authentication error: ${exception.message}';
      case AuthorizationException:
        return 'Authorization error: ${exception.message}';
      case NotFoundException:
        return 'Not found: ${exception.message}';
      case TimeoutException:
        return 'Timeout: ${exception.message}';
      case CacheException:
        return 'Cache error: ${exception.message}';
      case ParseException:
        return 'Parse error: ${exception.message}';
      default:
        return 'Error: ${exception.message}';
    }
  }
}
