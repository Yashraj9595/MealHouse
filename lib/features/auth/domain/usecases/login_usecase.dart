import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import 'package:meal_house/core/error/app_exceptions.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  /// Execute login use case
  /// 
  /// [email] - User email address
  /// [password] - User password
  /// 
  /// Returns [User] on successful login
  /// Throws [ValidationException] if input is invalid
  /// Throws [AuthenticationException] if credentials are wrong
  /// Throws [NetworkException] if there's a network error
  /// Throws [ServerException] if there's a server error
  Future<User> execute(String email, String password) async {
    // Validate input
    if (email.isEmpty) {
      throw const ValidationException('Email is required');
    }
    
    if (password.isEmpty) {
      throw const ValidationException('Password is required');
    }
    
    // Basic email format validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      throw const ValidationException('Please enter a valid email address');
    }
    
    // Basic password validation
    if (password.length < 6) {
      throw const ValidationException('Password must be at least 6 characters long');
    }
    
    try {
      return await _repository.login(email, password);
    } on AppException {
      // Re-throw known exceptions
      rethrow;
    } catch (e) {
      // Wrap unknown exceptions
      throw UnknownException('Login failed: ${e.toString()}');
    }
  }
}
