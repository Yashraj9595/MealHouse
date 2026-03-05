import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/meal_group_entity.dart';
import '../repositories/meal_repository.dart';

class GetMealGroupsUseCase {
  final MealRepository repository;

  GetMealGroupsUseCase(this.repository);

  Future<Either<Failure, List<MealGroupEntity>>> call(String messId) async {
    return await repository.getMealGroups(messId);
  }
}
