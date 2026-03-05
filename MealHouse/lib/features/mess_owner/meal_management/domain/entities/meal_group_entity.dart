import 'meal_item_entity.dart';

enum MealType { breakfast, lunch, dinner }

extension MealTypeExtension on MealType {
  String get name {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
    }
  }
}

class MealGroupEntity {
  final String id;
  final String title;
  final double price;
  final List<MealItemEntity> items;
  final bool isActive;
  final String? imageUrl;
  final String? videoUrl;
  final int availableQuantity;
  final MealType mealType;

  MealGroupEntity({
    required this.id,
    required this.title,
    required this.price,
    required this.items,
    this.isActive = true,
    this.imageUrl,
    this.videoUrl,
    required this.availableQuantity,
    required this.mealType,
  });

  String get itemsDescription => items.map((e) => e.name).join(', ');
}
