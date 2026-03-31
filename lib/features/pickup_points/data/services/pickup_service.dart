import 'package:dio/dio.dart';
import 'package:meal_house/core/network/api_client.dart';
import 'package:meal_house/core/constants/api_endpoints.dart';
import 'package:meal_house/core/error/app_exceptions.dart';

class PickupService {
  final ApiClient _apiClient;

  PickupService(this._apiClient);

  Future<Response> getAllPickupPoints() async {
    try {
      return await _apiClient.get(ApiEndpoints.pickupPoints);
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  Future<Response> getNearbyPickupPoints(double lat, double lon,
      {int maxDistance = 20000}) async {
    try {
      return await _apiClient.get(
        ApiEndpoints.pickupPointsNearby,
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'maxDistance': maxDistance,
        },
      );
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  Future<Response> createPickupPoint(Map<String, dynamic> data) async {
    try {
      return await _apiClient.post(
        ApiEndpoints.pickupPoints,
        data: data,
      );
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  Future<Response> updatePickupPoint(String id, Map<String, dynamic> data) async {
    try {
      return await _apiClient.put(
        '${ApiEndpoints.pickupPoints}/$id',
        data: data,
      );
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  Future<Response> deletePickupPoint(String id) async {
    try {
      return await _apiClient.delete('${ApiEndpoints.pickupPoints}/$id');
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }
}
