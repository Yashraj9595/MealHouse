import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MealHouse/features/user/domain/repositories/mess_repository.dart';
import 'package:MealHouse/features/user/data/repositories/mess_repository_impl.dart';
import 'package:MealHouse/features/user/data/models/mess_model.dart';
import 'package:MealHouse/features/user/data/models/meal_group_model.dart';
import '../../../../../core/network/dio_provider.dart';

final messRepositoryProvider = Provider<MessRepository>((ref) {
  return MessRepositoryImpl(ref.watch(dioClientProvider));
});

final messesProvider = FutureProvider<List<MessModel>>((ref) async {
  final repository = ref.watch(messRepositoryProvider);
  return repository.getMesses();
});

final messDetailsProvider = FutureProvider.family<MessModel, String>((ref, id) async {
  final repository = ref.watch(messRepositoryProvider);
  return repository.getMessDetails(id);
});

final featuredMealsProvider = FutureProvider<List<UserMealGroupModel>>((ref) async {
  final repository = ref.watch(messRepositoryProvider);
  return repository.getFeaturedMeals();
});
