import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/app_export.dart';
import '../../domain/repositories/meal_repository.dart';
import '../../domain/usecases/get_meal_groups_usecase.dart';
import '../../domain/usecases/create_meal_group_usecase.dart';
import '../../domain/usecases/update_meal_group_usecase.dart';
import '../../domain/usecases/delete_meal_usecase.dart';
import '../../domain/usecases/toggle_meal_status_usecase.dart';
import '../../data/repositories/meal_repository_impl.dart';
import '../../domain/entities/meal_group_entity.dart';

import 'package:MealHouse/core/network/dio_provider.dart';

// Repository Provider
final mealRepositoryProvider = Provider<MealRepository>((ref) {
  return MealRepositoryImpl(dio: ref.watch(dioProvider));
});

// Use Case Providers
final getMealGroupsUseCaseProvider = Provider((ref) => GetMealGroupsUseCase(ref.watch(mealRepositoryProvider)));
final createMealGroupUseCaseProvider = Provider((ref) => CreateMealGroupUseCase(ref.watch(mealRepositoryProvider)));
final updateMealGroupUseCaseProvider = Provider((ref) => UpdateMealGroupUseCase(ref.watch(mealRepositoryProvider)));
final deleteMealUseCaseProvider = Provider((ref) => DeleteMealUseCase(ref.watch(mealRepositoryProvider)));
final toggleMealStatusUseCaseProvider = Provider((ref) => ToggleMealStatusUseCase(ref.watch(mealRepositoryProvider)));

// State Provider for List
final mealListProvider = FutureProvider.family<List<MealGroupEntity>, String>((ref, messId) async {
  final useCase = ref.watch(getMealGroupsUseCaseProvider);
  final result = await useCase(messId);
  return result.fold(
    (failure) => throw failure, // Ideally handle specific failure types or wrap in specific error state
    (meals) => meals,
  );
});
