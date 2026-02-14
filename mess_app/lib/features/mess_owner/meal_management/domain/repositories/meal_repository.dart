import '../entities/meal_group_entity.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/app_export.dart';

abstract class MealRepository {
  Future<Either<Failure, List<MealGroupEntity>>> getMealGroups(String messId);
  Future<Either<Failure, void>> createMealGroup(String messId, MealGroupEntity group);
  Future<Either<Failure, void>> updateMealGroup(String messId, MealGroupEntity group);
  Future<Either<Failure, void>> deleteMealGroup(String messId, String mealGroupId);
  Future<Either<Failure, void>> toggleMealGroupStatus(String messId, String mealGroupId, bool isActive);
}
