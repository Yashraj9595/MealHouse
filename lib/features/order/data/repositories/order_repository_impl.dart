import '../../domain/models/order_model.dart';
import '../../domain/repositories/order_repository.dart';
import '../services/order_service.dart';
import '../../../../core/error/app_exceptions.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderService _orderService;

  OrderRepositoryImpl(this._orderService);

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      final response = await _orderService.createOrder(order.toJson());
      if (response.statusCode == 201) {
        return OrderModel.fromJson(response.data['data']);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to create order');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<OrderModel>> getMyOrders() async {
    try {
      final response = await _orderService.getMyOrders();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((e) => OrderModel.fromJson(e)).toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to fetch orders');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<OrderModel>> getMessOrders(String messId) async {
    try {
      final response = await _orderService.getMessOrders(messId);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((e) => OrderModel.fromJson(e)).toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to fetch mess orders');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<OrderModel> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await _orderService.updateOrderStatus(orderId, status);
      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data['data']);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to update order status');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final response = await _orderService.getOrderById(orderId);
      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data['data']);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to fetch order');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<OrderModel> verifyPayment(String orderId, String paymentId, String signature) async {
    try {
      final response = await _orderService.verifyPayment({
        'razorpayOrderId': orderId,
        'razorpayPaymentId': paymentId,
        'razorpaySignature': signature,
      });
      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data['data']);
      } else {
        throw ServerException(response.data['message'] ?? 'Payment verification failed');
      }
    } catch (e) {
      rethrow;
    }
  }
}
