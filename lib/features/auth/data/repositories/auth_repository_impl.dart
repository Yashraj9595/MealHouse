import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/auth_service.dart';
import 'package:meal_house/core/error/app_exceptions.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Future<User> login(String email, String password) async {
    try {
      final response = await _authService.login(email, password);
      
      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data['data'];
        
        if (userData['user'] != null) {
          return User.fromJson(userData['user']);
        } else {
          throw const ServerException('Invalid response format');
        }
      } else {
        throw ServerException(
          response.data?['message'] ?? 'Login failed',
          code: response.statusCode?.toString(),
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Login error: ${e.toString()}');
    }
  }

  @override
  Future<User> register({
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
      final response = await _authService.register(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        firstName: firstName,
        lastName: lastName,
        mobile: mobile,
        role: role ?? 'user',
        acceptedTerms: acceptedTerms ?? true,
      );
      
      if (response.statusCode == 201 && response.data != null) {
        final userData = response.data['data'];
        
        if (userData['user'] != null) {
          return User.fromJson(userData['user']);
        } else {
          throw const ServerException('Invalid response format');
        }
      } else {
        throw ServerException(
          response.data?['message'] ?? 'Registration failed',
          code: response.statusCode?.toString(),
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Registration error: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _authService.logout();
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Logout error: ${e.toString()}');
    }
  }

  @override
  Future<User> getCurrentUser() async {
    try {
      final response = await _authService.getCurrentUser();
      
      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data['data'];
        
        if (userData['user'] != null) {
          return User.fromJson(userData['user']);
        } else {
          throw const ServerException('Invalid response format');
        }
      } else {
        throw ServerException(
          response.data?['message'] ?? 'Failed to get user profile',
          code: response.statusCode?.toString(),
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Get current user error: ${e.toString()}');
    }
  }

  @override
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? mobile,
    String? profileImage,
    List<SavedLocation>? savedLocations,
    PickupPreferences? pickupPreferences,
  }) async {
    try {
      final response = await _authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        mobile: mobile,
        profileImage: profileImage,
        savedLocations: savedLocations,
        pickupPreferences: pickupPreferences,
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data['data'];
        
        if (userData['user'] != null) {
          return User.fromJson(userData['user']);
        } else {
          throw const ServerException('Invalid response format');
        }
      } else {
        throw ServerException(
          response.data?['message'] ?? 'Failed to update profile',
          code: response.statusCode?.toString(),
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Update profile error: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadProfilePhoto(List<int> bytes, String fileName) async {
    try {
      final response = await _authService.uploadProfilePhoto(bytes, fileName);
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data']['profileImage'] as String;
      }
      throw const AuthenticationException('Failed to upload photo');
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthenticationException('Unexpected error during photo upload: $e');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      
      if (response.statusCode != 200) {
        throw ServerException(
          response.data?['message'] ?? 'Failed to change password',
          code: response.statusCode?.toString(),
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Change password error: ${e.toString()}');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      final response = await _authService.forgotPassword(email);
      
      if (response.statusCode != 200) {
        throw ServerException(
          response.data?['message'] ?? 'Failed to send password reset email',
          code: response.statusCode?.toString(),
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Forgot password error: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _authService.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      
      if (response.statusCode != 200) {
        throw ServerException(
          response.data?['message'] ?? 'Failed to reset password',
          code: response.statusCode?.toString(),
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Reset password error: ${e.toString()}');
    }
  }

  @override
  Future<bool> verifyOtp({
    required String email,
    required String otp,
    required String type,
  }) async {
    try {
      final response = await _authService.verifyOtp(
        email: email,
        otp: otp,
        type: type,
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return response.data['success'] ?? false;
      } else {
        throw ServerException(
          response.data?['message'] ?? 'Failed to verify OTP',
          code: response.statusCode?.toString(),
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Verify OTP error: ${e.toString()}');
    }
  }

  @override
  Future<String> refreshToken() async {
    try {
      final token = await _authService.refreshToken();
      return token;
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Refresh token error: ${e.toString()}');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return await _authService.isAuthenticated();
  }

  @override
  Future<String?> getAuthToken() async {
    return _authService.getAuthToken();
  }

  @override
  Future<void> clearAuthData() async {
    await _authService.clearAuthData();
  }
}
