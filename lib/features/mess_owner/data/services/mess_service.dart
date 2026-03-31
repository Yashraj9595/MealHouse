import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:meal_house/core/network/api_client.dart';
import 'package:meal_house/core/constants/api_endpoints.dart';
import 'package:meal_house/core/error/app_exceptions.dart';

class MessService {
  final ApiClient _apiClient;

  MessService(this._apiClient);

  Future<Response> getMesses({double? lat, double? lng, double? radius, String? cuisine}) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (lat != null) queryParameters['lat'] = lat;
      if (lng != null) queryParameters['lng'] = lng;
      if (radius != null) queryParameters['radius'] = radius;
      if (cuisine != null) queryParameters['cuisine'] = cuisine;

      return await _apiClient.get(
        ApiEndpoints.messes,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  Future<Response> getMessById(String id) async {
    try {
      return await _apiClient.get('${ApiEndpoints.messes}/$id');
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  Future<Response> getMyMesses() async {
    try {
      return await _apiClient.get(ApiEndpoints.myMesses);
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  Future<Response> createMess(Map<String, dynamic> data) async {
    try {
      return await _apiClient.post(ApiEndpoints.messes, data: data);
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  Future<Response> updateMess(String id, Map<String, dynamic> data) async {
    try {
      return await _apiClient.put('${ApiEndpoints.messes}/$id', data: data);
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  Future<Response> deleteMess(String id) async {
    try {
      return await _apiClient.delete('${ApiEndpoints.messes}/$id');
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  Future<Response> getMenu(String messId) async {
    try {
      return await _apiClient.get('${ApiEndpoints.menus}/$messId');
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  Future<Response> updateMenu(Map<String, dynamic> data) async {
    try {
      return await _apiClient.put(ApiEndpoints.menus, data: data);
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  Future<Response> uploadImages(List<String> imagePaths) async {
    try {
      final List<MultipartFile> files = [];
      for (final path in imagePaths) {
        if (kIsWeb) {
           // On Web, the path is a blob URL. We need a clean Dio instance to fetch it
           // because _apiClient has a baseUrl that would be prepended.
           final response = await Dio().get(path, options: Options(responseType: ResponseType.bytes));
           final fileName = 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg';
           files.add(MultipartFile.fromBytes(response.data as List<int>, filename: fileName));
        } else {
           files.add(await MultipartFile.fromFile(path));
        }
      }

      final formData = FormData.fromMap({
        'images': files,
      });

      return await _apiClient.post(
        '${ApiEndpoints.messes}/upload',
        data: formData,
      );
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  Future<Response> uploadImagesBytes(List<List<int>> bytesList, List<String> fileNames) async {
    try {
      final List<MultipartFile> files = [];
      for (int i = 0; i < bytesList.length; i++) {
         files.add(MultipartFile.fromBytes(bytesList[i], filename: fileNames[i]));
      }

      final formData = FormData.fromMap({
        'images': files,
      });

      return await _apiClient.post(
        '${ApiEndpoints.messes}/upload',
        data: formData,
      );
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  Future<Response> getDashboardStats(String messId) async {
    try {
      return await _apiClient.get('${ApiEndpoints.messDashboardStats}/$messId/stats');
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }
}
