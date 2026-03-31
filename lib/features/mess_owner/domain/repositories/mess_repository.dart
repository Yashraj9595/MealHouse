import '../models/mess_model.dart';
import '../models/menu_model.dart';
import '../models/dashboard_stats_model.dart';

abstract class MessRepository {
  Future<List<MessModel>> getMesses({double? lat, double? lng, double? radius, String? cuisine});
  Future<MessModel> getMessById(String id);
  Future<List<MessModel>> getMyMesses();
  Future<MessModel> createMess(MessModel mess);
  Future<MessModel> updateMess(String id, Map<String, dynamic> updates);
  Future<void> deleteMess(String id);
  
  Future<MenuModel> getMenu(String messId);
  Future<MenuModel> updateMenu(MenuModel menu);
  Future<List<String>> uploadImages(List<String> imagePaths);
  Future<List<String>> uploadImagesBytes(List<List<int>> bytesList, List<String> fileNames);
  Future<DashboardStatsModel> getDashboardStats(String messId);
}
