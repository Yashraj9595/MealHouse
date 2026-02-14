abstract class MessOwnerRepository {
  Future<Map<String, dynamic>> getMyMessDetails();
  Future<void> updateMenu(Map<String, dynamic> menuData);
  Future<List<dynamic>> getActiveOrders();
  Future<void> updateOrderStatus(String orderId, String status);
}
