enum OrderStatus { pending, preparing, ready, delivered, cancelled }

class OrderEntity {
  final String id;
  final String customerName;
  final String customerPhone;
  final String mealName;
  final double price;
  final DateTime orderTime;
  final OrderStatus status;
  final String? specialInstructions;
  final List<Map<String, dynamic>> items;

  OrderEntity({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.mealName,
    required this.price,
    required this.orderTime,
    required this.status,
    this.specialInstructions,
    this.items = const [],
  });
}
