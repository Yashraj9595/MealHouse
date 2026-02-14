import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/profile_entity.dart';

abstract class UserProfileRepository {
  Future<Either<Failure, UserProfileEntity>> getUserProfile();
  Future<Either<Failure, void>> updateUserProfile(UserProfileEntity profile);
}
