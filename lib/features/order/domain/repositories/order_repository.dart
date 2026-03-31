import '../../domain/models/order_model.dart';

abstract class OrderRepository {
  Future<OrderModel> createOrder(OrderModel order);
  Future<List<OrderModel>> getMyOrders();
  Future<List<OrderModel>> getMessOrders(String messId);
  Future<OrderModel> updateOrderStatus(String orderId, String status);
  Future<OrderModel> getOrderById(String orderId);
  Future<OrderModel> verifyPayment(String orderId, String paymentId, String signature);
}
