import '../../data/models/order_model.dart';
import '../../data/models/profile_model.dart';

abstract class UserRepository {
  Future<ProfileModel> getProfile();
  Future<List<OrderModel>> getOrders();
  Future<void> updateProfile(Map<String, dynamic> data);
  Future<void> placeOrder(Map<String, dynamic> orderData);
}
