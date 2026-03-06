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

      final raw = response.data;
      dynamic inner;

      if (raw is Map<String, dynamic>) {
        if (raw['success'] == false) {
          throw Exception(raw['message'] ?? 'Failed to load messes');
        }
        inner = raw['data'] ?? raw['messes'] ?? raw['items'] ?? raw;
      } else {
        inner = raw;
      }

      List<dynamic> list;
      if (inner is List) {
        list = inner;
      } else if (inner != null) {
        list = [inner];
      } else {
        list = <dynamic>[];
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map((mess) => MessModel.fromJson(mess))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MessModel> getMessDetails(String id) async {
    try {
      final response = await _dioClient.get('/messes/$id');

      final raw = response.data;

      if (raw is Map<String, dynamic>) {
        if (raw['success'] == false) {
          throw Exception(raw['message'] ?? 'Failed to load mess details');
        }
        final inner = raw['data'] ?? raw['mess'] ?? raw;
        if (inner is Map<String, dynamic>) {
          return MessModel.fromJson(inner);
        }
      } else if (raw is List && raw.isNotEmpty && raw.first is Map<String, dynamic>) {
        // Some APIs return a list even for detail endpoints; use the first item.
        return MessModel.fromJson(raw.first as Map<String, dynamic>);
      }

      throw Exception('Failed to load mess details: unexpected response format');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<UserMealGroupModel>> getFeaturedMeals() async {
    try {
      final response = await _dioClient.get('/mealgroups');

      final raw = response.data;
      dynamic inner;

      if (raw is Map<String, dynamic>) {
        if (raw['success'] == false) {
          throw Exception(raw['message'] ?? 'Failed to load featured meals');
        }
        inner = raw['data'] ?? raw['meals'] ?? raw['items'] ?? raw;
      } else {
        inner = raw;
      }

      final list = inner is List ? inner : (inner != null ? [inner] : <dynamic>[]);

      return list
          .whereType<Map<String, dynamic>>()
          .map((json) => UserMealGroupModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
