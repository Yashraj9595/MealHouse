import 'package:dio/dio.dart';
import 'package:meal_house/core/network/api_client.dart';
import 'package:meal_house/core/constants/api_endpoints.dart';
import 'package:meal_house/core/error/app_exceptions.dart';

class OrderService {
  final ApiClient _apiClient;

  OrderService(this._apiClient);

  Future<Response> createOrder(Map<String, dynamic> data) async {
    try {
      return await _apiClient.post(ApiEndpoints.orders, data: data);
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  Future<Response> getMyOrders() async {
    try {
      return await _apiClient.get(ApiEndpoints.myOrders);
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  Future<Response> getMessOrders(String messId) async {
    try {
      return await _apiClient.get('${ApiEndpoints.messOrders}/$messId');
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  Future<Response> updateOrderStatus(String orderId, String status) async {
    try {
      return await _apiClient.patch(
        ApiEndpoints.updateOrderStatus,
        data: {
          'orderId': orderId,
          'status': status,
        },
      );
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  Future<Response> getOrderById(String orderId) async {
    try {
      return await _apiClient.get('${ApiEndpoints.orders}/$orderId');
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  Future<Response> verifyPayment(Map<String, dynamic> data) async {
    try {
      return await _apiClient.post(ApiEndpoints.verifyRazorpay, data: data);
    } on DioException catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }
}
