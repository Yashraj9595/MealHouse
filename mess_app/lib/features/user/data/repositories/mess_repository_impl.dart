import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/mess_repository.dart';
import '../models/mess_model.dart';

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
      final response = await _dioClient.get(
        '/messes',
        queryParameters: {
          if (city != null) 'city': city,
          if (mealType != null) 'mealType': mealType,
          if (search != null) 'search': search,
        },
      );

      if (response.data['success'] == true) {
        final List messesJson = response.data['data'];
        return messesJson.map((json) => MessModel.fromJson(json)).toList();
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
}
