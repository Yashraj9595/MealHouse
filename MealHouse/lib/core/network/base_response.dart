import 'package:dio/dio.dart';

/// Standard API Response Wrapper
/// All API responses should follow this format:
/// {
///   "success": true,
///   "message": "Operation successful",
///   "data": {...}
/// }
class BaseResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? error;

  BaseResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory BaseResponse.fromJson(Response response) {
    final data = response.data;
    
    // Handle different response formats
    if (data is Map<String, dynamic>) {
      // Standard format with success field
      if (data.containsKey('success')) {
        return BaseResponse<T>(
          success: data['success'] ?? false,
          message: data['message'] ?? (data['success'] == true ? 'Success' : 'Failed'),
          data: data['data'],
          error: data['error'],
        );
      }
      
      // Direct data format (no success field)
      return BaseResponse<T>(
        success: response.statusCode == 200,
        message: response.statusCode == 200 ? 'Success' : 'Failed',
        data: data as T?,
      );
    }
    
    // Direct response (not a map)
    return BaseResponse<T>(
      success: response.statusCode == 200,
      message: response.statusCode == 200 ? 'Success' : 'Failed',
      data: data as T?,
    );
  }

  /// Helper method to extract list data from response
  List<T> getListData<T>(T Function(dynamic) fromJson) {
    if (data is List) {
      return (data as List).map((item) => fromJson(item)).toList();
    }
    return [];
  }

  /// Helper method to extract single object data
  T? getData<T>(T Function(dynamic) fromJson) {
    if (data != null) {
      return fromJson(data);
    }
    return null;
  }

  @override
  String toString() {
    return 'BaseResponse(success: $success, message: $message, data: $data, error: $error)';
  }
}

/// Extension to easily convert Dio Response to BaseResponse
extension ResponseExtension on Response {
  BaseResponse<T> toBaseResponse<T>() {
    return BaseResponse<T>.fromJson(this);
  }
}
