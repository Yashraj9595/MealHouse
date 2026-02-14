import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../repositories/meal_repository.dart';

class DeleteMealUseCase {
  final MealRepository repository;

  DeleteMealUseCase(this.repository);

  Future<Either<Failure, void>> call(String messId, String mealGroupId) async {
    return await repository.deleteMealGroup(messId, mealGroupId);
  }
}
