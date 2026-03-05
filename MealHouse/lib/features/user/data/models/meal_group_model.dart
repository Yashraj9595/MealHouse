class MealItemModel {
  final String id;
  final String name;
  final String? description;
  final bool isAvailable;

  MealItemModel({
    required this.id,
    required this.name,
    this.description,
    this.isAvailable = true,
  });

  factory MealItemModel.fromJson(Map<String, dynamic> json) {
    return MealItemModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      isAvailable: json['isAvailable'] ?? true,
    );
  }
}

class UserMealGroupModel {
  final String id;
  final String name;
  final String description;
  final String mealType; // 'breakfast', 'lunch', 'dinner'
  final String category; // 'veg', 'non-veg'
  final double price;
  final List<MealItemModel> items;
  final int availableTiffins;
  final bool isActive;
  final String? messName;
  final String? messId;

  UserMealGroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.mealType,
    required this.category,
    required this.price,
    required this.items,
    required this.availableTiffins,
    required this.isActive,
    this.messName,
    this.messId,
  });

  factory UserMealGroupModel.fromJson(Map<String, dynamic> json) {
    return UserMealGroupModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      mealType: json['mealType'] ?? 'lunch',
      category: json['category'] ?? 'veg',
      price: (json['price'] ?? 0).toDouble(),
      items: (json['items'] as List?)?.map((item) => MealItemModel.fromJson(item)).toList() ?? [],
      availableTiffins: json['availableTiffins'] ?? 0,
      isActive: json['isActive'] ?? true,
      messName: json['mess'] != null ? (json['mess'] is Map ? json['mess']['name'] : null) : null,
      messId: json['mess'] != null ? (json['mess'] is Map ? json['mess']['_id'] : json['mess'].toString()) : null,
    );
  }
}
