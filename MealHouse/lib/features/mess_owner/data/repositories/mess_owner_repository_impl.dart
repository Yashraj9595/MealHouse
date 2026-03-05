import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/mess_owner_repository.dart';

class MessOwnerRepositoryImpl implements MessOwnerRepository {
  final DioClient _dioClient;

  MessOwnerRepositoryImpl(this._dioClient);

  @override
  Future<Map<String, dynamic>> getMyMessDetails() async {
    try {
      final response = await _dioClient.get('/messes/my/mess');
      return response.data['data'];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateMenu(Map<String, dynamic> menuData) async {
    // Implementation for updating meal groups/menu
  }

  @override
  Future<List<dynamic>> getActiveOrders() async {
    try {
      final response = await _dioClient.get('/orders/my/orders');
      return response.data['data'];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _dioClient.put('/orders/$orderId/status', data: {'status': status});
    } catch (e) {
      rethrow;
    }
  }
}
