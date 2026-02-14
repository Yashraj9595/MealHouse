import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/order_model.dart';
import '../models/profile_model.dart';

class UserRepositoryImpl implements UserRepository {
  final DioClient _dioClient;

  UserRepositoryImpl(this._dioClient);

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final response = await _dioClient.get('/auth/me');
      return ProfileModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await _dioClient.get('/orders/my/orders');
      final List ordersJson = response.data['data'];
      return ordersJson.map((j) => OrderModel.fromJson(j)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      await _dioClient.put('/auth/updatedetails', data: data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> placeOrder(Map<String, dynamic> orderData) async {
    try {
      await _dioClient.post('/orders', data: orderData);
    } catch (e) {
      rethrow;
    }
  }
}
