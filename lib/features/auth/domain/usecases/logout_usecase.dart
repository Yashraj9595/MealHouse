import '../repositories/auth_repository.dart';
import 'package:meal_house/core/error/app_exceptions.dart';

class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  /// Execute logout use case
  /// 
  /// Logs out the current user and clears authentication data
  /// Throws [NetworkException] if there's a network error
  Future<void> execute() async {
    try {
      await _repository.logout();
    } on AppException {
      // Re-throw known exceptions
      rethrow;
    } catch (e) {
      // Wrap unknown exceptions
      throw UnknownException('Logout failed: ${e.toString()}');
    }
  }
}
