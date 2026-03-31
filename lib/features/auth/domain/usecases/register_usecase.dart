import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import 'package:meal_house/core/error/app_exceptions.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  /// Execute registration use case
  /// 
  /// [email] - User email address
  /// [password] - User password
  /// [confirmPassword] - Password confirmation
  /// [firstName] - User first name
  /// [lastName] - User last name
  /// [mobile] - User mobile number
  /// [role] - User role (optional, defaults to 'user')
  /// [acceptedTerms] - Whether user accepted terms (optional, defaults to true)
  /// 
  /// Returns [User] on successful registration
  /// Throws [ValidationException] if input is invalid
  /// Throws [ServerException] if there's a server error
  Future<User> execute({
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    required String mobile,
    String? role,
    bool? acceptedTerms,
  }) async {
    // Validate required fields
    if (email.isEmpty) {
      throw const ValidationException('Email is required');
    }
    
    if (password.isEmpty) {
      throw const ValidationException('Password is required');
    }
    
    if (firstName.isEmpty) {
      throw const ValidationException('First name is required');
    }
    
    if (lastName.isEmpty) {
      throw const ValidationException('Last name is required');
    }
    
    if (mobile.isEmpty) {
      throw const ValidationException('Mobile number is required');
    }
    
    // Validate email format
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      throw const ValidationException('Please enter a valid email address');
    }
    
    // Validate password
    if (password.length < 6) {
      throw const ValidationException('Password must be at least 6 characters long');
    }
    
    if (password.length > 50) {
      throw const ValidationException('Password is too long');
    }
    
    // Check if passwords match
    if (password != confirmPassword) {
      throw const ValidationException('Passwords do not match');
    }
    
    // Validate name length
    if (firstName.length > 50) {
      throw const ValidationException('First name is too long');
    }
    
    if (lastName.length > 50) {
      throw const ValidationException('Last name is too long');
    }
    
    // Validate name format (letters only)
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(firstName)) {
      throw const ValidationException('First name should only contain letters');
    }
    
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(lastName)) {
      throw const ValidationException('Last name should only contain letters');
    }
    
    // Validate mobile number
    final cleanMobile = mobile.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanMobile.length < 10) {
      throw const ValidationException('Mobile number must be at least 10 digits');
    }
    
    if (cleanMobile.length > 15) {
      throw const ValidationException('Mobile number is too long');
    }
    
    // Check terms acceptance
    if (acceptedTerms != null && !acceptedTerms) {
      throw const ValidationException('You must accept the terms and conditions');
    }
    
    try {
      return await _repository.register(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        mobile: cleanMobile,
        role: role ?? 'user',
        acceptedTerms: acceptedTerms ?? true,
      );
    } on AppException {
      // Re-throw known exceptions
      rethrow;
    } catch (e) {
      // Wrap unknown exceptions
      throw UnknownException('Registration failed: ${e.toString()}');
    }
  }
}
