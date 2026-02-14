import 'package:MealHouse/features/mess_owner/order_management/domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  OrderModel({
    required String id,
    required String customerName,
    required String customerPhone,
    required String mealName,
    required double price,
    required DateTime orderTime,
    required OrderStatus status,
    String? specialInstructions,
    List<Map<String, dynamic>> items = const [],
  }) : super(
          id: id,
          customerName: customerName,
          customerPhone: customerPhone,
          mealName: mealName,
          price: price,
          orderTime: orderTime,
          status: status,
          specialInstructions: specialInstructions,
          items: items,
        );

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Map status string to enum
    OrderStatus status = OrderStatus.pending;
    switch (json['status']) {
      case 'pending': status = OrderStatus.pending; break;
      case 'confirmed': status = OrderStatus.preparing; break; // Mapping confirmed to preparing or add confirmed to enum
      case 'preparing': status = OrderStatus.preparing; break;
      case 'ready': status = OrderStatus.ready; break;
      case 'delivered': status = OrderStatus.delivered; break;
      case 'cancelled': status = OrderStatus.cancelled; break;
    }

    // Handle items list to create a single meal name string or join
    String mealName = 'Unknown Meal';
    List<Map<String, dynamic>> itemsList = [];

    if (json['items'] != null && (json['items'] as List).isNotEmpty) {
      final items = json['items'] as List;
      mealName = items.map((i) => "${i['quantity']}x ${i['mealGroupName']}").join(', ');

      // Map raw items to structure expected by UI
      itemsList = items.map((i) {
        return {
          "name": i['mealGroupName'],
          "quantity": i['quantity'],
          "price": i['price'],
          "subtotal": i['subtotal'],
          "items": i['items'], // internal items of meal group if any
        };
      }).toList();
    }

    return OrderModel(
      id: json['_id'] ?? '',
      customerName: json['user']?['name'] ?? 'Unknown Customer',
      customerPhone: json['contactPhone'] ?? json['user']?['phone'] ?? '',
      mealName: mealName,
      price: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      orderTime: DateTime.parse(json['createdAt']),
      status: status,
      specialInstructions: json['specialInstructions'],
      items: itemsList,
    );
  }
}
