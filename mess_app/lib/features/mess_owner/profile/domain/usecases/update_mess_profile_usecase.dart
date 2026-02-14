import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/mess_profile_entity.dart';
import '../repositories/mess_profile_repository.dart';

class UpdateMessProfileUseCase {
  final MessProfileRepository repository;

  UpdateMessProfileUseCase(this.repository);

  Future<Either<Failure, void>> call(MessProfileEntity profile) async {
    return await repository.updateMessProfile(profile);
  }
}
