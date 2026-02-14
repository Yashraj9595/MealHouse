import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/profile_entity.dart';
import '../repositories/user_profile_repository.dart';

class UpdateUserProfileUseCase {
  final UserProfileRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<Either<Failure, void>> call(UserProfileEntity profile) async {
    return await repository.updateUserProfile(profile);
  }
}
