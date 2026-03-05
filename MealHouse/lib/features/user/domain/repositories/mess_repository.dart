import 'package:MealHouse/features/user/data/models/mess_model.dart';
import 'package:MealHouse/features/user/data/models/meal_group_model.dart';
import 'package:MealHouse/features/user/data/models/order_model.dart';
import 'package:MealHouse/features/user/data/models/profile_model.dart';

abstract class MessRepository {
  Future<List<MessModel>> getMesses({
    String? city,
    String? mealType,
    String? search,
  });
  
  Future<MessModel> getMessDetails(String id);
  Future<List<UserMealGroupModel>> getFeaturedMeals();
}
