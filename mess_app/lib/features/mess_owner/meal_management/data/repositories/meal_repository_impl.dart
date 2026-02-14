import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../../core/error/failures.dart';
import '../../domain/entities/meal_group_entity.dart';
import '../../domain/repositories/meal_repository.dart';
import '../models/meal_group_model.dart';

class MealRepositoryImpl implements MealRepository {
  final Dio dio;

  MealRepositoryImpl({required this.dio});

  @override
  Future<Either<Failure, List<MealGroupEntity>>> getMealGroups(String messId) async {
    try {
      final response = await dio.get('/api/messes/$messId/mealgroups');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final List<MealGroupEntity> meals = data.map((json) => MealGroupModel.fromJson(json)).toList();
        return Right(meals);
      } else {
        return Left(ServerFailure(message: response.statusMessage ?? 'Failed to fetch meals'));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createMealGroup(String messId, MealGroupEntity group) async {
    try {
      final model = MealGroupModel(
        id: group.id,
        title: group.title,
        price: group.price,
        items: group.items,
        isActive: group.isActive,
        imageUrl: group.imageUrl,
        videoUrl: group.videoUrl,
        availableQuantity: group.availableQuantity,
        mealType: group.mealType,
      );

      final response = await dio.post(
        '/api/messes/$messId/mealgroups',
        data: model.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return const Right(null);
      } else {
        return Left(ServerFailure(message: response.statusMessage ?? 'Failed to create meal'));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateMealGroup(String messId, MealGroupEntity group) async {
     // Note: API doc might use a specific endpoint for updating, assuming standard REST for now or similar to create
     // The API Test doc showed update Tiffin Availability, but not full update. 
     // For now, I'll assume a PUT exists at /api/mealgroups/:id or similar.
     // If strictly following API_TESTING.md, full update might not be documented, but I will implement a placeholder or standard REST call.
    try {
      // Assuming endpoint: /api/mealgroups/:id
      final model = MealGroupModel(
        id: group.id,
        title: group.title,
        price: group.price,
        items: group.items,
        isActive: group.isActive,
        imageUrl: group.imageUrl,
        videoUrl: group.videoUrl,
        availableQuantity: group.availableQuantity,
        mealType: group.mealType,
      );

      final response = await dio.put(
        '/api/mealgroups/${group.id}',
         data: model.toJson(),
      );

       if (response.statusCode == 200) {
        return const Right(null);
      } else {
        return Left(ServerFailure(message: response.statusMessage ?? 'Failed to update meal'));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMealGroup(String messId, String mealGroupId) async {
    try {
       final response = await dio.delete('/api/mealgroups/$mealGroupId');

       if (response.statusCode == 200) {
        return const Right(null);
      } else {
        return Left(ServerFailure(message: response.statusMessage ?? 'Failed to delete meal'));
      }
    } catch (e) {
       return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleMealGroupStatus(String messId, String mealGroupId, bool isActive) async {
   // This might need a specific endpoint if not generic update. 
   // Assuming part of update
    try {
      final response = await dio.patch(
        '/api/mealgroups/$mealGroupId/status',
         data: {'isActive': isActive},
      );

       if (response.statusCode == 200) {
        return const Right(null);
      } else {
        return Left(ServerFailure(message: response.statusMessage ?? 'Failed to update status'));
      }
    } catch (e) {
       return Left(ServerFailure(message: e.toString()));
    }
  }
}
