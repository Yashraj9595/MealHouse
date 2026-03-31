import '../entities/user.dart';
import 'package:meal_house/core/error/app_exceptions.dart';

abstract class AuthRepository {
  /// Login user with email and password
  /// Returns [User] on success
  /// Throws [AuthenticationException] on authentication failure
  Future<User> login(String email, String password);

  /// Register a new user
  /// Returns [User] on success
  /// Throws [ValidationException] on validation failure
  /// Throws [ServerException] on server error
  Future<User> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    required String mobile,
    String? role,
    bool? acceptedTerms,
  });

  /// Logout current user
  /// Throws [NetworkException] on network error
  Future<void> logout();

  /// Get current user profile
  /// Returns [User] on success
  /// Throws [AuthenticationException] if not authenticated
  Future<User> getCurrentUser();

  /// Update user profile
  /// Returns updated [User] on success
  /// Throws [ValidationException] on validation failure
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? mobile,
    String? profileImage,
    List<SavedLocation>? savedLocations,
    PickupPreferences? pickupPreferences,
  });

  /// Upload profile photo
  Future<String> uploadProfilePhoto(List<int> bytes, String fileName);

  /// Change user password
  /// Throws [ValidationException] on validation failure
  /// Throws [AuthenticationException] if current password is incorrect
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });

  /// Request password reset
  /// Throws [ValidationException] if email is invalid
  Future<void> forgotPassword(String email);

  /// Reset password with OTP
  /// Throws [ValidationException] if OTP or new password is invalid
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  });

  /// Verify OTP for various operations
  /// Throws [ValidationException] if OTP is invalid
  Future<bool> verifyOtp({
    required String email,
    required String otp,
    required String type,
  });

  /// Refresh authentication token
  /// Returns new token on success
  /// Throws [AuthenticationException] if refresh token is invalid
  Future<String> refreshToken();

  /// Check if user is authenticated
  /// Returns true if user has valid token
  Future<bool> isAuthenticated();

  /// Get authentication token
  /// Returns token if available, null otherwise
  Future<String?> getAuthToken();

  /// Clear authentication data
  /// Removes tokens and user data from storage
  Future<void> clearAuthData();
}
