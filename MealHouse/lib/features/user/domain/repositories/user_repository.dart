import '../../data/models/order_model.dart';
import '../../data/models/profile_model.dart';

abstract class UserRepository {
  Future<ProfileModel> getProfile();
  Future<List<OrderModel>> getOrders();
  Future<void> updateProfile(Map<String, dynamic> data);
  Future<String> placeOrder(Map<String, dynamic> orderData);
  Future<Map<String, dynamic>> createRazorpayOrder(String orderId);
  Future<void> verifyRazorpayPayment(Map<String, dynamic> paymentData);
}
