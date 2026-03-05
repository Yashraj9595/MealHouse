import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../../core/error/failures.dart';
import '../../domain/entities/meal_group_entity.dart';
import '../../domain/repositories/meal_repository.dart';
import '../models/meal_group_model.dart';
import '../datasource/meal_remote_datasource.dart';

class MealRepositoryImpl implements MealRepository {
  final MealRemoteDataSource remoteDataSource;

  MealRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<MealGroupEntity>>> getMealGroups(String messId) async {
    try {
      final meals = await remoteDataSource.getMealGroups(messId);
      return Right(meals);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.response?.data['message'] ?? 'Failed to fetch meals',
      ));
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

      await remoteDataSource.createMealGroup(messId, model.toJson());
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.response?.data['message'] ?? 'Failed to create meal',
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateMealGroup(String messId, MealGroupEntity group) async {
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

      await remoteDataSource.updateMealGroup(group.id, model.toJson());
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.response?.data['message'] ?? 'Failed to update meal',
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMealGroup(String messId, String mealGroupId) async {
    try {
      await remoteDataSource.deleteMealGroup(mealGroupId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.response?.data['message'] ?? 'Failed to delete meal',
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleMealGroupStatus(String messId, String mealGroupId, bool isActive) async {
    try {
      await remoteDataSource.toggleMealGroupStatus(mealGroupId, isActive);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.response?.data['message'] ?? 'Failed to update status',
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

