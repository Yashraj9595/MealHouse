import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/profile_entity.dart';
import '../repositories/user_profile_repository.dart';

class GetUserProfileUseCase {
  final UserProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<Either<Failure, UserProfileEntity>> call() async {
    return await repository.getUserProfile();
  }
}
