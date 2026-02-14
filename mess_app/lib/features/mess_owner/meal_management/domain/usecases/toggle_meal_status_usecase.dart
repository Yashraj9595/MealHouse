import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../repositories/meal_repository.dart';

class ToggleMealStatusUseCase {
  final MealRepository repository;

  ToggleMealStatusUseCase(this.repository);

  Future<Either<Failure, void>> call(String messId, String mealGroupId, bool isActive) async {
    return await repository.toggleMealGroupStatus(messId, mealGroupId, isActive);
  }
}
