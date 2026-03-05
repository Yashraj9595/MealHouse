import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/meal_group_entity.dart';
import '../repositories/meal_repository.dart';

class UpdateMealGroupUseCase {
  final MealRepository repository;

  UpdateMealGroupUseCase(this.repository);

  Future<Either<Failure, void>> call(String messId, MealGroupEntity group) async {
    return await repository.updateMealGroup(messId, group);
  }
}
