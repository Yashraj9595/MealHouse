import 'package:meal_house/core/error/app_exceptions.dart';
import '../../domain/models/mess_model.dart';
import '../../domain/models/menu_model.dart';
import '../../domain/models/dashboard_stats_model.dart';
import '../../domain/repositories/mess_repository.dart';
import '../services/mess_service.dart';

class MessRepositoryImpl implements MessRepository {
  final MessService _messService;

  MessRepositoryImpl(this._messService);

  @override
  Future<List<MessModel>> getMesses({double? lat, double? lng, double? radius, String? cuisine}) async {
    try {
      final response = await _messService.getMesses(
        lat: lat,
        lng: lng,
        radius: radius,
        cuisine: cuisine,
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> messesData = response.data['data'] ?? [];
        return messesData.map((json) => MessModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          response.data?['message'] ?? 'Failed to fetch messes',
          code: response.statusCode?.toString(),
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Fetch messes error: ${e.toString()}');
    }
  }

  @override
  Future<MessModel> getMessById(String id) async {
    try {
      final response = await _messService.getMessById(id);

      if (response.statusCode == 200 && response.data != null) {
        return MessModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data?['message'] ?? 'Failed to fetch mess details',
          code: response.statusCode?.toString(),
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Fetch mess details error: ${e.toString()}');
    }
  }

  @override
  Future<List<MessModel>> getMyMesses() async {
    try {
      final response = await _messService.getMyMesses();

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> messesData = response.data['data'] ?? [];
        return messesData.map((json) => MessModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          response.data?['message'] ?? 'Failed to fetch your messes',
          code: response.statusCode?.toString(),
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Fetch my messes error: ${e.toString()}');
    }
  }

  @override
  Future<MessModel> createMess(MessModel mess) async {
    try {
      final response = await _messService.createMess(mess.toJson());

      if (response.statusCode == 201 && response.data != null) {
        return MessModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data?['message'] ?? 'Failed to create mess',
          code: response.statusCode?.toString(),
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Create mess error: ${e.toString()}');
    }
  }

  @override
  Future<MessModel> updateMess(String id, Map<String, dynamic> updates) async {
    try {
      final response = await _messService.updateMess(id, updates);

      if (response.statusCode == 200 && response.data != null) {
        return MessModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data?['message'] ?? 'Failed to update mess',
          code: response.statusCode?.toString(),
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Update mess error: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteMess(String id) async {
    try {
      final response = await _messService.deleteMess(id);

      if (response.statusCode != 200) {
        throw ServerException(
          response.data?['message'] ?? 'Failed to delete mess',
          code: response.statusCode?.toString(),
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Delete mess error: ${e.toString()}');
    }
  }

  @override
  Future<MenuModel> getMenu(String messId) async {
    try {
      final response = await _messService.getMenu(messId);

      if (response.statusCode == 200 && response.data != null) {
        return MenuModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data?['message'] ?? 'Failed to fetch menu',
          code: response.statusCode?.toString(),
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Fetch menu error: ${e.toString()}');
    }
  }

  @override
  Future<MenuModel> updateMenu(MenuModel menu) async {
    try {
      final response = await _messService.updateMenu(menu.toJson());

      if (response.statusCode == 200 && response.data != null) {
        return MenuModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data?['message'] ?? 'Failed to update menu',
          code: response.statusCode?.toString(),
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Update menu error: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> uploadImages(List<String> imagePaths) async {
    try {
      final response = await _messService.uploadImages(imagePaths);

      if (response.statusCode == 200 && response.data != null) {
        return List<String>.from(response.data['data']);
      } else {
        throw ServerException(
          response.data?['message'] ?? 'Failed to upload images',
          code: response.statusCode?.toString(),
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Upload images error: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> uploadImagesBytes(List<List<int>> bytesList, List<String> fileNames) async {
    try {
      final response = await _messService.uploadImagesBytes(bytesList, fileNames);

      if (response.statusCode == 200 && response.data != null) {
        return List<String>.from(response.data['data']);
      } else {
        throw ServerException(
          response.data?['message'] ?? 'Failed to upload images',
          code: response.statusCode?.toString(),
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Upload images error: ${e.toString()}');
    }
  }

  @override
  Future<DashboardStatsModel> getDashboardStats(String messId) async {
    try {
      final response = await _messService.getDashboardStats(messId);

      if (response.statusCode == 200 && response.data != null) {
        return DashboardStatsModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data?['message'] ?? 'Failed to fetch dashboard stats',
          code: response.statusCode?.toString(),
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException('Fetch dashboard stats error: ${e.toString()}');
    }
  }
}

