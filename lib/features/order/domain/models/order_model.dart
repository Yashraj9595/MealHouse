class OrderModel {
  final String? id;
  final String userId;
  final String messId;
  final List<OrderItemModel> items;
  final double totalPrice;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final DateTime? orderDate;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? razorpaySignature;

  OrderModel({
    this.id,
    required this.userId,
    required this.messId,
    required this.items,
    required this.totalPrice,
    this.status = 'Pending',
    this.paymentStatus = 'Pending',
    required this.paymentMethod,
    this.orderDate,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.razorpaySignature,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'],
      userId: json['userId'] ?? '',
      messId: json['messId'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItemModel.fromJson(item))
              .toList() ??
          [],
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'Pending',
      paymentStatus: json['paymentStatus'] ?? 'Pending',
      paymentMethod: json['paymentMethod'] ?? '',
      orderDate: json['orderDate'] != null ? DateTime.parse(json['orderDate']) : null,
      razorpayOrderId: json['razorpayOrderId'],
      razorpayPaymentId: json['razorpayPaymentId'],
      razorpaySignature: json['razorpaySignature'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'userId': userId,
      'messId': messId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'orderDate': orderDate?.toIso8601String(),
      if (razorpayOrderId != null) 'razorpayOrderId': razorpayOrderId,
      if (razorpayPaymentId != null) 'razorpayPaymentId': razorpayPaymentId,
      if (razorpaySignature != null) 'razorpaySignature': razorpaySignature,
    };
  }
}

class OrderItemModel {
  final String name;
  final int quantity;
  final double price;
  final String? mealType;

  OrderItemModel({
    required this.name,
    required this.quantity,
    required this.price,
    this.mealType,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      mealType: json['mealType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      if (mealType != null) 'mealType': mealType,
    };
  }
}
