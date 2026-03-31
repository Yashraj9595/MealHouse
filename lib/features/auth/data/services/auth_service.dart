import 'package:dio/dio.dart';
import 'package:meal_house/core/network/api_client.dart';
import 'package:meal_house/core/constants/api_endpoints.dart';
import 'package:meal_house/core/error/app_exceptions.dart';
import '../../domain/entities/user.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<Response> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      if (response.statusCode == 200 && response.data['data'] != null) {
        final token = response.data['data']['token'];
        final refreshToken = response.data['data']['refreshToken'];
        final userData = response.data['data']['user'];
        final role = userData != null ? userData['role'] : null;
        
        if (token != null) {
          await _apiClient.saveToken(token);
        }
        if (refreshToken != null) {
          await _apiClient.saveRefreshToken(refreshToken);
        }
        if (role != null) {
          await _apiClient.saveUserRole(role);
        }
      }
      
      return response;
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  Future<Response> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    required String mobile,
    String? role,
    bool? acceptedTerms,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: {
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
          'firstName': firstName,
          'lastName': lastName,
          'mobile': mobile,
          'role': role ?? 'user',
          'acceptedTerms': acceptedTerms ?? true,
        },
      );
      
      return response;
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  Future<Response> forgotPassword(String email) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.forgotPassword,
        data: {
          'email': email,
        },
      );
      
      return response;
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  Future<Response> verifyOtp({
    required String email,
    required String otp,
    required String type,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.verifyOtp,
        data: {
          'email': email,
          'otp': otp,
          'type': type,
        },
      );
      
      return response;
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  Future<Response> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.resetPassword,
        data: {
          'email': email,
          'otp': otp,
          'password': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
      
      return response;
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(ApiEndpoints.logout);
    } finally {
      await _apiClient.clearTokens();
    }
  }

  Future<Response> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.userProfile);
      return response;
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  Future<Response> updateProfile({
    String? firstName,
    String? lastName,
    String? mobile,
    String? profileImage,
    List<SavedLocation>? savedLocations,
    PickupPreferences? pickupPreferences,
  }) async {
    try {
      final data = <String, dynamic>{};
      
      if (firstName != null) data['firstName'] = firstName;
      if (lastName != null) data['lastName'] = lastName;
      if (mobile != null) data['mobile'] = mobile;
      if (profileImage != null) data['profileImage'] = profileImage;
      if (savedLocations != null) {
        data['savedLocations'] = savedLocations.map((e) => e.toJson()).toList();
      }
      if (pickupPreferences != null) {
        data['pickupPreferences'] = pickupPreferences.toJson();
      }
      
      final response = await _apiClient.put(
        ApiEndpoints.updateProfile,
        data: data,
      );
      
      return response;
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  Future<Response> uploadProfilePhoto(List<int> bytes, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'profileImage': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
      });

      final response = await _apiClient.post(
        ApiEndpoints.uploadProfilePhoto,
        data: formData,
      );

      return response;
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  Future<Response> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
      
      return response;
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  Future<String> refreshToken() async {
    try {
      final refreshToken = await _apiClient.getRefreshToken();
      if (refreshToken == null) {
        throw const AuthenticationException('No refresh token available');
      }
      
      final response = await _apiClient.post(
        ApiEndpoints.refreshToken,
        data: {
          'refreshToken': refreshToken,
        },
      );
      
      if (response.statusCode == 200 && response.data['data'] != null) {
        final newAccessToken = response.data['data']['token'];
        final newRefreshToken = response.data['data']['refreshToken'];
        
        await _apiClient.saveToken(newAccessToken);
        if (newRefreshToken != null) {
          await _apiClient.saveRefreshToken(newRefreshToken);
        }
        
        return newAccessToken;
      } else {
        throw const AuthenticationException('Token refresh failed');
      }
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  Future<bool> isAuthenticated() async {
    // This is a simple check - in a real app, you might want to validate the token
    final token = await _apiClient.getToken();
    return token != null;
  }

  Future<String?> getAuthToken() async {
    return await _apiClient.getToken();
  }

  Future<void> clearAuthData() async {
    await _apiClient.clearTokens();
  }
}
