import '../../domain/entities/meal_group_entity.dart';
import '../../domain/entities/meal_item_entity.dart';

class MealGroupModel extends MealGroupEntity {
  MealGroupModel({
    required super.id,
    required super.title,
    required super.price,
    required super.items,
    super.isActive,
    super.imageUrl,
    super.videoUrl,
    required super.availableQuantity,
    required super.mealType,
  });

  factory MealGroupModel.fromJson(Map<String, dynamic> json) {
    return MealGroupModel(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['name'] ?? '', // API documentation uses 'name'
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => MealItemEntity(
                    id: e['_id'] ?? '',
                    name: e['name'] ?? '',
                    description: e['description'],
                    isAvailable: true, // defaulting
                  ))
              .toList() ??
          [],
      isActive: json['isActive'] ?? true,
      imageUrl: json['image'],
      videoUrl: json['video'],
      availableQuantity: json['availableTiffins'] ?? json['totalTiffins'] ?? 0,
            mealType: _parseMealType(json['mealType']),

    );
  }

  static MealType _parseMealType(String? type) {
    switch (type?.toLowerCase()) {
      case 'breakfast':
        return MealType.breakfast;
      case 'dinner':
        return MealType.dinner;
      case 'lunch':
      default:
        return MealType.lunch;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': title,
      'description': description ?? '', // Mapping title to description if needed or vice-versa, but based on API doc, title maps to name
      'price': price,
      'items': items.map((e) => {
        'name': e.name,
        // 'description': e.description, // API doc for Create Meal Group items object
      }).toList(),
      'isActive': isActive,
      'image': imageUrl,
      'video': videoUrl,
      'totalTiffins': availableQuantity,
      'mealType': mealType.name.toLowerCase(),
    };
  }
  
  // Helper to get description if needed, though entity doesn't have it yet.
  String? get description => null; 
}
