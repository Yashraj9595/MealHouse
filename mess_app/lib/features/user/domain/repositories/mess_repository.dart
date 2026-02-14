import '../../data/models/mess_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/profile_model.dart';

abstract class MessRepository {
  Future<List<MessModel>> getMesses({
    String? city,
    String? mealType,
    String? search,
  });
  
  Future<MessModel> getMessDetails(String id);
}
