import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/mess_profile_entity.dart';

abstract class MessProfileRepository {
  Future<Either<Failure, MessProfileEntity>> getMessProfile();
  Future<Either<Failure, void>> updateMessProfile(MessProfileEntity profile);
}
