enum MealType { breakfast, lunch, dinner }

extension MealTypeExtension on MealType {
  String get name => toString().split('.').last;
  
  String get label {
    switch (this) {
      case MealType.breakfast: return 'Breakfast';
      case MealType.lunch:     return 'Lunch';
      case MealType.dinner:    return 'Dinner';
    }
  }
}
