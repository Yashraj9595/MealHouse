class OrderModel {
  final String id;
  final String userId;
  final String messId;
  final String messName;
  final String mealName;
  final double amount;
  final String status; // 'pending', 'preparing', 'ready', 'delivered', 'cancelled'
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.messId,
    required this.messName,
    required this.mealName,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? '',
      userId: json['user'] ?? '',
      messId: json['mess']?['_id'] ?? '',
      messName: json['mess']?['name'] ?? 'Unknown Mess',
      mealName: json['items']?[0]?['name'] ?? 'Meal',
      amount: (json['totalAmount'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
