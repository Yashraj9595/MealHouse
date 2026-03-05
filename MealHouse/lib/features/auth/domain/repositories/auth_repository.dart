import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> register(Map<String, dynamic> data);
  Future<Either<Failure, UserEntity>> getMe();
  Future<Either<Failure, UserEntity>> updateDetails(Map<String, dynamic> data);
  Future<Either<Failure, void>> logout();
}
