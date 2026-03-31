import '../../domain/entities/order_status.dart';

class OrderModel {
  final String id;
  final String mealName;
  final String providerName;
  final String mealType;
  final String timeSlot;
  final double price;
  final String imageUrl;
  final String imageSemanticLabel;
  final OrderStatus status;
  final String pickupLocation;
  final String pickupDetail;
  final String date;
  final bool isVeg;

  const OrderModel({
    required this.id,
    required this.mealName,
    required this.providerName,
    required this.mealType,
    required this.timeSlot,
    required this.price,
    required this.imageUrl,
    required this.imageSemanticLabel,
    required this.status,
    required this.pickupLocation,
    required this.pickupDetail,
    required this.date,
    required this.isVeg,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] as String,
      mealName: map['mealName'] as String,
      providerName: map['providerName'] as String,
      mealType: map['mealType'] as String,
      timeSlot: map['timeSlot'] as String,
      price: (map['price'] as num).toDouble(),
      imageUrl: map['imageUrl'] as String,
      imageSemanticLabel: map['imageSemanticLabel'] as String,
      status: _statusFromString(map['status'] as String),
      pickupLocation: map['pickupLocation'] as String,
      pickupDetail: map['pickupDetail'] as String,
      date: map['date'] as String,
      isVeg: map['isVeg'] as bool,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'mealName': mealName,
    'providerName': providerName,
    'mealType': mealType,
    'timeSlot': timeSlot,
    'price': price,
    'imageUrl': imageUrl,
    'imageSemanticLabel': imageSemanticLabel,
    'status': status.name,
    'pickupLocation': pickupLocation,
    'pickupDetail': pickupDetail,
    'date': date,
    'isVeg': isVeg,
  };

  static OrderStatus _statusFromString(String v) {
    switch (v) {
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'outForDelivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'upcoming':
        return OrderStatus.upcoming;
      default:
        return OrderStatus.confirmed;
    }
  }
}
