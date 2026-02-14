import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/mess_profile_entity.dart';
import '../repositories/mess_profile_repository.dart';

class GetMessProfileUseCase {
  final MessProfileRepository repository;

  GetMessProfileUseCase(this.repository);

  Future<Either<Failure, MessProfileEntity>> call() async {
    return await repository.getMessProfile();
  }
}
