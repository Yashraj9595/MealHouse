import 'package:MealHouse/core/network/dio_client.dart';
import 'package:MealHouse/features/user/domain/repositories/mess_repository.dart';
import 'package:MealHouse/features/user/data/models/mess_model.dart';
import 'package:MealHouse/features/user/data/models/meal_group_model.dart';

class MessRepositoryImpl implements MessRepository {
  final DioClient _dioClient;

  MessRepositoryImpl(this._dioClient);

  @override
  Future<List<MessModel>> getMesses({
    String? city,
    String? mealType,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (city != null) queryParams['city'] = city;
      if (mealType != null) queryParams['mealType'] = mealType;
      if (search != null) queryParams['search'] = search;

      final response = await _dioClient.get('/messes', queryParameters: queryParams);

      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((mess) => MessModel.fromJson(mess))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load messes');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MessModel> getMessDetails(String id) async {
    try {
      final response = await _dioClient.get('/messes/$id');

      if (response.data['success'] == true) {
        return MessModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load mess details');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<UserMealGroupModel>> getFeaturedMeals() async {
    try {
      final response = await _dioClient.get('/mealgroups');
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((json) => UserMealGroupModel.fromJson(json))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load featured meals');
      }
    } catch (e) {
      rethrow;
    }
  }
}
