class MenuModel {
  final String? id;
  final String messId;
  final List<MenuItemModel> items;

  MenuModel({
    this.id,
    required this.messId,
    this.items = const [],
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['_id'],
      messId: json['messId'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => MenuItemModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'messId': messId,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  MenuModel copyWith({
    String? id,
    String? messId,
    List<MenuItemModel>? items,
  }) {
    return MenuModel(
      id: id ?? this.id,
      messId: messId ?? this.messId,
      items: items ?? this.items,
    );
  }
}

class MenuItemModel {
  final String? id;
  final String name;
  final String? description;
  final double price;
  final String category; // 'Veg', 'Non-Veg', 'Both', 'Snacks', 'Drinks'
  final List<String> mealType; // e.g. ['Breakfast', 'Lunch']
  final bool isAvailable;
  final String? image;
  final List<String> ingredients;
  final int platesAvailable;

  MenuItemModel({
    this.id,
    required this.name,
    this.description,
    required this.price,
    this.category = 'Veg',
    this.mealType = const ['Extra'],
    this.isAvailable = true,
    this.image,
    this.ingredients = const [],
    this.platesAvailable = 0,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['_id'],
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] ?? 'Veg',
      mealType: (json['mealType'] is List)
          ? (json['mealType'] as List).map((e) => e.toString()).toList()
          : [json['mealType']?.toString() ?? 'Extra'],
      isAvailable: json['isAvailable'] ?? true,
      image: json['image'],
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      platesAvailable: json['platesAvailable'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'mealType': mealType,
      'isAvailable': isAvailable,
      'image': image,
      'ingredients': ingredients,
      'platesAvailable': platesAvailable,
    };
  }

  MenuItemModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    List<String>? mealType,
    bool? isAvailable,
    String? image,
    List<String>? ingredients,
    int? platesAvailable,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      mealType: mealType ?? this.mealType,
      isAvailable: isAvailable ?? this.isAvailable,
      image: image ?? this.image,
      ingredients: ingredients ?? this.ingredients,
      platesAvailable: platesAvailable ?? this.platesAvailable,
    );
  }
}
