import 'package:MealHouse/core/network/dio_client.dart';
import '../models/meal_group_model.dart';

abstract class MealRemoteDataSource {
  Future<List<MealGroupModel>> getMealGroups(String messId);
  Future<void> createMealGroup(String messId, Map<String, dynamic> data);
  Future<void> updateMealGroup(String mealGroupId, Map<String, dynamic> data);
  Future<void> deleteMealGroup(String mealGroupId);
  Future<void> toggleMealGroupStatus(String mealGroupId, bool isActive);
}

class MealRemoteDataSourceImpl implements MealRemoteDataSource {
  final DioClient dioClient;

  MealRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<MealGroupModel>> getMealGroups(String messId) async {
    try {
      final response = await dioClient.get('/messes/$messId/mealgroups');
      
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => MealGroupModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> createMealGroup(String messId, Map<String, dynamic> data) async {
    try {
      await dioClient.post(
        '/messes/$messId/mealgroups',
        data: data,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateMealGroup(String mealGroupId, Map<String, dynamic> data) async {
    try {
      await dioClient.put(
        '/mealgroups/$mealGroupId',
        data: data,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteMealGroup(String mealGroupId) async {
    try {
      await dioClient.delete('/mealgroups/$mealGroupId');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> toggleMealGroupStatus(String mealGroupId, bool isActive) async {
    try {
      // Using the update endpoint with isActive field
      await dioClient.put(
        '/mealgroups/$mealGroupId',
        data: {'isActive': isActive},
      );
    } catch (e) {
      rethrow;
    }
  }
}
